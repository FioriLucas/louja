<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';

$conexao = new Conexao();
$pdo = $conexao->conectar();

$sqlCatalogoBase = "SELECT jogos.*,
        COALESCE((
            SELECT GROUP_CONCAT(DISTINCT jc.nome SEPARATOR ', ')
            FROM jogo_categorias AS jcat
            JOIN categorias AS jc ON jc.categoria_id = jcat.categoria_id
            WHERE jcat.jogo_id = jogos.jogo_id
        ), categorias.nome, 'Sem categoria') AS categoria,
        COALESCE((
            SELECT GROUP_CONCAT(DISTINCT jp.plataforma SEPARATOR ', ')
            FROM jogo_plataformas AS jp
            WHERE jp.jogo_id = jogos.jogo_id
        ), jogos.plataforma) AS plataformas
        FROM jogos
        LEFT JOIN categorias ON jogos.categoria_id = categorias.categoria_id
        WHERE jogos.ativo = 1";

$colunaDestaqueExiste = (bool) $pdo->query("SHOW COLUMNS FROM jogos LIKE 'destaque_carrossel'")->fetch();

if ($colunaDestaqueExiste) {
    $sqlDestaques = $sqlCatalogoBase . "
            AND jogos.destaque_carrossel = 1
            ORDER BY jogos.jogo_id DESC";

    $produtos = $pdo->query($sqlDestaques)->fetchAll();

    $sqlCatalogo = $sqlCatalogoBase . "
            AND jogos.destaque_carrossel = 0
            ORDER BY RAND()
            LIMIT 27";

    $catalogo = $pdo->query($sqlCatalogo)->fetchAll();
} else {
    $sqlBase = $sqlCatalogoBase . "
            ORDER BY jogos.jogo_id DESC";

    $todosJogos = $pdo->query($sqlBase)->fetchAll();

    $produtos = array_slice($todosJogos, 0, 5);
    $catalogo = array_slice($todosJogos, 5);
    shuffle($catalogo);
}

$sqlVitrine = $sqlCatalogoBase . "
        ORDER BY jogos.titulo";
$jogosVitrine = $pdo->query($sqlVitrine)->fetchAll();

$idsCatalogoPesquisa = array_fill_keys(array_column($catalogo, 'jogo_id'), true);
$jogosCatalogoPesquisa = $catalogo;
foreach ($jogosVitrine as $jogoVitrine) {
    if (!isset($idsCatalogoPesquisa[$jogoVitrine['jogo_id']])) {
        $jogosCatalogoPesquisa[] = $jogoVitrine;
    }
}

$ofertasVitrine = $jogosVitrine;
usort($ofertasVitrine, function ($jogoA, $jogoB) {
    return (float) $jogoA['preco'] <=> (float) $jogoB['preco'];
});

$secoesVitrine = ['Ofertas' => array_slice($ofertasVitrine, 0, 8)];

?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Louja - Game Store</title>
    <link rel="stylesheet" href="css/style.css">
    <?php require __DIR__ . '/tema-head.php'; ?>
</head>
<body class="home-page">

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
        <?php if (isset($_SESSION['usr_id'])): ?>
            <span>Ol&aacute;, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>
            <a href="perfil.php">Meu perfil</a>

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
                        <p class="plataforma"><?= htmlspecialchars($produto['plataformas']) ?></p>
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
                            <span class="jogo-plataforma"><?= htmlspecialchars($produto['plataformas']) ?></span>
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
        <section class="vitrine-jogos vitrine-ofertas" data-vitrine>
            <div class="vitrine-cabecalho">
                <div>
                    <h2><?= htmlspecialchars($nomeSecao) ?></h2>
                    <?php if ($nomeSecao === 'Ofertas'): ?>
                        <p>Uma sele&ccedil;&atilde;o dos menores pre&ccedil;os da loja.</p>
                    <?php endif; ?>
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

    <section class="sobre-nos" id="sobre-nos">
        <div class="sobre-nos-conteudo">
            <p class="sobre-nos-sobretitulo">Conhe&ccedil;a a Louja</p>
            <h2>Sobre N&oacute;s</h2>
            <p>
                A Louja foi oficialmente fundada em <strong>03 de novembro de 2026</strong> por seis
                integrantes unidos pelo interesse no universo dos games e pela vontade de criar uma
                loja virtual de jogos online.
            </p>
            <p>
                Desde o in&iacute;cio, nosso objetivo &eacute; facilitar o acesso dos jogadores aos seus
                t&iacute;tulos favoritos, reunindo praticidade, inova&ccedil;&atilde;o e uma experi&ecirc;ncia
                de compra simples em um s&oacute; lugar. A equipe dividiu responsabilidades entre
                organiza&ccedil;&atilde;o, desenvolvimento e an&aacute;lise para transformar essa ideia em
                uma plataforma feita em conjunto.
            </p>
        </div>

        <div class="sobre-nos-fundadores">
            <h3>Nossos Fundadores</h3>
            <div class="sobre-nos-equipes">
                <article class="sobre-nos-equipe">
                    <h4>Scrum Master</h4>
                    <p><strong>Lucas Fiori</strong> — organiza&ccedil;&atilde;o da equipe e acompanhamento do projeto.</p>
                </article>
                <article class="sobre-nos-equipe">
                    <h4>Desenvolvedores</h4>
                    <ul>
                        <li><strong>Artur Dionisio Silva</strong> — desenvolvimento e implementa&ccedil;&atilde;o das funcionalidades.</li>
                        <li><strong>Erick Gabriel Schnorr Ries</strong> — programa&ccedil;&atilde;o e constru&ccedil;&atilde;o dos recursos da plataforma.</li>
                        <li><strong>Jo&atilde;o Vitor Bortolaci da Silva</strong> — desenvolvimento e estrutura&ccedil;&atilde;o do sistema.</li>
                    </ul>
                </article>
                <article class="sobre-nos-equipe">
                    <h4>Analistas</h4>
                    <ul>
                        <li><strong>Luiza Szulczewski de Quadros</strong> — levantamento e an&aacute;lise de requisitos.</li>
                        <li><strong>Vict&oacute;ria Cunha Foga&ccedil;a</strong> — documenta&ccedil;&atilde;o e an&aacute;lise das necessidades do sistema.</li>
                    </ul>
                </article>
            </div>
        </div>

        <p class="sobre-nos-slogan">Louja — Sua pr&oacute;xima aventura come&ccedil;a aqui!</p>
    </section>
</main>

<footer class="rodape-loja">
    <div class="rodape-conteudo">
        <div class="rodape-marca">
            <a href="index.php" class="rodape-logo">Louja</a>
            <p>Sua pr&oacute;xima aventura come&ccedil;a aqui.</p>
        </div>
        <div class="rodape-redes">
            <h2>Redes sociais</h2>
            <ul>
                <li><a href="https://www.instagram.com/" target="_blank" rel="noopener noreferrer">Instagram</a></li>
                <li><a href="https://www.tiktok.com/" target="_blank" rel="noopener noreferrer">TikTok</a></li>
                <li><a href="https://discord.com/" target="_blank" rel="noopener noreferrer">Discord</a></li>
            </ul>
        </div>
        <div class="rodape-contato">
            <h2>Contato</h2>
            <a href="tel:+5511999990000">(11) 99999-0000</a>
            <small>N&uacute;mero ilustrativo</small>
        </div>
    </div>
    <div class="rodape-final">
        <span>&copy; 2026 Louja</span>
        <a href="#sobre-nos">Sobre N&oacute;s</a>
    </div>
</footer>

<script src="js/animacoes.js"></script>
</body>
</html>
