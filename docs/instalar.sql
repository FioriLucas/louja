CREATE DATABASE IF NOT EXISTS louja 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE louja;

-- 1. Apaga as tabelas antigas na ordem correta para recriar do zero sem erros
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS jogos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS usuarios;
SET FOREIGN_KEY_CHECKS = 1;

-- 2. Tabela de Usuários
CREATE TABLE usuarios (
    usr_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    perfil ENUM('cliente', 'admin') DEFAULT 'cliente'
);

INSERT INTO usuarios (nome, email, senha, perfil)
VALUES (
    'Administrador',
    'admin@louja.com',
    '$2y$10$sPN1FRZP84eiYnGpr7mOsePRgEFFhHkb7hUL3KKUzEwQJ26S6HkKm',
    'admin'
)
ON DUPLICATE KEY UPDATE
    nome = 'Administrador',
    senha = '$2y$10$sPN1FRZP84eiYnGpr7mOsePRgEFFhHkb7hUL3KKUzEwQJ26S6HkKm',
    perfil = 'admin';

-- 3. Tabela de Categorias
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

INSERT INTO categorias (categoria_id, nome) VALUES
(1, 'RPG'),
(2, 'Ação'),
(3, 'Aventura'),
(4, 'Horror'),
(5, 'Sobrevivência'),
(6, 'FPS'),
(7, 'Esportes');

-- 4. Tabela de Jogos (com UNIQUE no título para nunca duplicar)
CREATE TABLE jogos (
    jogo_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL UNIQUE,
    descricao TEXT,
    plataforma VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT DEFAULT 0,
    img_url VARCHAR(255),
    ativo TINYINT(1) DEFAULT 1,
    destaque_carrossel TINYINT(1) DEFAULT 0,

    FOREIGN KEY (categoria_id)
        REFERENCES categorias(categoria_id)
);

-- 5. Tabela de Pedidos
CREATE TABLE pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    usr_id INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pendente', 'pago', 'enviado', 'cancelado') DEFAULT 'pendente',
    forma_pagamento ENUM('cartao', 'pix', 'boleto') NOT NULL DEFAULT 'pix',
    dados_cliente_verificados TINYINT(1) NOT NULL DEFAULT 0,
    dados_verificados_por INT DEFAULT NULL,
    dados_verificados_em DATETIME DEFAULT NULL,
    valor_total DECIMAL(10,2) DEFAULT 0.00,

    FOREIGN KEY (usr_id)
        REFERENCES usuarios(usr_id)
        ON DELETE CASCADE
);

-- 6. Tabela de Itens do Pedido
CREATE TABLE itens_pedido (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    jogo_id INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id)
        ON DELETE CASCADE,
    FOREIGN KEY (jogo_id)
        REFERENCES jogos(jogo_id)
        ON DELETE CASCADE
);

