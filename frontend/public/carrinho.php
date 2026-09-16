<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';

$carrinho = $_SESSION['carrinho'] ?? [];
$produtos = [];
$total = 0;

foreach ($carrinho as $id => $quantidade) {
    $stmt = $pdo->prepare("SELECT * FROM jogos WHERE jogo_id = ?");
    $stmt->execute([$id]);
    $produto = $stmt->fetch();

    if ($produto) {
        $produto['quantidade'] = $quantidade;
        $produto['subtotal'] = $produto['preco'] * $quantidade;
        $total += $produto['subtotal'];
        $produtos[] = $produto;
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrinho - Louja</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <a href="index.php" class="logo">LOUJA</a>
    <nav>
        <a href="index.php">Jogos</a>
        <a href="carrinho.php">Carrinho</a>
        <?php if (isset($_SESSION['usr_id'])): ?>
            <a href="logout.php">Sair</a>
        <?php else: ?>
            <a href="login.php">Entrar</a>
        <?php endif; ?>
    </nav>
</header>

<div class="pagina">
    <h1>Meu carrinho</h1>

    <?php if (empty($produtos)): ?>
        <p>Seu carrinho está vazio.</p>
    <?php else: ?>
        <?php foreach ($produtos as $produto): ?>
            <div class="item-carrinho">
                <img src="<?= htmlspecialchars($produto['img_url']) ?>" alt="">
                <div>
                    <h2><?= htmlspecialchars($produto['titulo']) ?></h2>
                    <p>Quantidade: <?= $produto['quantidade'] ?></p>
                    <p>R$ <?= number_format($produto['subtotal'], 2, ',', '.') ?></p>
                    <a href="remover_carrinho.php?id=<?= $produto['jogo_id'] ?>">Remover</a>
                </div>
            </div>
        <?php endforeach; ?>

        <h2>Total: R$ <?= number_format($total, 2, ',', '.') ?></h2>
    <?php endif; ?>

    <a class="botao" href="index.php">Continuar comprando</a>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
gsap.from(".pagina", { opacity: 0, y: 20, duration: 0.6 });
</script>
</body>
</html>
