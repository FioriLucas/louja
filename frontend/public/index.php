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
    $sqlDestaques = "SELECT jogos.*, categorias.nome AS categoria
            FROM jogos
            JOIN categorias ON jogos.categoria_id = categorias.categoria_id
            WHERE jogos.ativo = 1
              AND jogos.destaque_carrossel = 1
            ORDER BY jogos.jogo_id DESC";

    $produtos = $pdo->query($sqlDestaques)->fetchAll();

    $sqlCatalogo = "SELECT jogos.*, categorias.nome AS categoria
            FROM jogos
            JOIN categorias ON jogos.categoria_id = categorias.categoria_id
            WHERE jogos.ativo = 1
              AND jogos.destaque_carrossel = 0
            ORDER BY RAND()
            LIMIT 27";

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
    shuffle($catalogo);
}

$sqlVitrine = "SELECT jogos.*, categorias.nome AS categoria
        FROM jogos
        JOIN categorias ON jogos.categoria_id = categorias.categoria_id
        WHERE jogos.ativo = 1
        ORDER BY jogos.titulo";
$jogosVitrine = $pdo->query($sqlVitrine)->fetchAll();
$categoriasVitrine = $pdo->query("SELECT nome FROM categorias
        ORDER BY CASE nome WHEN 'Ação' THEN 0 WHEN 'Esportes' THEN 1 ELSE 2 END, nome")
    ->fetchAll(PDO::FETCH_COLUMN);

$idsCatalogoPesquisa = array_fill_keys(array_column($catalogo, 'jogo_id'), true);
$jogosCatalogoPesquisa = $catalogo;
foreach ($jogosVitrine as $jogoVitrine) {
    if (!isset($idsCatalogoPesquisa[$jogoVitrine['jogo_id']])) {
        $jogosCatalogoPesquisa[] = $jogoVitrine;
    }
}

$jogosPorCategoria = [];
foreach ($jogosVitrine as $jogoVitrine) {
    $jogosPorCategoria[$jogoVitrine['categoria']][] = $jogoVitrine;
}

$ofertasVitrine = $jogosVitrine;
usort($ofertasVitrine, function ($jogoA, $jogoB) {
    return (float) $jogoA['preco'] <=> (float) $jogoB['preco'];
});

$secoesVitrine = ['Ofertas' => array_slice($ofertasVitrine, 0, 8)];
foreach ($categoriasVitrine as $categoriaVitrine) {
    if (!empty($jogosPorCategoria[$categoriaVitrine])) {
        $secoesVitrine[$categoriaVitrine] = $jogosPorCategoria[$categoriaVitrine];
    }
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
        <form class="busca-header" id="catalogo-busca-form" role="search" aria-label="Pesquisar jogos">
            <button type="submit" aria-label="Abrir pesquisa" aria-expanded="false" aria-controls="catalogo-busca">
                <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                    <circle cx="10.8" cy="10.8" r="6.8"></circle>
                    <path d="m16 16 5 5"></path>
                </svg>
            </button>
            <input id="catalogo-busca" type="search" placeholder="Buscar jogos..." aria-label="Buscar jogos pelo título">
        </form>
        <a href="jogos.php">Jogos</a>
        <a href="carrinho.php">Carrinho (<?= array_sum($_SESSION['carrinho'] ?? []) ?>)</a>

        <?php if (isset($_SESSION['usr_id'])): ?>
            <span>Ol&aacute;, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>

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
                        <p class="categoria"><?= htmlspecialchars($produto['categoria']) ?></p>
                        <h1><?= htmlspecialchars($produto['titulo']) ?></h1>
                        <p class="plataforma"><?= htmlspecialchars($produto['plataforma']) ?></p>
                        <p class="preco">R$ <?= number_format($produto['preco'], 2, ',', '.') ?></p>
                        <a class="botao" href="adicionar_carrinho.php?id=<?= $produto['jogo_id'] ?>">
                            Adicionar ao carrinho <span>&rsaquo;</span>
                        </a>
                    </div>
                </article>
            <?php endforeach; ?>
        </div>

        <?php if (count($produtos) > 1): ?>
            <button class="seta seta-esquerda" type="button" aria-label="Jogo anterior">&lsaquo;</button>
            <button class="seta seta-direita" type="button" aria-label="Pr&oacute;ximo jogo">&rsaquo;</button>
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
                <p>Confira os t&iacute;tulos dispon&iacute;veis na Louja.</p>
            </div>
            <div class="biblioteca-controles">
                <button class="catalogo-seta catalogo-anterior" type="button" aria-label="Jogos anteriores">&lsaquo;</button>
                <button class="catalogo-seta catalogo-proximo" type="button" aria-label="Pr&oacute;ximos jogos">&rsaquo;</button>
            </div>
        </div>

        <p class="catalogo-resultado" id="catalogo-resultado" aria-live="polite"></p>
        <div class="catalogo-viewport">
            <div class="catalogo-track">
                <?php foreach ($jogosCatalogoPesquisa as $indiceCatalogo => $produto): ?>
                    <a class="jogo-card"
                       href="jogo.php?id=<?= $produto['jogo_id'] ?>"
                       data-catalogo-inicial="<?= $indiceCatalogo < count($catalogo) ? 'true' : 'false' ?>"
                       style="<?= $indiceCatalogo >= count($catalogo) ? 'display: none;' : '' ?>">
                        <div class="jogo-card-imagem">
                            <img src="<?= htmlspecialchars($produto['img_url']) ?>"
                                 alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>"
                                 loading="lazy">
                            <span class="jogo-categoria"><?= htmlspecialchars($produto['categoria']) ?></span>
                        </div>
                        <div class="jogo-card-info">
                            <h3><?= htmlspecialchars($produto['titulo']) ?></h3>
                            <span class="jogo-plataforma"><?= htmlspecialchars($produto['plataforma']) ?></span>
                            <strong>R$ <?= number_format($produto['preco'], 2, ',', '.') ?></strong>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="catalogo-vazio" id="catalogo-vazio" <?= empty($catalogo) ? '' : 'hidden' ?>>
            Nenhum jogo encontrado com esse nome.
        </div>
    </section>

    <?php foreach ($secoesVitrine as $nomeSecao => $jogosSecao): ?>
        <section class="vitrine-jogos" data-vitrine>
            <div class="vitrine-cabecalho">
                <div>
                    <h2><?= htmlspecialchars($nomeSecao) ?></h2>
                    <?php if ($nomeSecao === 'Ofertas'): ?>
                        <p>Uma sele&ccedil;&atilde;o dos menores pre&ccedil;os da loja.</p>
                    <?php endif; ?>
                </div>
                <div class="vitrine-controles">
                    <button class="vitrine-seta" type="button" data-direcao="-1" aria-label="Jogos anteriores de <?= htmlspecialchars($nomeSecao) ?>">&lsaquo;</button>
                    <button class="vitrine-seta" type="button" data-direcao="1" aria-label="Pr&oacute;ximos jogos de <?= htmlspecialchars($nomeSecao) ?>">&rsaquo;</button>
                </div>
            </div>
            <div class="vitrine-viewport">
                <div class="vitrine-track">
                    <?php foreach ($jogosSecao as $produto): ?>
                        <a class="jogo-card vitrine-card" href="jogo.php?id=<?= $produto['jogo_id'] ?>">
                            <div class="jogo-card-imagem">
                                <img src="<?= htmlspecialchars($produto['img_url']) ?>"
                                     alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>"
                                     loading="lazy">
                            </div>
                            <div class="jogo-card-info">
                                <h3><?= htmlspecialchars($produto['titulo']) ?></h3>
                                <strong>R$ <?= number_format($produto['preco'], 2, ',', '.') ?></strong>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </div>
        </section>
    <?php endforeach; ?>
</main>

<script src="js/animacoes.js"></script>
</body>
</html>
