<?php
$paginaAdmin = strpos($_SERVER['SCRIPT_NAME'] ?? '', '/admin/') !== false;
$prefixoTema = $paginaAdmin ? '../' : '';
$caminhoLogo = $paginaAdmin ? '../../../docs/logolouja.png' : '../../docs/logolouja.png';
?>
<link rel="icon" type="image/png" href="<?= $caminhoLogo ?>">
<script src="<?= $prefixoTema ?>js/tema.js"></script>
<link rel="stylesheet" href="<?= $prefixoTema ?>css/tema-escuro.css">