<?php
session_set_cookie_params([
    'lifetime' => 60 * 60 * 24 * 7,
    'path' => '/'
]);
session_start();
$id=intval($_GET['id'] ?? 0);

if ($id>0 && isset($_SESSION['carrinho'][$id])) {
    $_SESSION['carrinho'][$id]--;

    if ($_SESSION['carrinho'][$id]<=0) {
    unset($_SESSION['carrinho'][$id]);
    }
}
header('Location: carrinho.php');
exit;
?>
