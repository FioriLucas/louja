<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$produtos = $pdo->query(
    "SELECT jogos.*,
            COALESCE((
                SELECT GROUP_CONCAT(jc.nome SEPARATOR ', ')
                FROM jogo_categorias AS jcat
                JOIN categorias AS jc ON jc.categoria_id = jcat.categoria_id
                WHERE jcat.jogo_id = jogos.jogo_id
            ), categorias.nome, 'Sem categoria') AS categoria,
            COALESCE((
                SELECT GROUP_CONCAT(jp.plataforma SEPARATOR ', ')
                FROM jogo_plataformas AS jp
                WHERE jp.jogo_id = jogos.jogo_id
            ), jogos.plataforma) AS plataformas
     FROM jogos
     LEFT JOIN categorias ON jogos.categoria_id = categorias.categoria_id
     ORDER BY jogos.jogo_id DESC"
)->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Admin - Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<header>
    <a href="../index.php" class="logo">
        <img src="../../../docs/logolouja.png" alt="Louja">
    </a>
    <nav>
        <span>Ol&aacute;, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>
        <a href="../index.php">Voltar para a loja</a>
        <a href="../logout.php">Sair</a>
    </nav>
</header>

<main class="admin">
    <div class="admin-cabecalho">
        <div>
            <h1>Painel administrativo</h1>
            <p>Gerencie os produtos da loja.</p>
        </div>
        <a class="botao" href="adicionar.php">+ Adicionar produto</a>
    </div>

    <div class="admin-catalogo">
        <?php foreach ($produtos as $produto): ?>
            <article class="jogo-card admin-card">
                <div class="jogo-card-imagem">
                    <img src="<?= htmlspecialchars($produto['img_url'] ?? '') ?>"
                         alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>"
                         loading="lazy">
                    <span class="jogo-categoria">
                        <?= htmlspecialchars($produto['categoria'] ?? 'Sem categoria') ?>
                    </span>
                </div>
                <div class="jogo-card-info">
                    <h3><?= htmlspecialchars($produto['titulo']) ?></h3>
                    <span class="admin-card-meta">
                        <?= htmlspecialchars($produto['plataformas']) ?>
                    </span>
                    <strong>R$ <?= number_format($produto['preco'], 2, ',', '.') ?></strong>
                </div>
                <div class="admin-acoes">
                    <a class="botao" href="editar.php?id=<?= (int) $produto['jogo_id'] ?>">Editar</a>
                    <a class="botao admin-excluir"
                       href="excluir.php?id=<?= (int) $produto['jogo_id'] ?>"
                       onclick="return confirm('Excluir este produto?')">Excluir</a>
                </div>
            </article>
        <?php endforeach; ?>
    </div>

    <?php if (empty($produtos)): ?>
        <div class="catalogo-vazio">Nenhum produto cadastrado.</div>
    <?php endif; ?>
</main>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
gsap.from(".admin", { opacity: 0, y: 25, duration: 0.6 });
</script>
</body>
</html>
