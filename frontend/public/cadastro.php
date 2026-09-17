<?php
session_start();

require_once '../../backend/config/conexao.php';

$erro = '';
$sucesso = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $nome = trim($_POST['nome'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $senha = $_POST['senha'] ?? '';
    $confirmarSenha = $_POST['confirmar_senha'] ?? '';

    if ($nome === '' || $email === '' || $senha === '' || $confirmarSenha === '') {
        $erro = 'Preencha todos os campos.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $erro = 'Digite um e-mail válido.';
    } elseif (strlen($senha) < 6) {
        $erro = 'A senha deve ter pelo menos 6 caracteres.';
    } elseif ($senha !== $confirmarSenha) {
        $erro = 'As senhas não coincidem.';
    } else {
        $conexao = new Conexao();
        $pdo = $conexao->conectar();
        $stmt = $pdo->prepare(
            'SELECT usr_id FROM usuarios WHERE email = ?'
        );
        $stmt->execute([$email]);

        if ($stmt->fetch()) {
            $erro = 'Este e-mail já está cadastrado.';
        } else {

            $senhaHash = password_hash($senha, PASSWORD_DEFAULT);

            $stmt = $pdo->prepare(
                'INSERT INTO usuarios (nome, email, senha, perfil)
                 VALUES (?, ?, ?, "cliente")'
            );

            if ($stmt->execute([$nome, $email, $senhaHash])) {
                $sucesso = 'Cadastro realizado com sucesso!';

                // Limpa os campos após o cadastro
                $nome = '';
                $email = '';
            } else {
                $erro = 'Não foi possível realizar o cadastro.';
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Cadastro | Louja</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;

            background: #f5f5f5;

            font-family: Arial, Helvetica, sans-serif;
            color: #111;
        }

        .cadastro-container {
            width: 100%;
            max-width: 420px;
            padding: 20px;
        }

        .cadastro-box {
            background: #fff;

            border: 1px solid #ddd;
            border-radius: 12px;

            padding: 40px;

            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.06);
        }

        .logo {
            text-align: center;

            font-size: 32px;
            font-weight: 900;
            letter-spacing: 5px;

            margin-bottom: 10px;
        }

        .subtitulo {
            text-align: center;

            color: #777;
            font-size: 14px;

            margin-bottom: 30px;
        }

        .campo {
            margin-bottom: 18px;
        }

        .campo label {
            display: block;

            font-size: 13px;
            font-weight: 600;

            margin-bottom: 7px;
        }

        .campo input {
            width: 100%;

            padding: 13px 14px;

            border: 1px solid #ccc;
            border-radius: 7px;

            font-size: 14px;

            outline: none;

            transition: border-color 0.2s;
        }

        .campo input:focus {
            border-color: #111;
        }

        .btn-cadastro {
            width: 100%;

            padding: 14px;

            border: none;
            border-radius: 7px;

            background: #111;
            color: #fff;

            font-size: 14px;
            font-weight: 600;

            cursor: pointer;

            transition: 0.2s;
        }

        .btn-cadastro:hover {
            background: #333;
        }

        .mensagem {
            padding: 12px;

            border-radius: 7px;

            font-size: 13px;

            margin-bottom: 20px;

            text-align: center;
        }

        .erro {
            background: #ffe7e7;
            color: #a00000;
        }

        .sucesso {
            background: #e5f6e8;
            color: #176b2c;
        }

        .voltar {
            display: block;

            margin-top: 20px;

            text-align: center;

            color: #111;

            font-size: 13px;
            text-decoration: none;
        }

        .voltar:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

<div class="cadastro-container">

    <div class="cadastro-box">

        <div class="logo">
            LOUJA
        </div>

        <div class="subtitulo">
            Crie sua conta
        </div>

        <?php if ($erro): ?>
            <div class="mensagem erro">
                <?= htmlspecialchars($erro) ?>
            </div>
        <?php endif; ?>

        <?php if ($sucesso): ?>
            <div class="mensagem sucesso">
                <?= htmlspecialchars($sucesso) ?>
            </div>
        <?php endif; ?>

        <form method="POST">

            <div class="campo">
                <label for="nome">Nome</label>

                <input
                    type="text"
                    id="nome"
                    name="nome"
                    placeholder="Digite seu nome"
                    value="<?= htmlspecialchars($nome ?? '') ?>"
                    required
                >
            </div>

            <div class="campo">
                <label for="email">E-mail</label>

                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Digite seu e-mail"
                    value="<?= htmlspecialchars($email ?? '') ?>"
                    required
                >
            </div>

            <div class="campo">
                <label for="senha">Senha</label>

                <input
                    type="password"
                    id="senha"
                    name="senha"
                    placeholder="Digite sua senha"
                    required
                >
            </div>

            <div class="campo">
                <label for="confirmar_senha">Confirmar senha</label>

                <input
                    type="password"
                    id="confirmar_senha"
                    name="confirmar_senha"
                    placeholder="Digite a senha novamente"
                    required
                >
            </div>

            <button
                type="submit"
                class="btn-cadastro"
            >
                Criar conta
            </button>

        </form>

        <a href="login.php" class="voltar">
            Já possui conta? Entrar
        </a>

    </div>

</div>

</body>
</html>
