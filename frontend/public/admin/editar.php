<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$id = intval($_GET['id'] ?? 0);

$stmt = $pdo->prepare("SELECT * FROM jogos WHERE jogo_id = ?");
$stmt->execute([$id]);
$produto = $stmt->fetch();

if (!$produto) {
    header('Location: index.php');
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

$stmt = $pdo->prepare('SELECT plataforma FROM jogo_plataformas WHERE jogo_id = ?');
$stmt->execute([$id]);
$plataformasSelecionadas = $stmt->fetchAll(PDO::FETCH_COLUMN);
if (!$plataformasSelecionadas) {
    $plataformasSelecionadas = [$produto['plataforma']];
}

$stmt = $pdo->prepare('SELECT categoria_id FROM jogo_categorias WHERE jogo_id = ?');
$stmt->execute([$id]);
$categoriasSelecionadas = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
if (!$categoriasSelecionadas) {
    $categoriasSelecionadas = [(int) $produto['categoria_id']];
}
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
            "UPDATE jogos SET categoria_id=?, titulo=?, descricao=?, plataforma=?,
             preco=?, img_url=? WHERE jogo_id=?"
        );
        $stmt->execute([
            $categoriasSelecionadas[0],
            $_POST['titulo'],
            $_POST['descricao'],
            $plataformasSelecionadas[0],
            $_POST['preco'],
            $_POST['img_url'],
            $id
        ]);

        $pdo->prepare('DELETE FROM jogo_plataformas WHERE jogo_id = ?')->execute([$id]);
        $stmtPlataforma = $pdo->prepare(
            'INSERT INTO jogo_plataformas (jogo_id, plataforma) VALUES (?, ?)'
        );
        foreach ($plataformasSelecionadas as $plataforma) {
            $stmtPlataforma->execute([$id, $plataforma]);
        }

        $pdo->prepare('DELETE FROM jogo_categorias WHERE jogo_id = ?')->execute([$id]);
        $stmtCategoria = $pdo->prepare(
            'INSERT INTO jogo_categorias (jogo_id, categoria_id) VALUES (?, ?)'
        );
        foreach ($categoriasSelecionadas as $categoriaId) {
            $stmtCategoria->execute([$id, $categoriaId]);
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
    <title>Editar - Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<div class="admin">
    <h1>Editar produto</h1>

    <form method="POST" class="form-admin">
        <?php if ($erro): ?>
            <p role="alert"><?= htmlspecialchars($erro) ?></p>
        <?php endif; ?>
        <input name="titulo" value="<?= htmlspecialchars($produto['titulo']) ?>" required>
        <textarea name="descricao"><?= htmlspecialchars($produto['descricao']) ?></textarea>
        <fieldset class="selecao-opcoes">
            <legend>Plataformas</legend>
            <div class="opcoes-grid">
            <?php foreach ($plataformas as $plataforma): ?>
                <label class="opcao-check">
                    <input type="checkbox" name="plataformas[]" value="<?= htmlspecialchars($plataforma) ?>"
                        <?= in_array($plataforma, $plataformasSelecionadas, true) ? 'checked' : '' ?>>
                    <?= htmlspecialchars($plataforma) ?>
                </label>
            <?php endforeach; ?>
            </div>
        </fieldset>
        <input type="number" step="0.01" name="preco" value="<?= $produto['preco'] ?>" required>
        <small class="campo-ajuda">A imagem deve ter 1024x1024 px.</small>
        <input name="img_url" value="<?= htmlspecialchars($produto['img_url']) ?>">

        <fieldset class="selecao-opcoes">
            <legend>Gêneros</legend>
            <div class="opcoes-grid">
            <?php foreach ($categorias as $categoria): ?>
                <label class="opcao-check">
                    <input type="checkbox" name="categorias[]" value="<?= $categoria['categoria_id'] ?>"
                        <?= in_array((int) $categoria['categoria_id'], $categoriasSelecionadas, true) ? 'checked' : '' ?>>
                    <?= htmlspecialchars($categoria['nome']) ?>
                </label>
            <?php endforeach; ?>
            </div>
        </fieldset>

        <button class="botao" type="submit">Salvar alterações</button>
    </form>

    <a href="index.php">Voltar</a>
</div>
</body>
</html>
