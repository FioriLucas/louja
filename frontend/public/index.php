<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';

$conexao = new Conexao();
$pdo = $conexao->conectar();

$sql = "SELECT jogos.*, categorias.nome AS categoria
        FROM jogos
        JOIN categorias ON jogos.categoria_id = categorias.categoria_id
        WHERE jogos.ativo = 1
        ORDER BY jogos.jogo_id DESC";

$produtos = $pdo->query($sql)->fetchAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Louja - Game Store</title>
    <link rel="stylesheet" href="css/style.css">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>
</head>
<body>

<header>
    <a href="index.php" class="logo"><img src="logolouja.png" alt="Louja"></a>

    <nav>
        <a href="index.php">Jogos</a>
        <a href="carrinho.php">Carrinho (<?= array_sum($_SESSION['carrinho'] ?? []) ?>)</a>

        <?php if (isset($_SESSION['usr_id'])): ?>
            <span>Olá, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>
            <?php if ($_SESSION['usr_perfil'] === 'admin'): ?>
                <a href="admin/index.php">Admin</a>
            <?php endif; ?>
            <a href="logout.php">Sair</a>
        <?php else: ?>
            <a href="login.php">Entrar</a>
        <?php endif; ?>
    </nav>
</header>

<main class="loja">
    <div class="produtos">

        <?php foreach ($produtos as $produto): ?>
            <section class="produto">
                <div class="imagem">
                    <img src="<?= htmlspecialchars($produto['img_url']) ?>"
                         alt="<?= htmlspecialchars($produto['titulo']) ?>">
                </div>

                <div class="info">
                    <p class="categoria"><?= htmlspecialchars($produto['categoria']) ?></p>
                    <h2><?= htmlspecialchars($produto['titulo']) ?></h2>
                    <p class="plataforma"><?= htmlspecialchars($produto['plataforma']) ?></p>
                    <p class="preco">R$ <?= number_format($produto['preco'], 2, ',', '.') ?></p>

                    <a class="botao" href="adicionar_carrinho.php?id=<?= $produto['jogo_id'] ?>">
                        Adicionar ao carrinho
                    </a>
                </div>
            </section>
        <?php endforeach; ?>

    </div>
</main>

<script src="js/animacoes.js"></script>
</body>
</html>