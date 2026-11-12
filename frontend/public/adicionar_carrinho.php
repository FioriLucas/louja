<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();

if (($_SESSION['usr_perfil'] ?? '') === 'admin') {
    $_SESSION['mensagem_carrinho'] = 'Administradores não podem comprar jogos. Entre com uma conta de usuário para realizar uma compra.';
    header('Location: carrinho.php');
    exit;
}

$id = intval($_GET['id'] ?? 0);

if ($id > 0) {
    if (!isset($_SESSION['carrinho'])) {
        $_SESSION['carrinho'] = [];
    }

    $_SESSION['carrinho'][$id] = 1;
}

header('Location: carrinho.php');
exit;
?>
