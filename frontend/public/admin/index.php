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

$categoriasFiltro = [];
$plataformasFiltro = [];
foreach ($produtos as $produto) {
    foreach (explode(',', $produto['categoria'] ?? '') as $categoria) {
        $categoria = trim($categoria);
        if ($categoria !== '') {
            $categoriasFiltro[$categoria] = $categoria;
        }
    }
    foreach (explode(',', $produto['plataformas'] ?? '') as $plataforma) {
        $plataforma = trim($plataforma);
        if ($plataforma !== '') {
            $plataformasFiltro[$plataforma] = $plataforma;
        }
    }
}
natcasesort($categoriasFiltro);
natcasesort($plataformasFiltro);
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin - Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<header>
    <a href="../index.php" class="logo">
        <img src="../../../docs/logolouja.png" alt="Louja">
    </a>
    <nav>
        <a href="index.php" aria-current="page">Jogos</a>
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

    <div class="admin-filtros" role="search" aria-label="Pesquisar e filtrar jogos">
        <label class="admin-busca">
            <span>Buscar jogos</span>
            <input id="admin-busca" type="search" placeholder="Buscar pelo título...">
        </label>
        <label class="admin-filtro">
            <span>Categoria ou plataforma</span>
            <select id="admin-filtro">
                <option value="">Todas</option>
                <optgroup label="Categorias">
                    <?php foreach ($categoriasFiltro as $categoria): ?>
                        <option value="categoria:<?= htmlspecialchars($categoria, ENT_QUOTES, 'UTF-8') ?>">
                            <?= htmlspecialchars($categoria) ?>
                        </option>
                    <?php endforeach; ?>
                </optgroup>
                <optgroup label="Plataformas">
                    <?php foreach ($plataformasFiltro as $plataforma): ?>
                        <option value="plataforma:<?= htmlspecialchars($plataforma, ENT_QUOTES, 'UTF-8') ?>">
                            <?= htmlspecialchars($plataforma) ?>
                        </option>
                    <?php endforeach; ?>
                </optgroup>
            </select>
        </label>
    </div>
    <p class="admin-resultado" id="admin-resultado" aria-live="polite"></p>

    <div class="admin-catalogo">
        <?php foreach ($produtos as $produto): ?>
            <article class="jogo-card admin-card"
                     data-categorias="<?= htmlspecialchars($produto['categoria'] ?? '', ENT_QUOTES, 'UTF-8') ?>"
                     data-plataformas="<?= htmlspecialchars($produto['plataformas'] ?? '', ENT_QUOTES, 'UTF-8') ?>">
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
    <?php else: ?>
        <div class="catalogo-vazio" id="admin-vazio" hidden>Nenhum jogo encontrado com esses filtros.</div>
    <?php endif; ?>
</main>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
if (window.gsap) {
    window.gsap.from(".admin", { opacity: 0, y: 25, duration: 0.6 });
}

const buscaAdmin = document.querySelector('#admin-busca');
const filtroAdmin = document.querySelector('#admin-filtro');
const resultadoAdmin = document.querySelector('#admin-resultado');
const vazioAdmin = document.querySelector('#admin-vazio');
const cardsAdmin = Array.from(document.querySelectorAll('.admin-card'));
const normalizarAdmin = (valor) => String(valor)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLocaleLowerCase('pt-BR');

function filtrarJogosAdmin() {
    const termo = normalizarAdmin(buscaAdmin.value.trim());
    const selecao = filtroAdmin.value;
    const separador = selecao.indexOf(':');
    const tipo = separador === -1 ? '' : selecao.slice(0, separador);
    const valor = separador === -1 ? '' : normalizarAdmin(selecao.slice(separador + 1));
    let quantidadeVisivel = 0;

    cardsAdmin.forEach((card) => {
        const titulo = normalizarAdmin(card.querySelector('h3')?.textContent ?? '');
        const categorias = (card.dataset.categorias ?? '')
            .split(',')
            .map((opcao) => normalizarAdmin(opcao.trim()));
        const plataformas = (card.dataset.plataformas ?? '')
            .split(',')
            .map((opcao) => normalizarAdmin(opcao.trim()));
        const opcoes = (card.dataset[tipo === 'categoria' ? 'categorias' : 'plataformas'] ?? '')
            .split(',')
            .map((opcao) => normalizarAdmin(opcao.trim()));
        const correspondeBusca = [titulo, ...categorias, ...plataformas]
            .some((campo) => campo.includes(termo));
        const correspondeFiltro = !tipo || opcoes.includes(valor);
        const corresponde = correspondeBusca && correspondeFiltro;
        card.hidden = !corresponde;
        quantidadeVisivel += corresponde ? 1 : 0;
    });

    const textoJogos = quantidadeVisivel === 1 ? 'jogo' : 'jogos';
    resultadoAdmin.textContent = `${quantidadeVisivel} de ${cardsAdmin.length} ${textoJogos}`;
    if (vazioAdmin) vazioAdmin.hidden = quantidadeVisivel > 0;
}

buscaAdmin.addEventListener('input', filtrarJogosAdmin);
filtroAdmin.addEventListener('change', filtrarJogosAdmin);
filtrarJogosAdmin();
</script>
</body>
</html>
