<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$categorias = $pdo->query("SELECT * FROM categorias ORDER BY nome")->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $sql = "INSERT INTO jogos
            (categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url)
            VALUES (?, ?, ?, ?, ?, ?, ?)";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        $_POST['categoria_id'],
        $_POST['titulo'],
        $_POST['descricao'],
        $_POST['plataforma'],
        $_POST['preco'],
        $_POST['estoque'],
        $_POST['img_url']
    ]);

    header('Location: index.php');
    exit;
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
        <input name="plataforma" placeholder="Plataforma" required>
        <input type="number" step="0.01" name="preco" placeholder="Preço" required>
        <input type="number" name="estoque" placeholder="Estoque" required>
        <input name="img_url" placeholder="URL da imagem">

        <select name="categoria_id" required>
            <?php foreach ($categorias as $categoria): ?>
                <option value="<?= $categoria['categoria_id'] ?>">
                    <?= htmlspecialchars($categoria['nome']) ?>
                </option>
            <?php endforeach; ?>
        </select>

        <button class="botao" type="submit">Cadastrar</button>
    </form>
    <a href="index.php">Voltar</a>
</div>
</body>
</html>
