<?php
session_start();

// Inclui a conexão com o banco de dados
require_once __DIR__ . '/../config/conexao.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // 1. Recebimento e higienização dos dados do Usuário
    $nome  = trim($_POST['nome'] ?? '');
    $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
    $senha = $_POST['senha'] ?? '';

    // 2. Recebimento dos dados do Endereço
    $cep         = trim($_POST['cep'] ?? '');
    $logradouro  = trim($_POST['logradouro'] ?? '');
    $numero      = trim($_POST['numero'] ?? '');
    $complemento = trim($_POST['complemento'] ?? '');
    $bairro      = trim($_POST['bairro'] ?? '');
    $cidade      = trim($_POST['cidade'] ?? '');
    $estado      = strtoupper(trim($_POST['estado'] ?? ''));

    // Validação básica dos campos obrigatórios
    if (
        empty($nome) || !$email || empty($senha) ||
        empty($cep) || empty($logradouro) || empty($numero) ||
        empty($bairro) || empty($cidade) || empty($estado)
    ) {
        header('Location: cadastro.php?erro=vazio');
        exit;
    }

    try {
        // Verifica se o e-mail já está cadastrado
        $sqlCheck = "SELECT usr_id FROM usuarios WHERE email = :email LIMIT 1";
        $stmtCheck = $pdo->prepare($sqlCheck);
        $stmtCheck->bindValue(':email', $email);
        $stmtCheck->execute();

        if ($stmtCheck->rowCount() > 0) {
            header('Location: cadastro.php?erro=email_existe');
            exit;
        }

        // Inicia a transação PDO
        $pdo->beginTransaction();

        // Insere na tabela 'usuarios'
        $senhaHash = password_hash($senha, PASSWORD_DEFAULT);
        $sqlUsuario = "INSERT INTO usuarios (nome, email, senha, perfil) VALUES (:nome, :email, :senha, 'cliente')";
        $stmtUsuario = $pdo->prepare($sqlUsuario);
        $stmtUsuario->bindValue(':nome', $nome);
        $stmtUsuario->bindValue(':email', $email);
        $stmtUsuario->bindValue(':senha', $senhaHash);
        $stmtUsuario->execute();

        // Recupera o ID gerado para o novo usuário
        $usr_id = $pdo->lastInsertId();

        // Insere na tabela 'enderecos' relacionando via chave estrangeira (usr_id)
        $sqlEndereco = "INSERT INTO enderecos (usr_id, cep, logradouro, numero, complemento, bairro, cidade, estado) 
                        VALUES (:usr_id, :cep, :logradouro, :numero, :complemento, :bairro, :cidade, :estado)";
        $stmtEndereco = $pdo->prepare($sqlEndereco);
        $stmtEndereco->bindValue(':usr_id', $usr_id);
        $stmtEndereco->bindValue(':cep', $cep);
        $stmtEndereco->bindValue(':logradouro', $logradouro);
        $stmtEndereco->bindValue(':numero', $numero);
        $stmtEndereco->bindValue(':complemento', $complemento);
        $stmtEndereco->bindValue(':bairro', $bairro);
        $stmtEndereco->bindValue(':cidade', $cidade);
        $stmtEndereco->bindValue(':estado', $estado);
        $stmtEndereco->execute();

        // Confirma a gravação dos dados nas duas tabelas
        $pdo->commit();

        // Redireciona para o login com mensagem de sucesso
        header('Location: login.php?sucesso=cadastrado');
        exit;

    } catch (PDOException $e) {
        // Em caso de erro, desfaz qualquer inserção no BD
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        header('Location: cadastro.php?erro=bd');
        exit;
    }

} else {
    header('Location: cadastro.php');
    exit;
}