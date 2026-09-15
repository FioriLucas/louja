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
    <title>Login - Ebolt Game Store</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);
            padding: 20px;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 40px 32px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.6);
            text-align: center;
        }
        .icon-header {
            width: 48px;
            height: 48px;
            background: #ffffff;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        h1 {
            font-size: 22px;
            color: #1a1a1a;
            margin-bottom: 8px;
            font-weight: 600;
        }
        p.subtitle {
            font-size: 13px;
            color: #666;
            margin-bottom: 28px;
            line-height: 1.4;
        }
        .form-group {
            margin-bottom: 14px;
            text-align: left;
        }
        .input-field {
            width: 100%;
            padding: 14px 16px;
            border-radius: 12px;
            border: 1px solid transparent;
            background: rgba(255, 255, 255, 0.8);
            font-size: 14px;
            outline: none;
            transition: all 0.2s ease;
        }
        .input-field:focus {
            background: #ffffff;
            border-color: #000;
        }
        .forgot-pass {
            display: block;
            text-align: right;
            font-size: 12px;
            color: #444;
            text-decoration: none;
            margin: 8px 0 20px;
        }
        .btn-submit {
            width: 100%;
            padding: 14px;
            border-radius: 12px;
            border: none;
            background: #18181b;
            color: #fff;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-submit:hover {
            background: #27272a;
        }
        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            padding: 10px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 16px;
        }
    </style>
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
        </form>
    </div>

</body>
</html>