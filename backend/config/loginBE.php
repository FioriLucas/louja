<?php
header('Content-Type: application/json; charset=utf-8');
session_start();
require_once 'conexao.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Preencha todos os campos.']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT usr_id, nome, email, senha, perfil FROM usuarios WHERE email = :email");
        $stmt->execute([':email' => $email]);
        $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($usuario && password_verify($password, $usuario['senha'])) {
            session_regenerate_id(true);

            $_SESSION['usr_id'] = $usuario['usr_id'];
            $_SESSION['nome']   = $usuario['nome'];
            $_SESSION['perfil'] = $usuario['perfil'];

            echo json_encode([
                'success' => true,
                'message' => 'Login realizado com sucesso.',
                'perfil'  => $usuario['perfil']
            ]);
        } else {
            echo json_encode([
                'success' => false, 
                'message' => 'E-mail ou senha incorretos.'
            ]);
        }
    } catch (PDOException $e) {
        error_log($e->getMessage());
        echo json_encode(['success' => false, 'message' => 'Erro interno no servidor.']);
    }
    exit;
}
?>