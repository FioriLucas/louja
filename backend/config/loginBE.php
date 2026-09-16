<?php
session_start();
require_once __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../../frontend/public/login.php');
    exit;
}

$email = $_POST['email'] ?? '';
$senha = $_POST['senha'] ?? '';

if ($email === '' || $senha === '') {
    header('Location: ../../frontend/public/login.php?erro=vazio');
    exit;
}

$sql = "SELECT * FROM usuarios WHERE email = ?";
$stmt = $pdo->prepare($sql);
$stmt->execute([$email]);
$usuario = $stmt->fetch();

if ($usuario && password_verify($senha, $usuario['senha'])) {
    session_regenerate_id(true);

    $_SESSION['usr_id'] = $usuario['usr_id'];
    $_SESSION['usr_nome'] = $usuario['nome'];
    $_SESSION['usr_perfil'] = $usuario['perfil'];

    if ($usuario['perfil'] === 'admin') {
        header('Location: ../../frontend/public/admin/index.php');
    } else {
        header('Location: ../../frontend/public/index.php');
    }
    exit;
}

header('Location: ../../frontend/public/login.php?erro=credenciais');
exit;
?>
