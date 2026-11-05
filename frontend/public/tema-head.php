<?php
$paginaAdmin = strpos($_SERVER['SCRIPT_NAME'] ?? '', '/admin/') !== false;
$prefixoTema = $paginaAdmin ? '../' : '';
$caminhoLogo = $paginaAdmin ? '../../../docs/logolouja.png' : '../../docs/logolouja.png';
$quantidadeCarrinho = count($_SESSION['carrinho'] ?? []);
$configuracaoCarrinho = [
    'url' => $paginaAdmin ? '../carrinho.php' : 'carrinho.php',
    'quantidade' => (int) $quantidadeCarrinho,
    'visivel' => ($_SESSION['usr_perfil'] ?? '') !== 'admin'
];
?>
<link rel="icon" type="image/png" href="<?= $caminhoLogo ?>">
<script>window.loujaCarrinho = <?= json_encode($configuracaoCarrinho, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;</script>
<script src="<?= $prefixoTema ?>js/tema.js"></script>
<link rel="stylesheet" href="<?= $prefixoTema ?>css/tema-escuro.css">