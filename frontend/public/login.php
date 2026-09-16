<?php
session_start();

if (isset($_SESSION['usr_id'])) {
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Louja</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="login-page">

<div class="login-box">
    <a href="index.php" class="logo">LOUJA</a>
    <h1>Entrar</h1>
    <p>Entre na sua conta para continuar.</p>

    <?php if (isset($_GET['erro'])): ?>
        <div class="erro">
            <?php
            if ($_GET['erro'] === 'vazio') {
                echo 'Preencha todos os campos.';
            } else {
                echo 'E-mail ou senha incorretos.';
            }
            ?>
        </div>
    <?php endif; ?>

    <form action="../../backend/config/loginBE.php" method="POST">
        <input type="email" name="email" placeholder="E-mail" required>
        <input type="password" name="senha" placeholder="Senha" required>
        <button type="submit">Entrar</button>
    </form>

    <a href="index.php" class="voltar">Voltar para a loja</a>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
<script>
gsap.from(".login-box", {
    opacity: 0,
    y: 30,
    duration: 0.7
});
</script>
</body>
</html>
