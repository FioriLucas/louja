<?php
session_start();
// Se já estiver logado, redireciona para a página principal
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
    <link rel="stylesheet" href="styleLogin.css">
   
</head>
<body>

    <div class="login-card">
        <div class="icon-header">
            ➔]
        </div>
        <h1>Sign in with email</h1>
        <p class="subtitle">Acesse sua conta para gerenciar seus pedidos e compras na loja.</p>

        <?php if (isset($_GET['erro'])): ?>
            <div class="alert-error">
                <?php 
                    if ($_GET['erro'] == 'credenciais') echo "E-mail ou senha incorretos!";
                    elseif ($_GET['erro'] == 'vazio') echo "Preencha todos os campos!";
                    else echo "Erro ao processar o login. Tente novamente.";
                ?>
            </div>
        <?php endif; ?>

        <form action="loginBE.php" method="POST">
            <div class="form-group">
                <input type="email" name="email" class="input-field" placeholder="Email" required>
            </div>
            <div class="form-group">
                <input type="password" name="senha" class="input-field" placeholder="Password" required>
            </div>
            
            <a href="#" class="forgot-pass">Forgot password?</a>

            <button type="submit" class="btn-submit">Get Started</button>
            <p style="margin-top: 15px;">Ainda não tem conta? <a href="../cadastro/cadastro.php">Cadastre-se aqui</a></p>
        </form>
    </div>

</body>
</html>