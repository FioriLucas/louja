<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$produtos = $pdo->query("SELECT * FROM jogos ORDER BY jogo_id DESC")->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Admin - Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<div class="admin">
    <h1>Painel administrativo</h1>
    <p>Olá, <?= htmlspecialchars($_SESSION['usr_nome']) ?></p>

    <a class="botao" href="adicionar.php">+ Adicionar produto</a>
    <a href="../index.php">Voltar para a loja</a>

    <div class="tabela">
        <?php foreach ($produtos as $produto): ?>
            <div class="linha">
                <strong><?= htmlspecialchars($produto['titulo']) ?></strong>
                <span>R$ <?= number_format($produto['preco'], 2, ',', '.') ?></span>
                <a href="editar.php?id=<?= $produto['jogo_id'] ?>">Editar</a>
                <a href="excluir.php?id=<?= $produto['jogo_id'] ?>"
                   onclick="return confirm('Excluir este produto?')">Excluir</a>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
gsap.from(".admin", { opacity: 0, y: 25, duration: 0.6 });
</script>
</body>
</html>
