CREATE DATABASE IF NOT EXISTS louja;
USE louja;

CREATE TABLE IF NOT EXISTS usuarios (
    usr_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil ENUM('cliente', 'admin') DEFAULT 'cliente'
);

CREATE TABLE IF NOT EXISTS categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS jogos (
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
('Ação'),
('Aventura'),
('Horror'),
('Sobrevivência'),
('FPS'),
('Esportes');


-- Senha de teste: admin123
INSERT INTO usuarios (nome, email, senha, perfil)
VALUES (
    'Administrador',
    'admin@loja.com',
    '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe1f8O09gTjWb9sY/Z6M8wD1o1J2i3Cq6',
    'admin'
);

INSERT INTO jogos
(categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url)
VALUES
(5, 'Minecraft', 'Jogo sandbox de sobrevivência e construção.', 'PC', 99.00, 20, 'https://images.igdb.com/igdb/image/upload/t_cover_big/co2l8f.jpg'),

(2, 'Grand Theft Auto V', 'Jogo de ação e mundo aberto.', 'PC', 99.90, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/271590/header.jpg'),

(2, 'Red Dead Redemption 2', 'Aventura de ação em mundo aberto ambientada no Velho Oeste.', 'PC', 299.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1174180/header.jpg'),

(1, 'The Witcher 3: Wild Hunt', 'RPG de mundo aberto com exploração e narrativa.', 'PC', 149.99, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/292030/header.jpg'),

(1, 'Cyberpunk 2077', 'RPG de ação ambientado em um futuro distópico.', 'PC', 199.90, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1091500/header.jpg'),

(1, 'Elden Ring', 'RPG de ação em um vasto mundo de fantasia.', 'PC', 229.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg'),

(1, 'Dark Souls III', 'RPG de ação conhecido por sua alta dificuldade.', 'PC', 229.90, 8, 'https://cdn.cloudflare.steamstatic.com/steam/apps/374320/header.jpg'),

(2, 'Sekiro: Shadows Die Twice', 'Jogo de ação com combate baseado em espadas.', 'PC', 274.90, 8, 'https://cdn.cloudflare.steamstatic.com/steam/apps/814380/header.jpg'),

(2, 'God of War', 'Aventura de ação baseada na mitologia nórdica.', 'PC', 199.90, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1593500/header.jpg'),

(2, 'God of War Ragnarök', 'Aventura de ação com Kratos e Atreus.', 'PC', 249.90, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2322010/header.jpg'),

(2, 'Marvel''s Spider-Man Remastered', 'Jogo de ação e aventura baseado no Homem-Aranha.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1817070/header.jpg'),

(2, 'Marvel''s Spider-Man 2', 'Jogo de ação e aventura com Peter Parker e Miles Morales.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2651280/header.jpg'),

(1, 'Horizon Zero Dawn', 'RPG de ação em um mundo aberto pós-apocalíptico.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1151640/header.jpg'),

(1, 'Horizon Forbidden West', 'RPG de ação e exploração em mundo aberto.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2420110/header.jpg'),

(2, 'The Last of Us Part I', 'Aventura de ação focada em narrativa e sobrevivência.', 'PC', 249.90, 8, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1888930/header.jpg'),

(2, 'The Last of Us Part II', 'Aventura de ação focada em narrativa.', 'PC', 249.90, 8, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2531310/header.jpg'),

(3, 'Uncharted 4', 'Aventura de ação com exploração e enigmas.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1659420/header.jpg'),

(2, 'Ghost of Tsushima', 'Ação e exploração em mundo aberto no Japão feudal.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2215430/header.jpg'),

(1, 'Assassin''s Creed Valhalla', 'RPG de ação ambientado na Era Viking.', 'PC', 199.90, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2208920/header.jpg'),

(1, 'Assassin''s Creed Odyssey', 'RPG de ação ambientado na Grécia Antiga.', 'PC', 199.90, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/812140/header.jpg'),

(6, 'Far Cry 6', 'FPS de ação em mundo aberto.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2369390/header.jpg'),

(4, 'Resident Evil 4', 'Jogo de horror e ação com elementos de sobrevivência.', 'PC', 169.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2050650/header.jpg'),

(4, 'Resident Evil Village', 'Jogo de horror e sobrevivência.', 'PC', 139.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1196590/header.jpg'),

(4, 'Dead Space', 'Horror de sobrevivência ambientado em uma nave espacial.', 'PC', 249.90, 8, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1693980/header.jpg'),

(1, 'Hogwarts Legacy', 'RPG de aventura ambientado no universo de Harry Potter.', 'PC', 249.90, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/990080/header.jpg'),

(3, 'Star Wars Jedi: Survivor', 'Aventura de ação ambientada no universo Star Wars.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1774580/header.jpg'),

(1, 'Baldur''s Gate 3', 'RPG baseado em regras de Dungeons & Dragons.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1086940/header.jpg'),

(1, 'Diablo IV', 'RPG de ação com combate e exploração.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2344520/header.jpg'),

(1, 'Monster Hunter: World', 'RPG de ação focado em caça e exploração.', 'PC', 139.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/582010/header.jpg'),

(1, 'Monster Hunter Wilds', 'RPG de ação focado em caça de monstros.', 'PC', 299.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2246340/header.jpg'),

(7, 'Forza Horizon 5', 'Jogo de corrida em mundo aberto.', 'PC', 249.00, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1551360/header.jpg'),

(7, 'Need for Speed Heat', 'Jogo de corrida focado em carros e perseguições.', 'PC', 199.90, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1222680/header.jpg'),

(7, 'EA Sports FC 26', 'Simulador de futebol.', 'PC', 349.90, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/3603210/header.jpg'),

(7, 'NBA 2K26', 'Simulador de basquete.', 'PC', 349.90, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/3472040/header.jpg'),

(7, 'F1 26', 'Simulador de corrida de Fórmula 1.', 'PC', 349.90, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/3059520/header.jpg'),

(7, 'Rocket League', 'Jogo que combina futebol e carros.', 'PC', 0.00, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/252950/header.jpg'),

(6, 'Fortnite', 'Battle royale e jogo de tiro multiplayer.', 'PC', 0.00, 20, 'https://images.igdb.com/igdb/image/upload/t_cover_big/co49wj.jpg'),

(6, 'Counter-Strike 2', 'FPS competitivo e tático multiplayer.', 'PC', 0.00, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/730/header.jpg'),

(6, 'Valorant', 'FPS tático competitivo com personagens e habilidades.', 'PC', 0.00, 20, 'https://images.igdb.com/igdb/image/upload/t_cover_big/co2mvt.jpg'),

(6, 'Overwatch 2', 'FPS multiplayer baseado em heróis.', 'PC', 0.00, 20, 'https://images.igdb.com/igdb/image/upload/t_cover_big/co4jni.jpg'),

(6, 'Apex Legends', 'FPS battle royale multiplayer.', 'PC', 0.00, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1172470/header.jpg'),

(6, 'Rainbow Six Siege', 'FPS tático multiplayer.', 'PC', 79.90, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/359550/header.jpg'),

(6, 'PUBG: Battlegrounds', 'Battle royale multiplayer.', 'PC', 0.00, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/578080/header.jpg'),

(5, 'Terraria', 'Sandbox de aventura, exploração e sobrevivência.', 'PC', 19.99, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/105600/header.jpg'),

(1, 'Stardew Valley', 'RPG e simulador de fazenda.', 'PC', 24.99, 15, 'https://cdn.cloudflare.steamstatic.com/steam/apps/413150/header.jpg'),

(2, 'Hades', 'Roguelike de ação baseado na mitologia grega.', 'PC', 73.99, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1145360/header.jpg'),

(3, 'Hollow Knight', 'Aventura de exploração em um mundo subterrâneo.', 'PC', 46.99, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/367520/header.jpg'),

(2, 'Cuphead', 'Jogo de ação e plataforma com estilo de animação clássica.', 'PC', 36.99, 12, 'https://cdn.cloudflare.steamstatic.com/steam/apps/268910/header.jpg'),

(3, 'It Takes Two', 'Aventura cooperativa para dois jogadores.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1426210/header.jpg'),

(7, 'Fall Guys', 'Jogo multiplayer de competição e desafios.', 'PC', 0.00, 20, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1097150/header.jpg');