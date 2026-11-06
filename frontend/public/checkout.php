<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

if (!isset($_SESSION['usr_id'])) {
    header('Location: login.php');
    exit;
}

$carrinhoDigital = [];
foreach (array_keys($_SESSION['carrinho'] ?? []) as $id) {
    $id = (int) $id;
    if ($id > 0) {
        $carrinhoDigital[$id] = 1;
    }
}
$_SESSION['carrinho'] = $carrinhoDigital;

require_once __DIR__ . '/../../backend/config/conexao.php';
require_once __DIR__ . '/../../backend/config/pedidos.php';
$conexao = new Conexao();
$pdo = $conexao->conectar();
garantirTabelasPedidos($pdo);
$stmtUsuario = $pdo->prepare('SELECT forma_pagamento_preferida FROM usuarios WHERE usr_id = ?');
$stmtUsuario->execute([(int) $_SESSION['usr_id']]);
$formaPagamentoPreferida = $stmtUsuario->fetchColumn() ?: 'pix';

$metodos = [
    'cartao' => 'Cartão de crédito',
    'pix' => 'Pix',
    'boleto' => 'Boleto'
];
$erro = '';
$pedidoConcluido = null;

if (isset($_GET['pedido'])) {
    $stmt = $pdo->prepare('SELECT pedido_id, status, valor_total, forma_pagamento FROM pedidos WHERE pedido_id = ? AND usr_id = ?');
    $stmt->execute([(int) $_GET['pedido'], (int) $_SESSION['usr_id']]);
    $pedidoConcluido = $stmt->fetch();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $tokenEnviado = $_POST['csrf_token'] ?? '';
    $metodo = $_POST['forma_pagamento'] ?? '';

    if (!hash_equals($_SESSION['csrf_checkout'] ?? '', $tokenEnviado)) {
        $erro = 'Sua sessão expirou. Atualize a página e tente novamente.';
    } elseif (!isset($metodos[$metodo])) {
        $erro = 'Selecione uma forma de pagamento válida.';
    } elseif (empty($_SESSION['carrinho'])) {
        $erro = 'Seu carrinho está vazio.';
    } else {
        try {
            $pdo->beginTransaction();
            $itensPedido = [];
            $totalPedido = 0;

            foreach ($_SESSION['carrinho'] as $id => $_) {
                $stmt = $pdo->prepare('SELECT jogo_id, titulo, preco, quantidade_estoque, ativo FROM jogos WHERE jogo_id = ? FOR UPDATE');
                $stmt->execute([(int) $id]);
                $produto = $stmt->fetch();
                $quantidade = 1;

                if (!$produto || !$produto['ativo'] || $produto['quantidade_estoque'] < 1) {
                    throw new RuntimeException('Um ou mais jogos estão indisponíveis ou sem chaves digitais. Revise seu carrinho.');
                }

                $produto['quantidade'] = $quantidade;
                $itensPedido[] = $produto;
                $totalPedido += (float) $produto['preco'] * $quantidade;
            }

            if (!$itensPedido) {
                throw new RuntimeException('Seu carrinho está vazio.');
            }

            $stmt = $pdo->prepare("INSERT INTO pedidos (usr_id, status, forma_pagamento, valor_total) VALUES (?, 'pendente', ?, ?)");
            $stmt->execute([(int) $_SESSION['usr_id'], $metodo, $totalPedido]);
            $pedidoId = (int) $pdo->lastInsertId();
            $stmtItem = $pdo->prepare('INSERT INTO itens_pedido (pedido_id, jogo_id, quantidade, preco_unitario) VALUES (?, ?, ?, ?)');
            $stmtEstoque = $pdo->prepare('UPDATE jogos SET quantidade_estoque = quantidade_estoque - ? WHERE jogo_id = ? AND quantidade_estoque >= ?');

            foreach ($itensPedido as $item) {
                $stmtItem->execute([$pedidoId, $item['jogo_id'], $item['quantidade'], $item['preco']]);
                $stmtEstoque->execute([$item['quantidade'], $item['jogo_id'], $item['quantidade']]);

                if ($stmtEstoque->rowCount() !== 1) {
                    throw new RuntimeException('O estoque mudou durante a compra. Tente novamente.');
                }
            }

            $pdo->commit();
            $_SESSION['carrinho'] = [];
            header('Location: checkout.php?pedido=' . $pedidoId);
            exit;
        } catch (RuntimeException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            $erro = $e->getMessage();
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            $erro = 'Não foi possível registrar o pedido. Tente novamente.';
        }
    }
}

$_SESSION['csrf_checkout'] = bin2hex(random_bytes(32));
$produtos = [];
$total = 0;

