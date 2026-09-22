<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';

if (!isset($_SESSION['usr_id']) || $_SESSION['usr_perfil'] !== 'admin') {
    header('Location: ../login.php');
    exit;
}

$id = intval($_GET['id'] ?? 0);

$stmt = $pdo->prepare("DELETE FROM jogos WHERE jogo_id = ?");
$stmt->execute([$id]);

header('Location: index.php');
exit;
?>
