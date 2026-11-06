<?php
$caminhoFotoPerfil = $_SESSION['usr_foto_perfil'] ?? '';
$fotoPerfilValida = preg_match('~^uploads/perfil/[a-f0-9]{48}\.(?:jpg|png|webp)$~', $caminhoFotoPerfil) === 1;
$nomeUsuarioAvatar = htmlspecialchars($_SESSION['usr_nome'] ?? 'Usuário', ENT_QUOTES, 'UTF-8');
?>
<a class="perfil-avatar-link" href="perfil.php" aria-label="Meu perfil de <?= $nomeUsuarioAvatar ?>" title="Meu perfil">
    <?php if ($fotoPerfilValida): ?>
        <img src="<?= htmlspecialchars($caminhoFotoPerfil, ENT_QUOTES, 'UTF-8') ?>" alt="">
    <?php else: ?>
        <svg viewBox="0 0 48 48" aria-hidden="true" focusable="false">
            <circle cx="24" cy="24" r="23"></circle>
            <circle class="perfil-avatar-cabeca" cx="24" cy="17" r="8"></circle>
            <path class="perfil-avatar-corpo" d="M8 43c1.8-9 7.7-13.5 16-13.5S38.2 34 40 43"></path>
        </svg>
    <?php endif; ?>
</a>
