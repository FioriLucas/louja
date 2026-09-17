<?php
session_start();

require_once __DIR__ . '/../classes/usuarioDAO.php';
require_once __DIR__ . '/../classes/usuario.php';

// 1. Verifica se os dados foram enviados
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $senha = trim($_POST['senha'] ?? '');

    if (empty($email) || empty($senha)) {
        header('Location: ../../frontend/public/login.php?erro=vazio');
        exit;
    }

    $usuarioDAO = new UsuarioDAO();
    $usuario = $usuarioDAO->autenticar($email, $senha);

    // 2. Se as credenciais estiverem corretas
    if ($usuario) {
        // Armazena as informações necessárias na sessão
        $_SESSION['usr_id']   = $usuario->getId();
        $_SESSION['usr_nome'] = $usuario->getNome();
        
        // Se a sua classe Usuario tiver o getter do perfil (ex: $usuario->getPerfil()):
        // $_SESSION['usr_perfil'] = $usuario->getPerfil(); 
        // Caso seu perfil venha de outra verificação ou método, defina a variável aqui:
        $perfil = $_SESSION['usr_perfil'] ?? 'cliente'; 

        // 3. Redirecionamento baseado no perfil do usuário
        if ($perfil === 'admin') {
            header('Location: ../../frontend/public/admin/index.php');
        } else {
            header('Location: ../../frontend/public/index.php');
        }
        exit;
    } else {
        // Se a senha ou e-mail estiverem incorretos
        header('Location: ../../frontend/public/login.php?erro=invalido');
        exit;
    }
} else {
    header('Location: ../../frontend/public/login.php');
    exit;
}