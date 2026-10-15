<?php
session_start();

if (!isset($_SESSION['usr_id'])) {
    header('Location: login.php');
    exit;
}

require_once __DIR__ . '/../../backend/config/conexao.php';
require_once __DIR__ . '/../../backend/config/pedidos.php';

$conexao = new Conexao();
$pdo = $conexao->conectar();
garantirTabelasPedidos($pdo);

$usuarioId = (int) $_SESSION['usr_id'];
$metodosPagamento = [
    'cartao' => 'Cartão de crédito',
    'pix' => 'Pix',
    'boleto' => 'Boleto'
];
$erro = '';
$sucesso = '';
$mostrarFormularioSenha = false;

if (empty($_SESSION['csrf_perfil'])) {
    $_SESSION['csrf_perfil'] = bin2hex(random_bytes(32));
}

$stmtUsuario = $pdo->prepare('SELECT usr_id, nome, email, senha, forma_pagamento_preferida FROM usuarios WHERE usr_id = ?');
$stmtUsuario->execute([$usuarioId]);
$usuario = $stmtUsuario->fetch();

if (!$usuario) {
    session_unset();
    session_destroy();
    header('Location: login.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $token = $_POST['csrf_token'] ?? '';
    $acao = $_POST['acao'] ?? '';
    $mostrarFormularioSenha = $acao === 'atualizar_senha';

    if (!hash_equals($_SESSION['csrf_perfil'], $token)) {
        $erro = 'Sua sessão expirou. Atualize a página e tente novamente.';
    } elseif ($acao === 'atualizar_dados') {
        $nome = trim($_POST['nome'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $formaPagamento = $_POST['forma_pagamento_preferida'] ?? '';
        $senhaAtual = $_POST['senha_atual'] ?? '';

        if ($nome === '' || strlen($nome) > 100) {
            $erro = 'Informe um nome com até 100 caracteres.';
        } elseif (strlen($email) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $erro = 'Informe um e-mail válido com até 100 caracteres.';
        } elseif (!isset($metodosPagamento[$formaPagamento])) {
            $erro = 'Selecione uma forma de pagamento válida.';
        } elseif (!password_verify($senhaAtual, $usuario['senha'])) {
            $erro = 'A senha atual não confere.';
        } else {
            $stmtEmail = $pdo->prepare('SELECT usr_id FROM usuarios WHERE email = ? AND usr_id <> ?');
            $stmtEmail->execute([$email, $usuarioId]);

            if ($stmtEmail->fetch()) {
                $erro = 'Este e-mail já está em uso.';
            } else {
                $stmtAtualizar = $pdo->prepare('UPDATE usuarios SET nome = ?, email = ?, forma_pagamento_preferida = ? WHERE usr_id = ?');
                $stmtAtualizar->execute([$nome, $email, $formaPagamento, $usuarioId]);
                $_SESSION['usr_nome'] = $nome;
                $sucesso = 'Dados da conta atualizados.';
            }
        }
    } elseif ($acao === 'atualizar_senha') {
        $senhaAtual = $_POST['senha_atual'] ?? '';
        $novaSenha = $_POST['nova_senha'] ?? '';
        $confirmarSenha = $_POST['confirmar_senha'] ?? '';

        if (!password_verify($senhaAtual, $usuario['senha'])) {
            $erro = 'A senha atual não confere.';
        } elseif (strlen($novaSenha) < 6) {
            $erro = 'A nova senha deve ter pelo menos 6 caracteres.';
        } elseif ($novaSenha !== $confirmarSenha) {
            $erro = 'A confirmação da nova senha não confere.';
        } else {
            $senhaHash = password_hash($novaSenha, PASSWORD_DEFAULT);
            $stmtSenha = $pdo->prepare('UPDATE usuarios SET senha = ? WHERE usr_id = ?');
            $stmtSenha->execute([$senhaHash, $usuarioId]);
            $sucesso = 'Senha alterada com sucesso.';
            $mostrarFormularioSenha = false;
        }
    } else {
        $erro = 'Ação inválida.';
    }

    $stmtUsuario->execute([$usuarioId]);
    $usuario = $stmtUsuario->fetch();
}

$stmtPedidos = $pdo->prepare(
    'SELECT p.pedido_id, p.data_pedido, p.status, p.forma_pagamento, p.valor_total,
            i.quantidade, i.preco_unitario, j.titulo
     FROM pedidos p
     LEFT JOIN itens_pedido i ON i.pedido_id = p.pedido_id
     LEFT JOIN jogos j ON j.jogo_id = i.jogo_id
     WHERE p.usr_id = ?
     ORDER BY p.data_pedido DESC, p.pedido_id DESC, i.item_id'
);
$stmtPedidos->execute([$usuarioId]);
$pedidos = [];

foreach ($stmtPedidos->fetchAll() as $linha) {
    $pedidoId = (int) $linha['pedido_id'];
    if (!isset($pedidos[$pedidoId])) {
        $pedidos[$pedidoId] = [
            'id' => $pedidoId,
            'data' => $linha['data_pedido'],
            'status' => $linha['status'],
            'pagamento' => $linha['forma_pagamento'],
            'total' => $linha['valor_total'],
            'itens' => []
        ];
    }

    if ($linha['titulo'] !== null) {
        $pedidos[$pedidoId]['itens'][] = [
            'titulo' => $linha['titulo'],
            'quantidade' => (int) $linha['quantidade'],
            'preco' => (float) $linha['preco_unitario']
        ];
    }
}

$statusPedidos = [
    'pendente' => 'Pendente',
    'pago' => 'Pago',
    'enviado' => 'Enviado',
    'cancelado' => 'Cancelado'
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meu perfil | Louja</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="css/perfil.css">
    <?php require __DIR__ . '/tema-head.php'; ?>
</head>
<body class="perfil-page">
<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>
    <nav>
        <a href="jogos.php">Jogos</a>
        <a href="carrinho.php">Carrinho (<?= array_sum($_SESSION['carrinho'] ?? []) ?>)</a>
        <a href="perfil.php" aria-current="page">Meu perfil</a>
        <?php if (($_SESSION['usr_perfil'] ?? '') === 'admin'): ?>
            <a href="admin/index.php">Admin</a>
        <?php endif; ?>
        <a href="logout.php">Sair</a>
    </nav>
</header>

<main class="perfil-wrap">
    <div class="perfil-cabecalho">
        <div>
            <p class="perfil-sobretitulo">CONTA LOUJA</p>
            <h1>Meu perfil</h1>
            <p>Gerencie seus dados e acompanhe seus pedidos.</p>
        </div>
        <div class="perfil-cabecalho-acoes">
            <button class="perfil-tema-botao" type="button" data-alternar-tema aria-pressed="false">Ativar tema escuro</button>
            <a class="perfil-voltar" href="jogos.php">Voltar à loja</a>
        </div>
    </div>

    <?php if ($erro !== ''): ?>
        <p class="perfil-mensagem perfil-erro" role="alert"><?= htmlspecialchars($erro, ENT_QUOTES, 'UTF-8') ?></p>
    <?php elseif ($sucesso !== ''): ?>
        <p class="perfil-mensagem perfil-sucesso" role="status"><?= htmlspecialchars($sucesso, ENT_QUOTES, 'UTF-8') ?></p>
    <?php endif; ?>

    <div class="perfil-grade">
        <section class="perfil-painel" aria-labelledby="titulo-dados">
            <div class="perfil-painel-cabecalho">
                <div>
                    <h2 id="titulo-dados">Dados da conta</h2>
                    <p>Atualize seu nome, e-mail e forma de pagamento preferida.</p>
                </div>
            </div>
            <form method="post" class="perfil-form">
                <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_perfil'], ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="acao" value="atualizar_dados">
                <label for="nome">Nome</label>
                <input id="nome" name="nome" type="text" maxlength="100" autocomplete="name" value="<?= htmlspecialchars($usuario['nome'], ENT_QUOTES, 'UTF-8') ?>" required>

                <label for="email">E-mail</label>
                <input id="email" name="email" type="email" maxlength="100" autocomplete="email" value="<?= htmlspecialchars($usuario['email'], ENT_QUOTES, 'UTF-8') ?>" required>

                <fieldset class="perfil-pagamentos">
                    <legend>Forma de pagamento preferida</legend>
                    <?php foreach ($metodosPagamento as $valor => $rotulo): ?>
                        <label>
                            <input type="radio" name="forma_pagamento_preferida" value="<?= htmlspecialchars($valor, ENT_QUOTES, 'UTF-8') ?>" <?= $usuario['forma_pagamento_preferida'] === $valor ? 'checked' : '' ?> required>
                            <span><?= htmlspecialchars($rotulo, ENT_QUOTES, 'UTF-8') ?></span>
                        </label>
                    <?php endforeach; ?>
                </fieldset>

                <label for="senha-atual-dados">Senha atual para confirmar</label>
                <input id="senha-atual-dados" name="senha_atual" type="password" autocomplete="current-password" required>
                <button class="botao" type="submit">Salvar dados</button>
            </form>
            <p class="perfil-nota">A loja guarda apenas sua forma de pagamento preferida. Dados de cartão ou conta não são armazenados.</p>
        </section>

        <section class="perfil-painel perfil-painel-senha" aria-labelledby="botao-senha">
            <form method="post" class="perfil-form perfil-form-senha" id="form-senha">
                <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_perfil'], ENT_QUOTES, 'UTF-8') ?>">
                <input type="hidden" name="acao" value="atualizar_senha">
                <div class="perfil-senha-campos" id="campos-senha" <?= $mostrarFormularioSenha ? '' : 'hidden' ?>>
                    <label for="senha-atual-senha">Senha atual</label>
                    <input id="senha-atual-senha" name="senha_atual" type="password" autocomplete="current-password" required>

                    <label for="nova-senha">Nova senha</label>
                    <input id="nova-senha" name="nova_senha" type="password" minlength="6" autocomplete="new-password" required>

                    <label for="confirmar-senha">Confirmar nova senha</label>
                    <input id="confirmar-senha" name="confirmar_senha" type="password" minlength="6" autocomplete="new-password" required>
                </div>
                <button class="botao" id="botao-senha" type="<?= $mostrarFormularioSenha ? 'submit' : 'button' ?>">
                    <?= $mostrarFormularioSenha ? 'Salvar nova senha' : 'Alterar senha' ?>
                </button>
            </form>
        </section>
    </div>

    <section class="perfil-historico" aria-labelledby="titulo-historico">
        <div class="perfil-painel-cabecalho">
            <div>
                <h2 id="titulo-historico">Histórico de compras</h2>
                <p><?= count($pedidos) ?> <?= count($pedidos) === 1 ? 'pedido' : 'pedidos' ?> na sua conta</p>
            </div>
        </div>

        <?php if (!$pedidos): ?>
            <p class="perfil-sem-pedidos">Você ainda não tem compras. <a href="jogos.php">Explorar jogos</a></p>
        <?php else: ?>
            <div class="perfil-pedidos">
                <?php foreach ($pedidos as $pedido): ?>
                    <article class="perfil-pedido">
                        <div class="perfil-pedido-resumo">
                            <div>
                                <h3>Pedido #<?= $pedido['id'] ?></h3>
                                <p><?= htmlspecialchars(date('d/m/Y \à\s H:i', strtotime($pedido['data'])), ENT_QUOTES, 'UTF-8') ?></p>
                            </div>
                            <div class="perfil-pedido-total">
                                <span class="perfil-status status-<?= htmlspecialchars($pedido['status'], ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($statusPedidos[$pedido['status']] ?? ucfirst($pedido['status']), ENT_QUOTES, 'UTF-8') ?></span>
                                <strong>R$ <?= number_format((float) $pedido['total'], 2, ',', '.') ?></strong>
                            </div>
                        </div>
                        <ul>
                            <?php foreach ($pedido['itens'] as $item): ?>
                                <li>
                                    <span><?= htmlspecialchars($item['titulo'], ENT_QUOTES, 'UTF-8') ?> <small>× <?= $item['quantidade'] ?></small></span>
                                    <span>R$ <?= number_format($item['preco'] * $item['quantidade'], 2, ',', '.') ?></span>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                        <p class="perfil-pagamento-resumo">Pagamento: <?= htmlspecialchars($metodosPagamento[$pedido['pagamento']] ?? 'Não informado', ENT_QUOTES, 'UTF-8') ?></p>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
</main>
<script>
const botaoSenha = document.getElementById('botao-senha');
const camposSenha = document.getElementById('campos-senha');

botaoSenha.addEventListener('click', () => {
    if (!camposSenha.hidden) {
        return;
    }

    camposSenha.hidden = false;
    botaoSenha.type = 'submit';
    botaoSenha.textContent = 'Salvar nova senha';
    document.getElementById('senha-atual-senha').focus();
});
</script>
</body>
</html>