<?php
header('Content-Type: application/json; charset=utf-8');
session_start();

// Inclui a conexão com o banco de dados
require_once __DIR__ . '/conexao.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Captura os dados (aceita tanto 'username'/'email' quanto 'password'/'senha')
    $email = trim($_POST['username'] ?? $_POST['email'] ?? '');
    $password = $_POST['password'] ?? $_POST['senha'] ?? '';

    // Validação de campos vazios
    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'Preencha todos os campos.']);
        exit;
    }

    try {
        // Consulta o usuário pelo e-mail no banco de dados
        $stmt = $pdo->prepare("SELECT usr_id, nome, email, senha, perfil FROM usuarios WHERE email = :email LIMIT 1");
        $stmt->execute([':email' => $email]);
        $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

        // Valida usuário e hash da senha
        if ($usuario && password_verify($password, $usuario['senha'])) {
            session_regenerate_id(true);

            // Armazena dados do usuário na sessão
            $_SESSION['usr_id']     = $usuario['usr_id'];
            $_SESSION['usr_nome']   = $usuario['nome'];
            $_SESSION['usr_email']  = $usuario['email'];
            $_SESSION['usr_perfil'] = $usuario['perfil'];

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
} else {
    echo json_encode(['success' => false, 'message' => 'Método de requisição inválido.']);
    exit;
}
?>