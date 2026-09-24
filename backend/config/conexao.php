<?php

class Conexao {
    private string $host = "localhost";
    private string $db = "louja";
    private string $user = "root";
    private string $pass = "";
    private string $charset = "utf8mb4";

    public function conectar(): PDO {
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->db};charset={$this->charset}";
            
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ];

            return new PDO($dsn, $this->user, $this->pass, $options);
        } catch (PDOException $e) {
            die("Erro ao conectar com o banco de dados: " . $e->getMessage());
        }
    }
}

$conexao = new Conexao();
$pdo = $conexao->conectar();