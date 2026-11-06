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

$stmtUsuario = $pdo->prepare('SELECT usr_id, nome, email, senha, forma_pagamento_preferida, foto_perfil FROM usuarios WHERE usr_id = ?');
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
    } elseif ($acao === 'atualizar_foto') {
        $arquivo = $_FILES['foto_perfil'] ?? null;

        if (!is_array($arquivo) || ($arquivo['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            $erro = 'Selecione uma imagem para enviar.';
        } elseif (($arquivo['size'] ?? 0) > 3 * 1024 * 1024) {
            $erro = 'A imagem deve ter no máximo 3 MB.';
        } elseif (!is_uploaded_file($arquivo['tmp_name'] ?? '')) {
            $erro = 'Não foi possível validar o arquivo enviado.';
        } else {
            $tiposImagem = [
                'image/jpeg' => 'jpg',
                'image/png' => 'png',
                'image/webp' => 'webp'
            ];
            $finfo = new finfo(FILEINFO_MIME_TYPE);
            $tipoImagem = $finfo->file($arquivo['tmp_name']);
            $dadosImagem = getimagesize($arquivo['tmp_name']);

            if (!isset($tiposImagem[$tipoImagem]) || $dadosImagem === false) {
                $erro = 'Escolha uma imagem válida nos formatos JPG, PNG ou WebP.';
            } else {
                $nomeArquivo = bin2hex(random_bytes(24)) . '.' . $tiposImagem[$tipoImagem];
                $diretorioFotos = __DIR__ . '/uploads/perfil';
                $caminhoDestino = $diretorioFotos . DIRECTORY_SEPARATOR . $nomeArquivo;

                if (!is_dir($diretorioFotos) && !mkdir($diretorioFotos, 0755, true)) {
                    $erro = 'Não foi possível preparar o armazenamento da imagem.';
                } elseif (!move_uploaded_file($arquivo['tmp_name'], $caminhoDestino)) {
                    $erro = 'Não foi possível salvar a imagem enviada.';
                } else {
                    $fotoPerfilAnterior = $usuario['foto_perfil'];
                    $caminhoRelativo = 'uploads/perfil/' . $nomeArquivo;
                    $stmtFoto = $pdo->prepare('UPDATE usuarios SET foto_perfil = ? WHERE usr_id = ?');
                    $stmtFoto->execute([$caminhoRelativo, $usuarioId]);
                    $_SESSION['usr_foto_perfil'] = $caminhoRelativo;
                    $sucesso = 'Foto de perfil atualizada.';

                    if (is_string($fotoPerfilAnterior) && preg_match('~^uploads/perfil/[a-f0-9]{48}\.(?:jpg|png|webp)$~', $fotoPerfilAnterior)) {
                        $caminhoAnterior = __DIR__ . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $fotoPerfilAnterior);
                        if (is_file($caminhoAnterior)) {
                            unlink($caminhoAnterior);
                        }
                    }
                }
            }
        }
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
    <link rel="stylesheet" href="css/perfil.css?v=20261106-1">
    <?php require __DIR__ . '/tema-head.php'; ?>
</head>
<body class="perfil-page">
<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>
    <nav>
        <a href="jogos.php">Jogos</a>
        <?php require __DIR__ . '/perfil-avatar.php'; ?>
        <?php if (($_SESSION['usr_perfil'] ?? '') === 'admin'): ?>
            <a href="admin/index.php">Admin</a>
        <?php endif; ?>
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
            <a class="perfil-voltar" href="jogos.php">Voltar à loja</a>
            <a class="perfil-sair" href="logout.php">Sair da conta</a>
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
            <div class="perfil-foto">
                <div class="perfil-foto-avatar">
                    <?php if (!empty($usuario['foto_perfil'])): ?>
                        <img src="<?= htmlspecialchars($usuario['foto_perfil'], ENT_QUOTES, 'UTF-8') ?>" alt="Foto de perfil atual">
                    <?php else: ?>
                        <svg class="perfil-foto-padrao" viewBox="0 0 48 48" role="img" aria-label="Avatar padrão">
                            <circle class="perfil-foto-fundo" cx="24" cy="24" r="24"></circle>
                            <circle class="perfil-foto-cabeca" cx="24" cy="17" r="8"></circle>
                            <path class="perfil-foto-corpo" d="M8 43c1.8-9 7.7-13.5 16-13.5S38.2 34 40 43"></path>
                        </svg>
                    <?php endif; ?>
                </div>
                <form method="post" class="perfil-foto-form" enctype="multipart/form-data">
                    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_perfil'], ENT_QUOTES, 'UTF-8') ?>">
                    <input type="hidden" name="acao" value="atualizar_foto">
                    <label for="foto-perfil">Foto de perfil</label>
                    <input id="foto-perfil" name="foto_perfil" type="file" accept="image/jpeg,image/png,image/webp" required>
                    <small>JPG, PNG ou WebP; até 3 MB.</small>
                    <button class="botao" type="submit">Salvar foto</button>
                </form>
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
                                    <span><?= htmlspecialchars($item['titulo'], ENT_QUOTES, 'UTF-8') ?></span>
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