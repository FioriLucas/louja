<?php
require_once __DIR__ . '/../config/conexao.php';
require_once __DIR__ . '/usuario.php'; 

class UsuarioDAO {
    private PDO $db;

    public function __construct() {
        $conexao = new Conexao();
        $this->db = $conexao->conectar();
    }

    public function cadastrar(Usuario $usuario): bool {
        $sql = "INSERT INTO usuarios (nome, email, senha) VALUES (:nome, :email, :senha)";
        $stmt = $this->db->prepare($sql);

        $senhaHash = password_hash($usuario->getSenha(), PASSWORD_DEFAULT);

        return $stmt->execute([
            ':nome'  => $usuario->getNome(),
            ':email' => $usuario->getEmail(),
            ':senha' => $senhaHash
        ]);
    }

    public function buscarPorEmail(string $email): ?Usuario {
        $sql = "SELECT usr_id, nome, email, senha, perfil FROM usuarios WHERE email = :email LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':email' => $email]);

        $data = $stmt->fetch();
        if (!$data) {
            return null;
        }

        return new Usuario(
            (int) $data['usr_id'],
            $data['nome'],
            $data['email'],
            $data['senha'],
            $data['perfil'] ?? 'cliente'
        );
    }

    public function autenticar(string $email, string $senha): ?Usuario {
        $usuario = $this->buscarPorEmail($email);

        if ($usuario && password_verify($senha, $usuario->getSenha())) {
            return $usuario;
        }

        return null;
    }
}