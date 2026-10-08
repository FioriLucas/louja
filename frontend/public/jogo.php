<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

require_once __DIR__ . '/../../backend/config/conexao.php';

$conexao = new Conexao();
$pdo = $conexao->conectar();

$id = intval($_GET['id'] ?? 0);

$stmt = $pdo->prepare("SELECT jogos.*,
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
                       WHERE jogos.jogo_id = ? AND jogos.ativo = 1
                       LIMIT 1");
$stmt->execute([$id]);
$produto = $stmt->fetch();

if (!$produto) {
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($produto['titulo']) ?> - Louja</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <a href="index.php" class="logo"><img src="../../docs/logolouja.png" alt="Louja"></a>

    <nav>
        <a href="jogos.php">Jogos</a>
        <a href="carrinho.php">Carrinho (<?= array_sum($_SESSION['carrinho'] ?? []) ?>)</a>
        <?php if (isset($_SESSION['usr_id'])): ?>
            <span>Olá, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>
            <a href="logout.php">Sair</a>
        <?php else: ?>
            <a href="login.php">Entrar</a>
        <?php endif; ?>
    </nav>
</header>

<main class="jogo-detalhe">
    <div class="jogo-detalhe-box">
        <div class="jogo-detalhe-capa">
            <img src="<?= htmlspecialchars($produto['img_url']) ?>"
                 alt="Capa de <?= htmlspecialchars($produto['titulo']) ?>">
        </div>

        <div class="jogo-detalhe-info">
            <span class="categoria"><?= htmlspecialchars($produto['categorias']) ?></span>

            <h1><?= htmlspecialchars($produto['titulo']) ?></h1>

            <div class="jogo-detalhe-meta">
                <span>Plataformas: <?= htmlspecialchars($produto['plataformas']) ?></span>
            </div>

            <p class="jogo-detalhe-descricao">
                <?= htmlspecialchars($produto['descricao']) ?>
            </p>

            <div class="jogo-detalhe-preco">
                R$ <?= number_format($produto['preco'], 2, ',', '.') ?>
            </div>

            <?php if ((int)$produto['quantidade_estoque'] > 0): ?>
                <a class="botao" href="adicionar_carrinho.php?id=<?= $produto['jogo_id'] ?>">
                    Adicionar ao carrinho <span>›</span>
                </a>
            <?php else: ?>
                <span class="botao" style="opacity:.5; cursor:not-allowed;">Fora de estoque</span>
            <?php endif; ?>

            <a class="voltar-loja" href="index.php#biblioteca">← Voltar para a biblioteca</a>
        </div>
    </div>
</main>

</body>
</html>
