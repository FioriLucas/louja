<?php

class Usuario {
    private ?int $id;
    private string $nome;
    private string $email;
    private string $senha;
    private string $perfil;
    private ?string $fotoPerfil;

    public function __construct(?int $id = null, string $nome = '', string $email = '', string $senha = '', string $perfil = 'cliente', ?string $fotoPerfil = null) {
        $this->id = $id;
        $this->nome = $nome;
        $this->email = $email;
        $this->senha = $senha;
        $this->perfil = $perfil;
        $this->fotoPerfil = $fotoPerfil;
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

    public function getFotoPerfil(): ?string {
        return $this->fotoPerfil;
    }
}