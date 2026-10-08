<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';
$conexao = new Conexao();
$pdo = $conexao->conectar();

$produtos = $pdo->query(
    "SELECT jogos.*,
            COALESCE((
                SELECT GROUP_CONCAT(DISTINCT jc.nome SEPARATOR ', ')
                FROM jogo_categorias AS jcat
                JOIN categorias AS jc ON jc.categoria_id = jcat.categoria_id
                WHERE jcat.jogo_id = jogos.jogo_id
            ), categorias.nome, 'Sem categoria') AS categorias,
            COALESCE((
                SELECT GROUP_CONCAT(DISTINCT jp.plataforma SEPARATOR ', ')
                FROM jogo_plataformas AS jp
                WHERE jp.jogo_id = jogos.jogo_id
            ), jogos.plataforma, '') AS plataformas
     FROM jogos
     LEFT JOIN categorias ON categorias.categoria_id = jogos.categoria_id
     WHERE jogos.ativo = 1
     ORDER BY jogos.titulo"
)->fetchAll();

$categorias = [];
$plataformas = [];
foreach ($produtos as $produto) {
    foreach (explode(',', $produto['categorias'] ?? '') as $categoria) {
        $categoria = trim($categoria);
        if ($categoria !== '') {
            $categorias[$categoria] = $categoria;
        }
    }
    foreach (explode(',', $produto['plataformas'] ?? '') as $plataforma) {
        $plataforma = trim($plataforma);
        if ($plataforma !== '') {
            $plataformas[$plataforma] = $plataforma;
        }
    }
}
natcasesort($categorias);
natcasesort($plataformas);
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jogos - Louja</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>
    <nav>
        <a href="jogos.php" aria-current="page">Jogos</a>
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

<main class="catalogo-completo-pagina">
    <section aria-labelledby="catalogo-titulo">
        <div class="catalogo-completo-cabecalho">
            <div>
                <h1 id="catalogo-titulo">Todos os jogos</h1>
                <p>Explore o catálogo completo da Louja.</p>
            </div>
        </div>

        <div class="catalogo-completo-filtros" role="search" aria-label="Pesquisar e filtrar jogos">
            <label class="catalogo-completo-busca">
                <span>Nome do jogo</span>
                <input id="jogos-busca" type="search" placeholder="Buscar pelo título...">
            </label>
            <label class="catalogo-completo-filtro">
                <span>Categoria ou plataforma</span>
                <select id="jogos-filtro">
                    <option value="">Todas</option>
                    <optgroup label="Categorias">
                        <?php foreach ($categorias as $categoria): ?>
                            <option value="categoria:<?= htmlspecialchars($categoria, ENT_QUOTES, 'UTF-8') ?>">
                                <?= htmlspecialchars($categoria) ?>
                            </option>
                        <?php endforeach; ?>
                    </optgroup>
                    <optgroup label="Plataformas">
                        <?php foreach ($plataformas as $plataforma): ?>
                            <option value="plataforma:<?= htmlspecialchars($plataforma, ENT_QUOTES, 'UTF-8') ?>">
                                <?= htmlspecialchars($plataforma) ?>
                            </option>
                        <?php endforeach; ?>
                    </optgroup>
                </select>
            </label>
            <button class="catalogo-completo-limpar" id="jogos-limpar" type="button">Limpar filtros</button>
        </div>

        <p class="catalogo-completo-resultado" id="jogos-resultado" aria-live="polite"></p>

        <?php if ($produtos): ?>
            <div class="catalogo-completo-grade" id="jogos-grade">
                <?php foreach ($produtos as $produto): ?>
                    <a class="jogo-card catalogo-completo-card"
                       href="jogo.php?id=<?= (int) $produto['jogo_id'] ?>"
                       data-categorias="<?= htmlspecialchars($produto['categorias'] ?? '', ENT_QUOTES, 'UTF-8') ?>"
                       data-plataformas="<?= htmlspecialchars($produto['plataformas'] ?? '', ENT_QUOTES, 'UTF-8') ?>">
                        <div class="jogo-card-imagem">
                            <img src="<?= htmlspecialchars($produto['img_url'] ?? '') ?>"
                                 alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>"
                                 loading="lazy">
                            <span class="jogo-categoria"><?= htmlspecialchars($produto['categorias']) ?></span>
                        </div>
                        <div class="jogo-card-info">
                            <h2><?= htmlspecialchars($produto['titulo']) ?></h2>
                            <span class="catalogo-completo-plataformas">
                                <?= htmlspecialchars($produto['plataformas'] ?: 'Plataforma não informada') ?>
                            </span>
                            <strong>R$ <?= number_format($produto['preco'], 2, ',', '.') ?></strong>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>
            <div class="catalogo-vazio" id="jogos-vazio" hidden>Nenhum jogo encontrado com esses filtros.</div>
        <?php else: ?>
            <div class="catalogo-vazio">Nenhum jogo disponível no momento.</div>
        <?php endif; ?>
    </section>
</main>

<script>
const campoBuscaJogos = document.querySelector('#jogos-busca');
const filtroJogos = document.querySelector('#jogos-filtro');
const resultadoJogos = document.querySelector('#jogos-resultado');
const mensagemVaziaJogos = document.querySelector('#jogos-vazio');
const cartoesJogos = Array.from(document.querySelectorAll('.catalogo-completo-card'));
const normalizarTexto = (texto) => texto
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLocaleLowerCase('pt-BR');

function filtrarJogos() {
    const termo = normalizarTexto(campoBuscaJogos.value.trim());
    const selecao = filtroJogos.value;
    const separador = selecao.indexOf(':');
    const tipo = separador === -1 ? '' : selecao.slice(0, separador);
    const valor = separador === -1 ? '' : normalizarTexto(selecao.slice(separador + 1));
    let quantidade = 0;

    cartoesJogos.forEach((cartao) => {
        const titulo = normalizarTexto(cartao.querySelector('h2')?.textContent ?? '');
        const atributos = tipo === 'categoria' ? 'categorias' : 'plataformas';
        const valores = (cartao.dataset[atributos] ?? '')
            .split(',')
            .map((item) => normalizarTexto(item.trim()));
        const corresponde = titulo.includes(termo) && (!tipo || valores.includes(valor));
        cartao.hidden = !corresponde;
        quantidade += corresponde ? 1 : 0;
    });

    resultadoJogos.textContent = `${quantidade} de ${cartoesJogos.length} jogos`;
    if (mensagemVaziaJogos) mensagemVaziaJogos.hidden = quantidade > 0;
}

campoBuscaJogos.addEventListener('input', filtrarJogos);
filtroJogos.addEventListener('change', filtrarJogos);
document.querySelector('#jogos-limpar')?.addEventListener('click', () => {
    campoBuscaJogos.value = '';
    filtroJogos.value = '';
    filtrarJogos();
});

filtrarJogos();
</script>
</body>
</html>