if (!$pedidoConcluido) {
    foreach ($_SESSION['carrinho'] ?? [] as $id => $_) {
        $stmt = $pdo->prepare('SELECT jogo_id, titulo, preco FROM jogos WHERE jogo_id = ? AND ativo = 1');
        $stmt->execute([(int) $id]);
        $produto = $stmt->fetch();

        if ($produto) {
            $produto['subtotal'] = (float) $produto['preco'];
            $total += $produto['subtotal'];
            $produtos[] = $produto;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finalizar compra - Louja</title>
    <link rel="stylesheet" href="css/style.css">
    <?php require __DIR__ . '/tema-head.php'; ?>
</head>
<body>
<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>
    <nav>
        <a href="jogos.php">Jogos</a>
        <?php require __DIR__ . '/perfil-avatar.php'; ?>
    </nav>
</header>

<main class="pagina">
    <h1>Finalizar compra</h1>

    <?php if ($pedidoConcluido): ?>
        <section class="checkout-sucesso">
            <h2>Pedido registrado</h2>
            <p>Pedido #<?= (int) $pedidoConcluido['pedido_id'] ?> recebido com pagamento por <?= htmlspecialchars($metodos[$pedidoConcluido['forma_pagamento']] ?? 'pagamento') ?>.</p>
            <p>Status: <?= htmlspecialchars(ucfirst($pedidoConcluido['status'])) ?>. Total: R$ <?= number_format((float) $pedidoConcluido['valor_total'], 2, ',', '.') ?></p>
        </section>
        <p class="checkout-aviso">Esta loja está em modo demonstrativo. Nenhum pagamento real foi processado.</p>
        <a class="botao" href="jogos.php">Voltar para a loja</a>
    <?php elseif (empty($produtos)): ?>
        <p>Seu carrinho está vazio.</p>
        <a class="botao" href="jogos.php">Ver jogos</a>
    <?php else: ?>
        <p class="checkout-aviso">Modo demonstrativo: os dados de pagamento não são enviados nem armazenados e nenhuma cobrança real será feita.</p>

        <?php if ($erro !== ''): ?>
            <p class="erro" role="alert"><?= htmlspecialchars($erro) ?></p>
        <?php endif; ?>

        <section class="checkout-resumo" aria-labelledby="titulo-resumo">
            <h2 id="titulo-resumo">Resumo do pedido</h2>
            <?php foreach ($produtos as $produto): ?>
                <div class="checkout-linha">
                    <span><?= htmlspecialchars($produto['titulo']) ?></span>
                    <span>R$ <?= number_format($produto['subtotal'], 2, ',', '.') ?></span>
                </div>
            <?php endforeach; ?>
            <p class="checkout-total">Total: R$ <?= number_format($total, 2, ',', '.') ?></p>
        </section>

        <form method="post" class="checkout-pagamento" id="form-checkout">
            <h2>Forma de pagamento</h2>
            <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_checkout']) ?>">

            <fieldset class="checkout-opcoes">
                <legend>Escolha uma opção</legend>
                <label><input type="radio" name="forma_pagamento" value="cartao" required <?= $formaPagamentoPreferida === 'cartao' ? 'checked' : '' ?>> Cartão de crédito</label>
                <label><input type="radio" name="forma_pagamento" value="pix" required <?= $formaPagamentoPreferida === 'pix' ? 'checked' : '' ?>> Pix</label>
                <label><input type="radio" name="forma_pagamento" value="boleto" required <?= $formaPagamentoPreferida === 'boleto' ? 'checked' : '' ?>> Boleto</label>
            </fieldset>

            <div class="checkout-painel" data-payment-panel="cartao" hidden>
                <div class="checkout-campos">
                    <div class="checkout-campo checkout-campo-largo">
                        <label for="titular">Nome impresso no cartão</label>
                        <input id="titular" type="text" autocomplete="cc-name" data-required="true">
                    </div>
                    <div class="checkout-campo checkout-campo-largo">
                        <label for="numero-cartao">Número do cartão</label>
                        <input id="numero-cartao" type="text" inputmode="numeric" autocomplete="cc-number" maxlength="19" pattern="[0-9 ]{13,19}" placeholder="0000 0000 0000 0000" data-required="true">
                    </div>
                    <div class="checkout-campo">
                        <label for="validade">Validade</label>
                        <input id="validade" type="month" autocomplete="cc-exp" data-required="true">
                    </div>
                    <div class="checkout-campo">
                        <label for="cvv">Código de segurança</label>
                        <input id="cvv" type="password" inputmode="numeric" autocomplete="cc-csc" maxlength="4" pattern="[0-9]{3,4}" data-required="true">
                    </div>
                </div>
            </div>

            <div class="checkout-painel" data-payment-panel="pix" hidden>
                <div class="pix-demonstracao">
                    <div class="pix-demonstracao-info">
                        <span class="pix-demonstracao-etiqueta">PIX • DEMONSTRAÇÃO</span>
                        <h3>QR Code ilustrativo</h3>
                        <p>Este código é apenas visual. Não pode ser escaneado e não realiza pagamentos.</p>
                        <strong>Valor: R$ <?= number_format($total, 2, ',', '.') ?></strong>
                    </div>
                    <div class="pix-qr" role="img" aria-label="QR Code ilustrativo de demonstração, não válido para pagamento">
                        <svg viewBox="0 0 41 41" aria-hidden="true" focusable="false" data-qr-demonstracao>
                            <rect width="41" height="41" fill="#fff"></rect>
                        </svg>
                        <span>DEMO</span>
                    </div>
                </div>
            </div>

            <div class="checkout-painel" data-payment-panel="boleto" hidden>
                <div class="checkout-campos">
                    <div class="checkout-campo">
                        <label for="nome-boleto">Nome completo</label>
                        <input id="nome-boleto" type="text" autocomplete="name" data-required="true">
                    </div>
                    <div class="checkout-campo">
                        <label for="cpf-boleto">CPF do pagador</label>
                        <input id="cpf-boleto" type="text" inputmode="numeric" maxlength="11" pattern="[0-9]{11}" placeholder="Somente números" data-required="true">
                    </div>
                </div>
            </div>

            <div class="checkout-acoes">
                <button class="botao" type="submit">Confirmar pedido</button>
                <?php if (($_SESSION['usr_perfil'] ?? '') !== 'admin'): ?>
                    <a href="carrinho.php">Voltar ao carrinho</a>
                <?php endif; ?>
            </div>
        </form>
    <?php endif; ?>
</main>

<script>
const paineisPagamento = document.querySelectorAll('[data-payment-panel]');
const opcoesPagamento = document.querySelectorAll('input[name="forma_pagamento"]');

function atualizarCamposPagamento() {
    const metodoSelecionado = document.querySelector('input[name="forma_pagamento"]:checked')?.value;

    paineisPagamento.forEach((painel) => {
        const ativo = painel.dataset.paymentPanel === metodoSelecionado;
        painel.hidden = !ativo;
        painel.querySelectorAll('[data-required="true"]').forEach((campo) => {
            campo.required = ativo;
        });
    });
}

function desenharQrDemonstracao(svg) {
    const tamanho = 33;
    const reservado = new Set();
    const modulosEscuros = new Set();

    function marcar(x, y, escuro) {
        if (x < 0 || y < 0 || x >= tamanho || y >= tamanho) {
            return;
        }

        const chave = `${x},${y}`;
        reservado.add(chave);
        if (escuro) {
            modulosEscuros.add(chave);
        }
    }

    [[0, 0], [26, 0], [0, 26]].forEach(([inicioX, inicioY]) => {
        for (let y = -1; y <= 7; y++) {
            for (let x = -1; x <= 7; x++) {
                const distancia = Math.max(Math.abs(x - 3), Math.abs(y - 3));
                marcar(inicioX + x, inicioY + y, distancia === 3 || distancia <= 1);
            }
        }
    });

    for (let posicao = 8; posicao < 25; posicao++) {
        marcar(posicao, 6, posicao % 2 === 0);
        marcar(6, posicao, posicao % 2 === 0);
    }

    for (let y = -2; y <= 2; y++) {
        for (let x = -2; x <= 2; x++) {
            const distancia = Math.max(Math.abs(x), Math.abs(y));
            marcar(26 + x, 26 + y, distancia === 2 || distancia === 0);
        }
    }

    let semente = 2026;
    function proximoBit() {
        semente = (semente * 9301 + 49297) % 233280;
        return semente / 233280 > .5;
    }

    for (let y = 0; y < tamanho; y++) {
        for (let x = 0; x < tamanho; x++) {
            if (!reservado.has(`${x},${y}`) && proximoBit()) {
                modulosEscuros.add(`${x},${y}`);
            }
        }
    }

    const grupo = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    grupo.setAttribute('fill', '#17121d');
    modulosEscuros.forEach((chave) => {
        const [x, y] = chave.split(',').map(Number);
        const modulo = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        modulo.setAttribute('x', String(x + 4));
        modulo.setAttribute('y', String(y + 4));
        modulo.setAttribute('width', '1');
        modulo.setAttribute('height', '1');
        grupo.appendChild(modulo);
    });
    svg.appendChild(grupo);
}

opcoesPagamento.forEach((opcao) => opcao.addEventListener('change', atualizarCamposPagamento));
atualizarCamposPagamento();
document.querySelectorAll('[data-qr-demonstracao]').forEach(desenharQrDemonstracao);
</script>
</body>
</html>