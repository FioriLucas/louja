<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';

$conexao = new Conexao();
$pdo = $conexao->conectar();

$colunaDestaqueExiste = (bool) $pdo->query("SHOW COLUMNS FROM jogos LIKE 'destaque_carrossel'")->fetch();

if ($colunaDestaqueExiste) {
    // Busca os jogos marcados para aparecer no carrossel.
    $sqlDestaques = "SELECT jogos.*, categorias.nome AS categoria
            FROM jogos
            JOIN categorias ON jogos.categoria_id = categorias.categoria_id
            WHERE jogos.ativo = 1
              AND jogos.destaque_carrossel = 1
            ORDER BY jogos.jogo_id DESC";

    $produtos = $pdo->query($sqlDestaques)->fetchAll();

    // Busca os jogos que não estão no carrossel.
    $sqlCatalogo = "SELECT jogos.*, categorias.nome AS categoria
            FROM jogos
            JOIN categorias ON jogos.categoria_id = categorias.categoria_id
            WHERE jogos.ativo = 1
              AND jogos.destaque_carrossel = 0
            ORDER BY jogos.jogo_id DESC";

    $catalogo = $pdo->query($sqlCatalogo)->fetchAll();
} else {
    $sqlBase = "SELECT jogos.*, categorias.nome AS categoria
            FROM jogos
            JOIN categorias ON jogos.categoria_id = categorias.categoria_id
            WHERE jogos.ativo = 1
            ORDER BY jogos.jogo_id DESC";

    $todosJogos = $pdo->query($sqlBase)->fetchAll();

    $produtos = array_slice($todosJogos, 0, 5);
    $catalogo = array_slice($todosJogos, 5);
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Louja - Game Store</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>

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

    <section class="hero-carousel" aria-label="Destaques da loja">

        <div class="slides">

            <?php foreach ($produtos as $i => $produto): ?>

                <article class="slide <?= $i === 0 ? 'ativo' : '' ?>">

                    <img class="slide-bg"
                         src="<?= htmlspecialchars($produto['img_url']) ?>"
                         alt=""
                         aria-hidden="true">

                    <div class="slide-overlay"></div>

                    <div class="slide-content">

                        <p class="categoria">
                            <?= htmlspecialchars($produto['categoria']) ?>
                        </p>

                        <h1>
                            <?= htmlspecialchars($produto['titulo']) ?>
                        </h1>

                        <p class="plataforma">
                            <?= htmlspecialchars($produto['plataforma']) ?>
                        </p>

                        <p class="preco">
                            R$ <?= number_format($produto['preco'], 2, ',', '.') ?>
                        </p>

                        <a class="botao"
                           href="adicionar_carrinho.php?id=<?= $produto['jogo_id'] ?>">
                            Adicionar ao carrinho <span>›</span>
                        </a>

                    </div>

                </article>

            <?php endforeach; ?>

        </div>

        <?php if (count($produtos) > 1): ?>

            <button class="seta seta-esquerda"
                    type="button"
                    aria-label="Jogo anterior">
                ‹
            </button>

            <button class="seta seta-direita"
                    type="button"
                    aria-label="Próximo jogo">
                ›
            </button>

            <div class="indicadores" aria-label="Selecionar jogo">

                <?php foreach ($produtos as $i => $produto): ?>

                    <button class="indicador <?= $i === 0 ? 'ativo' : '' ?>"
                            type="button"
                            aria-label="Ir para <?= htmlspecialchars($produto['titulo']) ?>"
                            aria-current="<?= $i === 0 ? 'true' : 'false' ?>">
                    </button>

                <?php endforeach; ?>

            </div>

        <?php endif; ?>

    </section>

    <section class="biblioteca" id="biblioteca">

        <div class="biblioteca-cabecalho">

            <div>
                <h2>Explore nossos jogos</h2>
                <p>Confira outros títulos disponíveis na Louja.</p>
            </div>

            <div class="biblioteca-controles">

                <button class="catalogo-seta catalogo-anterior"
                        type="button"
                        aria-label="Jogos anteriores">
                    ‹
                </button>

                <button class="catalogo-seta catalogo-proximo"
                        type="button"
                        aria-label="Próximos jogos">
                    ›
                </button>

            </div>

        </div>

        <div class="catalogo-viewport">

            <div class="catalogo-track">

                <?php foreach ($catalogo as $produto): ?>

                    <a class="jogo-card"
                       href="jogo.php?id=<?= $produto['jogo_id'] ?>">

                        <div class="jogo-card-imagem">

                            <img src="<?= htmlspecialchars($produto['img_url']) ?>"
                                 alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>"
                                 loading="lazy">

                            <span class="jogo-categoria">
                                <?= htmlspecialchars($produto['categoria']) ?>
                            </span>

                        </div>

                        <div class="jogo-card-info">

                            <h3>
                                <?= htmlspecialchars($produto['titulo']) ?>
                            </h3>

                            <span class="jogo-plataforma">
                                <?= htmlspecialchars($produto['plataforma']) ?>
                            </span>

                            <strong>
                                R$ <?= number_format($produto['preco'], 2, ',', '.') ?>
                            </strong>

                        </div>

                    </a>

                <?php endforeach; ?>

            </div>

        </div>

        <?php if (empty($catalogo)): ?>

            <div class="catalogo-vazio">
                Nenhum jogo disponível no catálogo.
            </div>

        <?php endif; ?>

    </section>

</main>

<script src="js/animacoes.js"></script>

</body>
</html>