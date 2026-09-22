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

$categorias = $pdo->query("SELECT * FROM categorias ORDER BY nome")->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "UPDATE jogos SET categoria_id=?, titulo=?, descricao=?, plataforma=?,
            preco=?, quantidade_estoque=?, img_url=? WHERE jogo_id=?";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        $_POST['categoria_id'],
        $_POST['titulo'],
        $_POST['descricao'],
        $_POST['plataforma'],
        $_POST['preco'],
        $_POST['estoque'],
        $_POST['img_url'],
        $id
    ]);

    header('Location: index.php');
    exit;
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
        <input name="titulo" value="<?= htmlspecialchars($produto['titulo']) ?>" required>
        <textarea name="descricao"><?= htmlspecialchars($produto['descricao']) ?></textarea>
        <input name="plataforma" value="<?= htmlspecialchars($produto['plataforma']) ?>" required>
        <input type="number" step="0.01" name="preco" value="<?= $produto['preco'] ?>" required>
        <input type="number" name="estoque" value="<?= $produto['quantidade_estoque'] ?>" required>
        <input name="img_url" value="<?= htmlspecialchars($produto['img_url']) ?>">

        <select name="categoria_id">
            <?php foreach ($categorias as $categoria): ?>
                <option value="<?= $categoria['categoria_id'] ?>"
                    <?= $categoria['categoria_id'] == $produto['categoria_id'] ? 'selected' : '' ?>>
                    <?= htmlspecialchars($categoria['nome']) ?>
                </option>
            <?php endforeach; ?>
        </select>

        <button class="botao" type="submit">Salvar alterações</button>
    </form>

    <a href="index.php">Voltar</a>
</div>
</body>
</html>
