<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['limpar_carrinho'])) {
    $_SESSION['carrinho'] = [];
    header('Location: carrinho.php');
    exit;
}

require_once __DIR__ . '/../../backend/config/conexao.php';
$conexao = new Conexao();
$pdo = $conexao->conectar();

$carrinho = [];
foreach (array_keys($_SESSION['carrinho'] ?? []) as $id) {
    $id = (int) $id;
    if ($id > 0) {
        $carrinho[$id] = 1;
    }
}
$_SESSION['carrinho'] = $carrinho;
$produtos = [];
$total = 0;

foreach ($carrinho as $id => $_) {
    $stmt = $pdo->prepare("SELECT * FROM jogos WHERE jogo_id = ?");
    $stmt->execute([$id]);
    $produto = $stmt->fetch();

    if ($produto) {
        $produto['subtotal'] = (float) $produto['preco'];
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
    <?php require __DIR__ . '/tema-head.php'; ?>
</head>
<body class="pagina-carrinho">

<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>
    <nav>
        <a href="jogos.php">Jogos</a>
        <?php if (isset($_SESSION['usr_id'])): ?>
            <a href="perfil.php">Meu perfil</a>
            <a href="logout.php">Sair</a>
        <?php else: ?>
            <a href="login.php">Entrar</a>
        <?php endif; ?>
    </nav>
</header>

<main class="pagina pagina-carrinho-conteudo">
    <div class="carrinho-cabecalho">
        <div>
            <span class="carrinho-sobretitulo">SUA SELEÇÃO</span>
            <h1>Meu carrinho</h1>
            <p>Seus jogos digitais, reunidos em um só lugar.</p>
        </div>
        <?php if (!empty($produtos)): ?>
            <form action="carrinho.php" method="post">
                <button class="carrinho-botao-limpar" type="submit" name="limpar_carrinho" value="1">
                    Limpar carrinho <span aria-hidden="true">❌</span> 
                </button>
            </form>
        <?php endif; ?>
    </div>

    <?php if (empty($produtos)): ?>
        <section class="carrinho-vazio">
            <span class="carrinho-vazio-icone" aria-hidden="true">
                <svg viewBox="0 0 24 24" focusable="false">
                    <path d="M3 4h2l2.2 11.2a2 2 0 0 0 2 1.6h8.4a2 2 0 0 0 1.9-1.4L21 8H6"></path>
                    <circle cx="10" cy="20" r="1"></circle>
                    <circle cx="18" cy="20" r="1"></circle>
                </svg>
            </span>
            <h2>Seu carrinho está vazio</h2>
            <p>Explore a loja e encontre seu próximo jogo favorito.</p>
            <a class="botao carrinho-botao-principal" href="jogos.php">Explorar jogos</a>
        </section>
    <?php else: ?>
        <div class="carrinho-lista">
            <?php foreach ($produtos as $produto): ?>
                <article class="item-carrinho">
                    <img src="<?= htmlspecialchars($produto['img_url']) ?>" alt="Capa de <?= htmlspecialchars($produto['titulo'], ENT_QUOTES, 'UTF-8') ?>">
                    <div class="item-carrinho-info">
                        <h2><?= htmlspecialchars($produto['titulo']) ?></h2>
                        <p class="item-carrinho-preco">R$ <?= number_format($produto['subtotal'], 2, ',', '.') ?></p>
                        <div class="item-carrinho-acoes">
                            <a class="item-carrinho-acao item-carrinho-remover-tudo" href="remover_carrinho.php?id=<?= (int) $produto['jogo_id'] ?>" aria-label="Remover <?= htmlspecialchars($produto['titulo'], ENT_QUOTES, 'UTF-8') ?> do carrinho" title="Remover produto">
                                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                                    <path d="M4 7h16M10 11v6m4-6v6M5 7l1 14h12l1-14M9 7V4h6v3"></path>
                                </svg>
                                <span>Remover</span>
                            </a>
                        </div>
                    </div>
                    <strong class="item-carrinho-subtotal">R$ <?= number_format($produto['subtotal'], 2, ',', '.') ?></strong>
                </article>
            <?php endforeach; ?>
        </div>

        <section class="carrinho-resumo" aria-label="Resumo da compra">
            <div>
                <span class="carrinho-resumo-legenda">Total da compra</span>
                <strong>R$ <?= number_format($total, 2, ',', '.') ?></strong>
            </div>
            <div class="carrinho-resumo-acoes">
                <a class="carrinho-continuar" href="jogos.php">Continuar comprando</a>
                <a class="botao carrinho-botao-principal" href="checkout.php">
                    Finalizar compra
                    <span aria-hidden="true">&rsaquo;</span>
                </a>
            </div>
        </section>
    <?php endif; ?>
</main>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
gsap.from(".pagina", { opacity: 0, y: 20, duration: 0.6 });
</script>
</body>
</html>
