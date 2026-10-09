<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';
require_once __DIR__ . '/../../../backend/config/pedidos.php';

if (!isset($_SESSION['usr_id']) || ($_SESSION['usr_perfil'] ?? '') !== 'admin') {
    header('Location: ../login.php');
    exit;
}

garantirTabelasPedidos($pdo);
$pedidoId = filter_var($_GET['id'] ?? null, FILTER_VALIDATE_INT);
$statusNomes = [
    'pendente' => 'Pendente',
    'pago' => 'Pago',
    'enviado' => 'Enviado',
    'cancelado' => 'Cancelado'
];
$metodoNomes = [
    'cartao' => 'Cartão',
    'pix' => 'Pix',
    'boleto' => 'Boleto'
];
$mensagem = $_SESSION['flash_venda_detalhe'] ?? null;
unset($_SESSION['flash_venda_detalhe']);

if (!$pedidoId) {
    http_response_code(404);
    $pedido = null;
} else {
    $stmt = $pdo->prepare(
        'SELECT p.*, u.nome AS cliente_nome, u.email AS cliente_email,
                verificador.nome AS verificador_nome
         FROM pedidos AS p
         JOIN usuarios AS u ON u.usr_id = p.usr_id
         LEFT JOIN usuarios AS verificador ON verificador.usr_id = p.dados_verificados_por
         WHERE p.pedido_id = ?'
    );
    $stmt->execute([$pedidoId]);
    $pedido = $stmt->fetch();
    if (!$pedido) {
        http_response_code(404);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $pedido) {
    $token = $_POST['csrf_token'] ?? '';
    $acao = $_POST['acao'] ?? '';
    $mensagemErro = '';

    if (!is_string($token) || !hash_equals($_SESSION['csrf_venda_detalhe'] ?? '', $token)) {
        $mensagemErro = 'Sua sessão expirou. Atualize a página e tente novamente.';
    } else {
        try {
            if ($acao === 'verificar_cliente') {
                $stmt = $pdo->prepare(
                    'UPDATE pedidos
                     SET dados_cliente_verificados = 1, dados_verificados_por = ?, dados_verificados_em = CURRENT_TIMESTAMP
                     WHERE pedido_id = ?'
                );
                $stmt->execute([(int) $_SESSION['usr_id'], $pedidoId]);
                $_SESSION['flash_venda_detalhe'] = ['tipo' => 'sucesso', 'texto' => 'Dados cadastrados do cliente marcados como conferidos.'];
            } elseif ($acao === 'confirmar_compra') {
                if ($pedido['status'] !== 'pendente' || !(int) $pedido['dados_cliente_verificados']) {
                    throw new RuntimeException('Confira os dados do cliente antes de confirmar a compra.');
                }
                atualizarStatusPedido($pdo, $pedidoId, 'pago');
                $_SESSION['flash_venda_detalhe'] = ['tipo' => 'sucesso', 'texto' => 'Compra confirmada e marcada como paga.'];
            } elseif ($acao === 'recusar_compra') {
                if ($pedido['status'] !== 'pendente') {
                    throw new RuntimeException('Somente pedidos pendentes podem ser recusados nesta tela.');
                }
                atualizarStatusPedido($pdo, $pedidoId, 'cancelado');
                $_SESSION['flash_venda_detalhe'] = ['tipo' => 'sucesso', 'texto' => 'Pedido recusado e cancelado; o estoque foi atualizado.'];
            } elseif ($acao === 'marcar_enviado') {
                if ($pedido['status'] !== 'pago') {
                    throw new RuntimeException('Somente pedidos pagos podem ser marcados como enviados.');
                }
                atualizarStatusPedido($pdo, $pedidoId, 'enviado');
                $_SESSION['flash_venda_detalhe'] = ['tipo' => 'sucesso', 'texto' => 'Pedido marcado como enviado.'];
            } else {
                throw new RuntimeException('Ação inválida.');
            }
        } catch (Throwable $e) {
            $mensagemErro = $e instanceof RuntimeException ? $e->getMessage() : 'Não foi possível atualizar o pedido.';
        }
    }

    if ($mensagemErro !== '') {
        $_SESSION['flash_venda_detalhe'] = ['tipo' => 'erro', 'texto' => $mensagemErro];
    }
    header('Location: venda.php?id=' . $pedidoId);
    exit;
}

$_SESSION['csrf_venda_detalhe'] = bin2hex(random_bytes(32));
$itens = [];
if ($pedido) {
    $stmt = $pdo->prepare(
        'SELECT ip.jogo_id, ip.quantidade, ip.preco_unitario, j.titulo, j.plataforma
         FROM itens_pedido AS ip
         JOIN jogos AS j ON j.jogo_id = ip.jogo_id
         WHERE ip.pedido_id = ?
         ORDER BY j.titulo'
    );
    $stmt->execute([$pedidoId]);
    $itens = $stmt->fetchAll();
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analisar pedido - Admin Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <a href="../index.php" class="logo">
        <img src="../../../docs/logolouja.png" alt="Louja">
    </a>
    <nav>
        <a href="index.php">Jogos</a>
        <a href="vendas.php" aria-current="page">Vendas</a>
        <span>Ol&aacute;, <?= htmlspecialchars($_SESSION['usr_nome'] ?? 'Admin') ?></span>
        <a href="../index.php">Voltar para a loja</a>
        <a href="../logout.php">Sair</a>
    </nav>
</header>

<main class="admin">
    <div class="admin-cabecalho">
        <div>
            <h1><?= $pedido ? 'Análise do pedido #' . (int) $pedido['pedido_id'] : 'Pedido não encontrado' ?></h1>
            <p>Confira os dados cadastrados e valide a compra.</p>
        </div>
        <a class="botao" href="vendas.php">Voltar às vendas</a>
    </div>

    <?php if ($mensagem): ?>
        <p class="vendas-mensagem <?= $mensagem['tipo'] === 'erro' ? 'vendas-mensagem-erro' : '' ?>" role="status">
            <?= htmlspecialchars($mensagem['texto']) ?>
        </p>
    <?php endif; ?>

    <?php if (!$pedido): ?>
        <p class="venda-bloco">Não há um pedido com esse número.</p>
    <?php else: ?>
        <div class="venda-detalhe-colunas">
            <section class="venda-bloco" aria-labelledby="titulo-cliente">
                <h2 id="titulo-cliente">Dados do cliente</h2>
                <div class="venda-dados">
                    <div><span>Nome</span><strong><?= htmlspecialchars($pedido['cliente_nome']) ?></strong></div>
                    <div><span>E-mail</span><strong><?= htmlspecialchars($pedido['cliente_email']) ?></strong></div>
                    <div><span>Código do cliente</span><strong>#<?= (int) $pedido['usr_id'] ?></strong></div>
                </div>
                <p class="venda-nota">O cadastro da loja contém nome e e-mail. CPF e endereço não são registrados.</p>

                <?php if ((int) $pedido['dados_cliente_verificados']): ?>
                    <p class="venda-auditoria">
                        Dados conferidos por <?= htmlspecialchars($pedido['verificador_nome'] ?? 'admin #' . $pedido['dados_verificados_por']) ?>
                        em <?= htmlspecialchars(date('d/m/Y H:i', strtotime($pedido['dados_verificados_em']))) ?>.
                    </p>
                <?php else: ?>
                    <form method="post" class="venda-form-acao">
                        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_venda_detalhe']) ?>">
                        <input type="hidden" name="acao" value="verificar_cliente">
                        <button class="botao" type="submit">Marcar dados do cliente como conferidos</button>
                    </form>
                <?php endif; ?>
            </section>

            <section class="venda-bloco" aria-labelledby="titulo-pedido">
                <h2 id="titulo-pedido">Dados da compra</h2>
                <div class="venda-dados">
                    <div><span>Pedido</span><strong>#<?= (int) $pedido['pedido_id'] ?></strong></div>
                    <div><span>Data</span><strong><?= htmlspecialchars(date('d/m/Y H:i', strtotime($pedido['data_pedido']))) ?></strong></div>
                    <div><span>Pagamento</span><strong><?= htmlspecialchars($metodoNomes[$pedido['forma_pagamento']] ?? 'Não informado') ?></strong></div>
                    <div><span>Status</span><strong><span class="vendas-status vendas-status-<?= htmlspecialchars($pedido['status']) ?>"><?= htmlspecialchars($statusNomes[$pedido['status']] ?? $pedido['status']) ?></span></strong></div>
                </div>
                <p class="venda-total">Total: R$ <?= number_format((float) $pedido['valor_total'], 2, ',', '.') ?></p>
            </section>
        </div>

        <section class="venda-bloco" aria-labelledby="titulo-itens">
            <h2 id="titulo-itens">Itens do pedido</h2>
            <div class="vendas-tabela-wrap">
                <table class="vendas-tabela venda-itens-tabela">
                    <thead>
                        <tr><th>Produto</th><th>Plataforma</th><th>Quantidade</th><th>Preço unitário</th><th>Subtotal</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach ($itens as $item): ?>
                            <tr>
                                <td><?= htmlspecialchars($item['titulo']) ?></td>
                                <td><?= htmlspecialchars($item['plataforma']) ?></td>
                                <td><?= (int) $item['quantidade'] ?></td>
                                <td>R$ <?= number_format((float) $item['preco_unitario'], 2, ',', '.') ?></td>
                                <td>R$ <?= number_format((float) $item['preco_unitario'] * (int) $item['quantidade'], 2, ',', '.') ?></td>
                            </tr>
                        <?php endforeach; ?>
                        <?php if (!$itens): ?>
                            <tr><td colspan="5" class="vendas-vazio">Este pedido não possui itens disponíveis.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="venda-bloco venda-validacao" aria-labelledby="titulo-validacao">
            <h2 id="titulo-validacao">Validação administrativa</h2>
            <p>Confira o pagamento no sistema utilizado pela loja antes de confirmar a compra. Esta tela não processa cobranças.</p>
            <div class="venda-acoes">
                <?php if ($pedido['status'] === 'pendente'): ?>
                    <?php if ((int) $pedido['dados_cliente_verificados']): ?>
                        <form method="post" class="venda-form-acao">
                            <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_venda_detalhe']) ?>">
                            <input type="hidden" name="acao" value="confirmar_compra">
                            <button class="botao" type="submit">Confirmar pagamento e compra</button>
                        </form>
                    <?php else: ?>
                        <button class="botao" type="button" disabled>Confira os dados antes de aprovar</button>
                    <?php endif; ?>
                    <form method="post" class="venda-form-acao" onsubmit="return confirm('Recusar e cancelar este pedido? O estoque será restaurado.');">
                        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_venda_detalhe']) ?>">
                        <input type="hidden" name="acao" value="recusar_compra">
                        <button class="botao venda-recusar" type="submit">Recusar e cancelar</button>
                    </form>
                <?php elseif ($pedido['status'] === 'pago'): ?>
                    <form method="post" class="venda-form-acao">
                        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_venda_detalhe']) ?>">
                        <input type="hidden" name="acao" value="marcar_enviado">
                        <button class="botao" type="submit">Marcar como enviado</button>
                    </form>
                <?php else: ?>
                    <p class="venda-estado-final">Este pedido está <?= htmlspecialchars($statusNomes[$pedido['status']] ?? $pedido['status']) ?>.</p>
                <?php endif; ?>
            </div>
        </section>
    <?php endif; ?>
</main>
</body>
</html>