DROP DATABASE IF EXISTS louja;
CREATE DATABASE louja CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE louja;CREATE DATABASE IF NOT EXISTS louja 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE louja;

-- 1. TABELA DE USUÁRIOS
CREATE TABLE usuarios (
    usr_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil ENUM('cliente', 'admin') NOT NULL DEFAULT 'cliente',
    email_verificado TINYINT(1) NOT NULL DEFAULT 0,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. TABELA DE ENDEREÇOS
CREATE TABLE enderecos (
    endereco_id INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    FOREIGN KEY (usr_id) REFERENCES usuarios(usr_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. TABELA DE CATEGORIAS
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT
) ENGINE=InnoDB;

-- 4. TABELA DE JOGOS
CREATE TABLE jogos (
    jogo_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    plataforma VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    img_url VARCHAR(255),
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
) ENGINE=InnoDB;

-- 5. TABELA DE PEDIDOS
CREATE TABLE pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    endereco_id INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_subtotal DECIMAL(10,2) NOT NULL,
    valor_frete DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_total DECIMAL(10,2) NOT NULL,
    status ENUM('pendente', 'pago', 'enviado', 'entregue', 'cancelado') NOT NULL DEFAULT 'pendente',
    FOREIGN KEY (usr_id) REFERENCES usuarios(usr_id),
    FOREIGN KEY (endereco_id) REFERENCES enderecos(endereco_id)
) ENGINE=InnoDB;

-- 6. TABELA ITENS DO PEDIDO
CREATE TABLE itens_pedido (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    jogo_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    FOREIGN KEY (jogo_id) REFERENCES jogos(jogo_id)
) ENGINE=InnoDB;

-- INSERÇÃO DOS DADOS INICIAIS DE TESTE
INSERT INTO categorias (nome, descricao) VALUES 
('RPG', 'Jogos de interpretação de papéis e mundos abertos'),
('Ação e Aventura', 'Jogos com foco em combate e exploração'),
('Esportes', 'Simulação de modalidades esportivas');

INSERT INTO jogos (categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url, ativo) VALUES 
(1, 'Elden Ring', 'RPG de ação em mundo aberto.', 'PC / PS5 / Xbox', 249.90, 15, 'https://via.placeholder.com/400x500?text=Elden+Ring', 1),
(2, 'God of War Ragnarök', 'Aventura épica na mitologia nórdica.', 'PS5', 299.00, 10, 'https://via.placeholder.com/400x500?text=God+of+War', 1),
(3, 'EA Sports FC 24', 'Simulador de futebol profissional.', 'PC / PS5 / Xbox', 199.90, 20, 'https://via.placeholder.com/400x500?text=FC+24', 1);

INSERT INTO usuarios (nome, email, senha, perfil, email_verificado) VALUES 
('Administrador', 'admin@loja.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe1f8O09gTjWb9sY/Z6M8wD1o1J2i3Cq6', 'admin', 1);