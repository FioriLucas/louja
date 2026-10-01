<?php

require_once __DIR__ . '/../config/conexao.php';
require_once __DIR__ . '/usuario.php';

class UsuarioDAO {
    private PDO $pdo;

    public function __construct() {
        global $pdo;
        $this->pdo = $pdo;
    }

    public function autenticar(string $email, string $senha): ?Usuario {
        $stmt = $this->pdo->prepare(
            'SELECT usr_id, nome, email, senha, perfil FROM usuarios WHERE email = :email'
        );
        $stmt->execute([':email' => $email]);
        $dados = $stmt->fetch();

        if (!$dados || !password_verify($senha, $dados['senha'])) {
            return null;
        }

        return new Usuario(
            (int) $dados['usr_id'],
            $dados['nome'],
            $dados['email'],
            $dados['senha'],
            $dados['perfil']
        );
    }
}