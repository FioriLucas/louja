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

    <link rel="stylesheet" href="css/login.css">
    <link rel="stylesheet" href="css/cadastro.css">
</head>

<body class="login-page">

<div class="login-box">
    <a href="index.php" class="logo">LOUJA</a>
    <h1>Criar conta</h1>
    <p>Crie sua conta para continuar.</p>

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

    <form method="POST" class="form-cadastro">
        <input
            type="text"
            id="nome"
            name="nome"
            placeholder="Nome"
            value="<?= htmlspecialchars($nome ?? '') ?>"
            required
        >

        <input
            type="email"
            id="email"
            name="email"
            placeholder="E-mail"
            value="<?= htmlspecialchars($email ?? '') ?>"
            required
        >

        <input
            type="password"
            id="senha"
            name="senha"
            placeholder="Senha"
            required
        >

        <input
            type="password"
            id="confirmar_senha"
            name="confirmar_senha"
            placeholder="Confirmar senha"
            required
        >

        <button type="submit">Criar conta</button>
    </form>

    <a href="login.php" class="btn-cadastro">
        Já possui conta? Entrar
    </a>

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
