<?php
session_start();

// Inclui a conexão com o banco de dados
require_once __DIR__ . '/../config/conexao.php';

// Garante que o acesso ocorra via método POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Sanitize e captura dos dados recebidos
    $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
    $senha = $_POST['senha'] ?? '';

    // Validação de campos vazios
    if (!$email || empty($senha)) {
        header('Location: login.php?erro=vazio');
        exit;
    }

    try {
        // Consulta o usuário pelo e-mail cadastrado
        $sql = "SELECT usr_id, nome, email, senha, perfil FROM usuarios WHERE email = :email LIMIT 1";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':email', $email);
        $stmt->execute();

        $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

        // Verifica se o usuário existe e valida a Hash da senha
        if ($usuario && password_verify($senha, $usuario['senha'])) {
            
            // Regrava o ID da sessão por questões de segurança
            session_regenerate_id(true);

            // Armazena informações relevantes do usuário na Sessão PHP
            $_SESSION['usr_id']     = $usuario['usr_id'];
            $_SESSION['usr_nome']   = $usuario['nome'];
            $_SESSION['usr_email']  = $usuario['email'];
            $_SESSION['usr_perfil'] = $usuario['perfil'];

            // Redireciona conforme o perfil do usuário
            if ($usuario['perfil'] === 'admin') {
                header('Location: admin_dashboard.php');
            } else {
                header('Location: index.php');
            }
            exit;

        } else {
            // Credenciais inválidas (E-mail ou senha incorretos)
            header('Location: login.php?erro=credenciais');
            exit;
        }

    } catch (PDOException $e) {
        // Trata eventuais erros de execução no BD
        header('Location: login.php?erro=bd');
        exit;
    }

} else {
    // Redireciona se tentar acessar diretamente a URL sem enviar o formulário
    header('Location: login.php');
    exit;
}