<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$categorias = $pdo->query(
    "SELECT MIN(categoria_id) AS categoria_id, nome
     FROM categorias
     GROUP BY nome
     ORDER BY nome"
)->fetchAll();
$plataformas = ['PC', 'PlayStation 4', 'PlayStation 5', 'Xbox One', 'Xbox Series X|S', 'Nintendo Switch'];
$categoriasPermitidas = array_map('intval', array_column($categorias, 'categoria_id'));
$erro = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $plataformasEnviadas = is_array($_POST['plataformas'] ?? null) ? $_POST['plataformas'] : [];
    $plataformasSelecionadas = array_values(array_unique(array_filter(
        $plataformasEnviadas,
        fn($plataforma) => is_string($plataforma) && in_array($plataforma, $plataformas, true)
    )));
    $categoriasEnviadas = is_array($_POST['categorias'] ?? null) ? $_POST['categorias'] : [];
    $categoriasSelecionadas = array_values(array_unique(array_intersect(
        array_map('intval', $categoriasEnviadas),
        $categoriasPermitidas
    )));

    if (!$plataformasSelecionadas || !$categoriasSelecionadas) {
        $erro = 'Selecione pelo menos uma plataforma e um gênero.';
    } else {
        $pdo->beginTransaction();
        $stmt = $pdo->prepare(
            "INSERT INTO jogos
             (categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url)
             VALUES (?, ?, ?, ?, ?, 1, ?)"
        );
        $stmt->execute([
            $categoriasSelecionadas[0],
            $_POST['titulo'],
            $_POST['descricao'],
            $plataformasSelecionadas[0],
            $_POST['preco'],
            $_POST['img_url']
        ]);
        $jogoId = (int) $pdo->lastInsertId();

        $stmtPlataforma = $pdo->prepare(
            'INSERT INTO jogo_plataformas (jogo_id, plataforma) VALUES (?, ?)'
        );
        foreach ($plataformasSelecionadas as $plataforma) {
            $stmtPlataforma->execute([$jogoId, $plataforma]);
        }

        $stmtCategoria = $pdo->prepare(
            'INSERT INTO jogo_categorias (jogo_id, categoria_id) VALUES (?, ?)'
        );
        foreach ($categoriasSelecionadas as $categoriaId) {
            $stmtCategoria->execute([$jogoId, $categoriaId]);
        }

        $pdo->commit();
        header('Location: index.php');
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Adicionar - Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<div class="admin">
    <h1>Adicionar produto</h1>
    <form method="POST" class="form-admin">
        <input name="titulo" placeholder="Nome do jogo" required>
        <textarea name="descricao" placeholder="Descrição"></textarea>
        <?php if ($erro): ?>
            <p role="alert"><?= htmlspecialchars($erro) ?></p>
        <?php endif; ?>
        <fieldset class="selecao-opcoes">
            <legend>Plataformas</legend>
            <div class="opcoes-grid">
            <?php foreach ($plataformas as $plataforma): ?>
                <label class="opcao-check">
                    <input type="checkbox" name="plataformas[]" value="<?= htmlspecialchars($plataforma) ?>"
                        <?= in_array($plataforma, $plataformasSelecionadas ?? [], true) ? 'checked' : '' ?>>
                    <?= htmlspecialchars($plataforma) ?>
                </label>
            <?php endforeach; ?>
            </div>
        </fieldset>
        <input type="number" step="0.01" name="preco" placeholder="Preço" required>
        <small class="campo-ajuda">A imagem deve ter 1024x1024 px.</small>
        <input name="img_url" placeholder="URL da imagem">

        <fieldset class="selecao-opcoes">
            <legend>Gêneros</legend>
            <div class="opcoes-grid">
            <?php foreach ($categorias as $categoria): ?>
                <label class="opcao-check">
                    <input type="checkbox" name="categorias[]" value="<?= $categoria['categoria_id'] ?>"
                        <?= in_array((int) $categoria['categoria_id'], $categoriasSelecionadas ?? [], true) ? 'checked' : '' ?>>
                    <?= htmlspecialchars($categoria['nome']) ?>
                </label>
            <?php endforeach; ?>
            </div>
        </fieldset>

        <button class="botao" type="submit">Cadastrar</button>
    </form>
    <a href="index.php">Voltar</a>
</div>
</body>
</html>
