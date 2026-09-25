<?php

require_once __DIR__ . '/../config/conexao.php';
require_once __DIR__ . '/usuario.php';

class UsuarioDAO {

    private ?int $id;
    private string $nome;
    private string $email;
    private string $senha;
    private string $perfil;

    public function __construct(
        ?int $id = null,
        string $nome = '',
        string $email = '',
        string $senha = '',
        string $perfil = 'cliente'
    ) {
        $this->id = $id;
        $this->nome = $nome;
        $this->email = $email;
        $this->senha = $senha;
        $this->perfil = $perfil;
    }

    public function getId(): ?int {
        return $this->id;
    }

    public function setId(?int $id): void {
        $this->id = $id;
    }

    public function getNome(): string {
        return $this->nome;
    }

    public function setNome(string $nome): void {
        $this->nome = $nome;
    }

    public function getEmail(): string {
        return $this->email;
    }

    public function setEmail(string $email): void {
        $this->email = $email;
    }

    public function getSenha(): string {
        return $this->senha;
    }

    public function setSenha(string $senha): void {
        $this->senha = $senha;
    }

    public function getPerfil(): string {
        return $this->perfil;
    }

    public function setPerfil(string $perfil): void {
        $this->perfil = $perfil;
    }


    // MÉTODO DE LOGIN
    public function autenticar(string $email, string $senha): ?Usuario {

        global $pdo;

        $sql = "SELECT * FROM usuarios WHERE email = :email LIMIT 1";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':email', $email);
        $stmt->execute();

        $dados = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$dados) {
            return null;
        }

        if (!password_verify($senha, $dados['senha'])) {
            return null;
        }

        return new Usuario(
            $dados['id'],
            $dados['nome'],
            $dados['email'],
            $dados['senha'],
            $dados['perfil']
        );
    }
}