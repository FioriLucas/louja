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

    <link rel="stylesheet" href="css/cadastro.css">
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