-- 7. Inserção dos 100 Jogos (Com URLs das imagens atualizadas)
INSERT INTO jogos
(categoria_id, titulo, descricao, plataforma, preco, quantidade_estoque, img_url, destaque_carrossel)
VALUES
(5, 'Minecraft', 'Jogo sandbox de sobrevivência e construção.', 'PC', 99.00, 20, 'https://sm.ign.com/ign_br/screenshot/default/tmp-cgtjz0-bb7faa1483782db2-minecraft-horizontal-key-art_n1te.jpg', 1),
(2, 'Grand Theft Auto V', 'Jogo de ação e mundo aberto.', 'PC', 99.90, 15, 'https://assetsio.gnwcdn.com/eurogamer-zjp1vx.jpg?width=1200&height=600&fit=crop&enable=upscale&auto=webp', 1),
(2, 'Red Dead Redemption 2', 'Aventura de ação em mundo aberto ambientada no Velho Oeste.', 'PC', 299.90, 10, 'https://cdn2.unrealengine.com/Diesel/productv2/heather/home/EGS_RockstarGames_RedDeadRedemption2_G1A_00-1920x1080-308f101576da37225c889173094f373f2afc56c1.jpg', 1),
(1, 'The Witcher 3: Wild Hunt', 'RPG de mundo aberto com exploração e narrativa.', 'PC', 149.99, 12, 'https://assets.nintendo.com/image/upload/c_fill,w_1200/q_auto:best/f_auto/dpr_2.0/store/software/switch2/70010000128692/da1a51c79e918768af5d1556e7416c0bc906665606fd273622ecbbd5cc8cfa26', 1),
(1, 'Cyberpunk 2077', 'RPG de ação ambientado em um futuro distópico.', 'PC', 199.90, 12, 'https://image.api.playstation.com/vulcan/ap/rnd/202111/3013/bxSj4jO0KBqUgAbH3zuNjCje.jpg', 1),
(1, 'Elden Ring', 'RPG de ação em um vasto mundo de fantasia.', 'PC', 229.90, 10, 'https://image.api.playstation.com/vulcan/ap/rnd/202110/2000/YMUoJUYNX0xWk6eTKuZLr5Iw.jpg', 1),
(4, 'Resident Evil 4', 'Jogo de horror e ação com elementos de sobrevivência.', 'PC', 169.90, 10, 'https://assets.nintendo.com/image/upload/q_auto/f_auto/store/software/switch/70010000012858/f4d4fd20c956621c4a342a8cade2e366f0e3cd43765bb52eccd0fea32b1606ce', 1),
(7, 'Forza Horizon 5', 'Jogo de corrida em mundo aberto.', 'PC', 249.00, 15, 'https://image.api.playstation.com/vulcan/ap/rnd/202501/2717/0c5df2b67b23263d055f3b78aeb77a6ce4668bb078fced77.jpg', 1),
(2, 'God of War', 'Aventura de ação baseada na mitologia nórdica.', 'PC', 199.90, 15, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1593500/library_600x900_2x.jpg', 0),
(2, 'God of War Ragnarök', 'Aventura de ação com Kratos e Atreus.', 'PC', 249.90, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2322010/library_600x900_2x.jpg', 0),
(2, 'Marvel''s Spider-Man Remastered', 'Aventura de ação baseada no Homem-Aranha.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1817070/library_600x900_2x.jpg', 0),
(2, 'Marvel''s Spider-Man 2', 'Aventura de ação com Peter Parker e Miles Morales.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2651280/library_600x900_2x.jpg', 0),
(1, 'Horizon Zero Dawn', 'RPG de ação em um mundo pós-apocalíptico.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1151640/library_600x900_2x.jpg', 0),
(1, 'Horizon Forbidden West', 'RPG de ação e exploração em mundo aberto.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2420110/library_600x900_2x.jpg', 0),
(2, 'The Last of Us Part I', 'Aventura de ação focada em narrativa e sobrevivência.', 'PC', 249.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1888930/library_600x900_2x.jpg', 0),
(2, 'The Last of Us Part II', 'Aventura de ação focada em narrativa.', 'PC', 249.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2531310/library_600x900_2x.jpg', 0),
(3, 'Uncharted: Legacy of Thieves Collection', 'Aventura de ação com exploração e enigmas.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1659420/library_600x900_2x.jpg', 0),
(2, 'Ghost of Tsushima', 'Ação e exploração no Japão feudal.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2215430/library_600x900_2x.jpg', 0),
(1, 'Assassin''s Creed Valhalla', 'RPG de ação ambientado na Era Viking.', 'PC', 199.90, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2208920/library_600x900_2x.jpg', 0),
(1, 'Assassin''s Creed Odyssey', 'RPG de ação ambientado na Grécia Antiga.', 'PC', 199.90, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/812140/library_600x900_2x.jpg', 0),
(6, 'Far Cry 6', 'FPS de ação em mundo aberto.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2369390/library_600x900_2x.jpg', 0),
(4, 'Resident Evil Village', 'Jogo de horror e sobrevivência.', 'PC', 139.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1196590/library_600x900_2x.jpg', 0),
(4, 'Dead Space', 'Horror de sobrevivência ambientado no espaço.', 'PC', 249.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1693980/library_600x900_2x.jpg', 0),
(1, 'Hogwarts Legacy', 'RPG de aventura ambientado no universo de Harry Potter.', 'PC', 249.90, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/990080/library_600x900_2x.jpg', 0),
(3, 'Star Wars Jedi: Survivor', 'Aventura de ação ambientada no universo Star Wars.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1774580/library_600x900_2x.jpg', 0),
(1, 'Baldur''s Gate 3', 'RPG baseado no universo de Dungeons & Dragons.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1086940/library_600x900_2x.jpg', 0),
(1, 'Diablo IV', 'RPG de ação com combate e exploração.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2344520/library_600x900_2x.jpg', 0),
(1, 'Monster Hunter: World', 'RPG de ação focado em caça e exploração.', 'PC', 139.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/582010/library_600x900_2x.jpg', 0),
(1, 'Monster Hunter Wilds', 'RPG de ação focado em caça de monstros.', 'PC', 299.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2246340/library_600x900_2x.jpg', 0),
(7, 'Need for Speed Heat', 'Jogo de corrida focado em carros e perseguições.', 'PC', 199.90, 15, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1222680/library_600x900_2x.jpg', 0),
(6, 'Rainbow Six Siege', 'FPS tático multiplayer.', 'PC', 79.90, 15, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/359550/library_600x900_2x.jpg', 0),
(5, 'Terraria', 'Sandbox de aventura, exploração e sobrevivência.', 'PC', 19.99, 15, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/105600/library_600x900_2x.jpg', 0),
(1, 'Stardew Valley', 'RPG e simulador de fazenda.', 'PC', 24.99, 15, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/413150/library_600x900_2x.jpg', 0),
(2, 'Hades', 'Roguelike de ação baseado na mitologia grega.', 'PC', 73.99, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900_2x.jpg', 0),
(3, 'Hollow Knight', 'Aventura de exploração em um mundo subterrâneo.', 'PC', 46.99, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/367520/library_600x900_2x.jpg', 0),
(2, 'Cuphead', 'Jogo de ação e plataforma com estilo de animação clássica.', 'PC', 36.99, 12, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/268910/library_600x900_2x.jpg', 0),
(3, 'It Takes Two', 'Aventura cooperativa para dois jogadores.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1426210/library_600x900_2x.jpg', 0),
(2, 'Sekiro: Shadows Die Twice', 'Jogo de ação com combate baseado em espadas.', 'PC', 274.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/814380/library_600x900_2x.jpg', 0),
(1, 'Dark Souls III', 'RPG de ação conhecido por sua dificuldade.', 'PC', 229.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/374320/library_600x900_2x.jpg', 0),
(1, 'Dark Souls Remastered', 'RPG de ação e fantasia sombria.', 'PC', 199.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/570940/library_600x900_2x.jpg', 0),
(1, 'Dark Souls II: Scholar of the First Sin', 'RPG de ação em um mundo sombrio.', 'PC', 149.90, 8, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/335300/library_600x900_2x.jpg', 0),
(1, 'Black Myth: Wukong', 'RPG de ação inspirado na mitologia chinesa.', 'PC', 299.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2358720/library_600x900_2x.jpg', 0),
(1, 'Lies of P', 'RPG de ação inspirado na história de Pinóquio.', 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1627720/library_600x900_2x.jpg', 0),
(2, 'Sifu', 'Jogo de ação focado em artes marciais.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2138710/library_600x900_2x.jpg', 0),
(3, 'Stray', 'Aventura em um mundo futurista habitado por robôs.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1332010/library_600x900_2x.jpg', 0),
(2, 'Days Gone', 'Aventura de ação em um mundo pós-apocalíptico.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1259420/library_600x900_2x.jpg', 0),
(3, 'DEATH STRANDING DIRECTOR''S CUT', 'Aventura de exploração e entrega em um mundo devastado.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1850570/library_600x900_2x.jpg', 0),
(2, 'Control Ultimate Edition', 'Ação e aventura com elementos sobrenaturais.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/870780/library_600x900_2x.jpg', 0),
(6, 'DOOM Eternal', 'FPS de ação em ritmo acelerado.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/782330/library_600x900_2x.jpg', 0),
(6, 'DOOM', 'FPS de ação ambientado em um complexo futurista.', 'PC', 129.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/379720/library_600x900_2x.jpg', 0),
(6, 'Titanfall 2', 'FPS com campanha e partidas multiplayer.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1237970/library_600x900_2x.jpg', 0),
(6, 'Battlefield 1', 'FPS ambientado durante a Primeira Guerra Mundial.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1238840/library_600x900_2x.jpg', 0),
(6, 'Battlefield V', 'FPS multiplayer ambientado na Segunda Guerra Mundial.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1238810/library_600x900_2x.jpg', 0),
(6, 'Battlefield 2042', 'FPS multiplayer ambientado em um futuro próximo.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1517290/library_600x900_2x.jpg', 0),
(2, 'Borderlands 3', 'RPG de ação com exploração e cooperação.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/397540/library_600x900_2x.jpg', 0),
(1, 'Tiny Tina''s Wonderlands', 'RPG de ação e fantasia.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1286680/library_600x900_2x.jpg', 0),
(6, 'Metro Exodus', 'FPS de sobrevivência em um mundo pós-apocalíptico.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/412020/library_600x900_2x.jpg', 0),
(5, 'Dying Light', 'Sobrevivência e exploração em uma cidade infestada.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239140/library_600x900_2x.jpg', 0),
(5, 'Dying Light 2 Stay Human', 'Aventura de sobrevivência em um mundo pós-apocalíptico.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/534380/library_600x900_2x.jpg', 0),
(5, 'Subnautica', 'Sobrevivência e exploração em um planeta oceânico.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/264710/library_600x900_2x.jpg', 0),
(5, 'Subnautica: Below Zero', 'Sobrevivência e exploração em uma região congelada.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/848450/library_600x900_2x.jpg', 0),
(5, 'No Man''s Sky', 'Exploração e sobrevivência em um universo procedural.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/275850/library_600x900_2x.jpg', 0),
(5, 'Grounded', 'Aventura e sobrevivência em um quintal gigantesco.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/962130/library_600x900_2x.jpg', 0),
(5, 'The Long Dark', 'Sobrevivência em um ambiente selvagem e congelado.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/305620/library_600x900_2x.jpg', 0),
(5, 'Sons Of The Forest', 'Sobrevivência e exploração em uma ilha misteriosa.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1326470/library_600x900_2x.jpg', 0),
(5, 'Valheim', 'Sobrevivência e exploração em um mundo inspirado na mitologia nórdica.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/892970/library_600x900_2x.jpg', 0),
(5, 'Palworld', 'Sobrevivência, exploração e construção em mundo aberto.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1623730/library_600x900_2x.jpg', 0),
(5, 'Raft', 'Sobrevivência e exploração em alto-mar.', 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/648800/library_600x900_2x.jpg', 0),
(5, 'Project Zomboid', 'RPG de sobrevivência em um mundo pós-apocalíptico.', 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/108600/library_600x900_2x.jpg', 0),
(5, 'Factorio', 'Construção e gerenciamento de fábricas.', 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/427520/library_600x900_2x.jpg', 0),
(5, 'Satisfactory', 'Construção e gerenciamento de fábricas em primeira pessoa.', 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/526870/library_600x900_2x.jpg', 0),
(3, 'DAVE THE DIVER', 'Aventura, exploração submarina e gerenciamento de restaurante.', 'PC', 99.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1868140/header.jpg', 0),
(1, 'Sea of Stars', 'RPG inspirado nos clássicos do gênero.', 'PC', 149.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1244090/header.jpg', 0),
(1, 'Balatro', 'Roguelike baseado em combinações de cartas.', 'PC', 49.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2379780/header.jpg', 0),
(1, 'Slay the Spire', 'Roguelike estratégico baseado em cartas.', 'PC', 49.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/646570/header.jpg', 0),
(3, 'Celeste', 'Jogo de plataforma e aventura.', 'PC', 59.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/504230/header.jpg', 0),
(1, 'Undertale', 'RPG independente focado em personagens e escolhas.', 'PC', 39.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/391540/header.jpg', 0),
(3, 'Ori and the Blind Forest: Definitive Edition', 'Aventura e plataforma em um mundo fantástico.', 'PC', 59.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/387290/header.jpg', 0),
(3, 'Ori and the Will of the Wisps', 'Aventura e plataforma com exploração.', 'PC', 99.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1057090/header.jpg', 0),
(1, 'Persona 5 Royal', 'RPG japonês focado em história e relacionamentos.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1687950/header.jpg', 0),
(1, 'Persona 4 Golden', 'RPG japonês com investigação e relacionamentos.', 'PC', 99.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1113000/header.jpg', 0),
(1, 'Final Fantasy VII Remake Intergrade', 'RPG de ação baseado em um clássico da franquia.', 'PC', 349.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1462040/header.jpg', 0),
(1, 'FINAL FANTASY XV WINDOWS EDITION', 'RPG de ação e aventura em mundo aberto.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/637650/header.jpg', 0),
(2, 'Yakuza: Like a Dragon', 'RPG de ação com história e combate por turnos.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1235140/header.jpg', 0),
(2, 'Like a Dragon: Infinite Wealth', 'RPG de aventura com história e exploração.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/2072450/header.jpg', 0),
(2, 'TEKKEN 8', 'Jogo de luta competitivo.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1778820/header.jpg', 0),
(2, 'Street Fighter 6', 'Jogo de luta com diversos modos de jogo.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/header.jpg', 0),
(2, 'Mortal Kombat 1', 'Jogo de luta com diversos personagens.', 'PC', 249.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1971870/header.jpg', 0),
(3, 'LEGO Star Wars: The Skywalker Saga', 'Aventura baseada na saga Star Wars.', 'PC', 149.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/920210/header.jpg', 0),
(3, 'A Plague Tale: Requiem', 'Aventura narrativa ambientada em um período histórico.', 'PC', 199.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/1182900/header.jpg', 0),
(3, 'A Plague Tale: Innocence', 'Aventura narrativa com exploração e sobrevivência.', 'PC', 149.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/752590/header.jpg', 0),
(3, 'Tomb Raider', 'Aventura de ação e exploração.', 'PC', 99.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/203160/header.jpg', 0),
(3, 'Rise of the Tomb Raider', 'Aventura de ação e exploração.', 'PC', 149.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/391220/header.jpg', 0),
(3, 'Shadow of the Tomb Raider', 'Aventura de ação em ambientes variados.', 'PC', 149.90, 10, 'https://cdn.cloudflare.steamstatic.com/steam/apps/750920/header.jpg', 0),
(2, 'Mafia: Definitive Edition', 'Aventura de ação ambientada em uma cidade dos anos 1930.', 'PC', 199.90, 10, 'https://cdn1.epicgames.com/ee8802651a004c48999169fa32eb4903/offer/EGS_MafiaDefinitiveEditionPreOrder_Hangar13_S2-1200x1600-3674a5caa0e10eca89feb4dba0484112.jpg', 0),
(2, 'Mafia II: Definitive Edition', 'Aventura de ação com narrativa cinematográfica.', 'PC', 149.90, 10, 'https://assets-prd.ignimgs.com/2020/07/07/mafia-ii-button-fin-1594154630039.jpg?crop=1%3A1%2Csmart&format=jpg&auto=webp&quality=80', 0),
(1, 'Kingdom Come: Deliverance II', 'RPG de ação ambientado na Europa medieval.', 'PC', 299.90, 10, 'https://image.api.playstation.com/vulcan/ap/rnd/202408/1208/05a84ce968125d79fa36484c5a756a1c8d9b05622aae21c1.png', 0),
(1, 'Dragon''s Dogma 2', 'RPG de ação com exploração e combate.', 'PC', 299.90, 10, 'https://image.api.playstation.com/vulcan/ap/rnd/202305/3007/2fff756fa904befe46b838dd6f27fa49f6b53d9f3dbbb776.png', 0),
(2, 'Hades II', 'Roguelike de ação com mitologia grega.', 'PC', 99.90, 10, 'https://image.api.playstation.com/vulcan/ap/rnd/202603/2318/cabc65dfd2ab1ffa31f51b20b7128ac69491ea9858c0daa3.png', 0),
(3, 'Cult of the Lamb', 'Aventura e gerenciamento com elementos roguelike.', 'PC', 99.90, 10, 'https://image.api.playstation.com/vulcan/ap/rnd/202512/1518/ea3296f59652aea59db01dd6668c93f1dd23102f84d18807.png', 0);