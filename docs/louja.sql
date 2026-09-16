CREATE DATABASE IF NOT EXISTS louja;
USE louja;

CREATE TABLE usuarios (
    usr_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil ENUM('cliente', 'admin') DEFAULT 'cliente'
);

CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE jogos (
    jogo_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    plataforma VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT DEFAULT 0,
    img_url VARCHAR(255),
    ativo TINYINT(1) DEFAULT 1,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
);

INSERT INTO categorias (nome) VALUES
('RPG'),
('Ação e Aventura'),
('Esportes');

INSERT INTO jogos
(categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url)
VALUES
(1, 'Elden Ring', 'RPG de ação em mundo aberto.', 'PC / PS5 / Xbox', 249.90, 15,
'https://via.placeholder.com/400x500?text=Elden+Ring'),
(2, 'God of War Ragnarök', 'Aventura épica.', 'PS5', 299.00, 10,
'https://via.placeholder.com/400x500?text=God+of+War'),
(3, 'EA Sports FC 24', 'Simulador de futebol.', 'PC / PS5 / Xbox', 199.90, 20,
'https://via.placeholder.com/400x500?text=FC+24');

-- Senha de teste: admin123
INSERT INTO usuarios (nome, email, senha, perfil)
VALUES (
    'Administrador',
    'admin@loja.com',
    '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe1f8O09gTjWb9sY/Z6M8wD1o1J2i3Cq6',
    'admin'
);
