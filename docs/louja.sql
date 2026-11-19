CREATE DATABASE IF NOT EXISTS louja 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE louja;

-- 1. Apaga as tabelas antigas na ordem correta para recriar do zero sem erros
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS jogo_categorias;
DROP TABLE IF EXISTS jogo_plataformas;
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
    forma_pagamento_preferida ENUM('cartao', 'pix', 'boleto') NOT NULL DEFAULT 'pix',
    perfil ENUM('cliente', 'admin') DEFAULT 'cliente',
    foto_perfil VARCHAR(255) DEFAULT NULL
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

-- ============================================================
-- RELACOES DE GENEROS E PLATAFORMAS
-- ============================================================
-- Execute depois de importar louja.sql. Pode ser executado novamente sem duplicar relações.
INSERT INTO categorias (nome)
SELECT generos.nome
FROM (
    SELECT 'Corrida' AS nome
    UNION ALL SELECT 'Estratégia'
    UNION ALL SELECT 'Luta'
    UNION ALL SELECT 'Metroidvania'
    UNION ALL SELECT 'Plataforma'
    UNION ALL SELECT 'Roguelike'
    UNION ALL SELECT 'Simulação'
) AS generos
WHERE NOT EXISTS (
    SELECT 1
    FROM categorias
    WHERE categorias.nome = generos.nome
);

CREATE TABLE IF NOT EXISTS jogo_plataformas (
    jogo_id INT NOT NULL,
    plataforma VARCHAR(50) NOT NULL,
    PRIMARY KEY (jogo_id, plataforma),
    CONSTRAINT fk_jogo_plataformas_jogo
        FOREIGN KEY (jogo_id) REFERENCES jogos(jogo_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS jogo_categorias (
    jogo_id INT NOT NULL,
    categoria_id INT NOT NULL,
    PRIMARY KEY (jogo_id, categoria_id),
    CONSTRAINT fk_jogo_categorias_jogo
        FOREIGN KEY (jogo_id) REFERENCES jogos(jogo_id) ON DELETE CASCADE,
    CONSTRAINT fk_jogo_categorias_categoria
        FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO jogo_plataformas (jogo_id, plataforma)
SELECT jogo_id, plataforma
FROM jogos
WHERE plataforma IS NOT NULL AND TRIM(plataforma) <> '';

INSERT IGNORE INTO jogo_categorias (jogo_id, categoria_id)
SELECT jogo_id, categoria_id
FROM jogos
WHERE categoria_id IS NOT NULL;

CREATE TEMPORARY TABLE catalogo_generos (
    titulo VARCHAR(150) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    PRIMARY KEY (titulo, genero)
) ENGINE=MEMORY;

INSERT IGNORE INTO catalogo_generos (titulo, genero) VALUES
('Minecraft', 'Aventura'), ('Minecraft', 'RPG'),
('Grand Theft Auto V', 'Aventura'), ('Grand Theft Auto V', 'Corrida'),
('Red Dead Redemption 2', 'Aventura'), ('Red Dead Redemption 2', 'RPG'),
('The Witcher 3: Wild Hunt', 'Ação'), ('The Witcher 3: Wild Hunt', 'Aventura'),
('Cyberpunk 2077', 'Ação'), ('Cyberpunk 2077', 'Aventura'),
('Elden Ring', 'Ação'), ('Elden Ring', 'Aventura'),
('Resident Evil 4', 'Ação'), ('Resident Evil 4', 'Sobrevivência'),
('Forza Horizon 5', 'Corrida'),
('God of War', 'Aventura'), ('God of War Ragnarök', 'Aventura'),
('Marvel''s Spider-Man Remastered', 'Aventura'), ('Marvel''s Spider-Man 2', 'Aventura'),
('Horizon Zero Dawn', 'Ação'), ('Horizon Zero Dawn', 'Aventura'),
('Horizon Forbidden West', 'Ação'), ('Horizon Forbidden West', 'Aventura'),
('The Last of Us Part I', 'Aventura'), ('The Last of Us Part I', 'Sobrevivência'),
('The Last of Us Part II', 'Aventura'), ('The Last of Us Part II', 'Sobrevivência'),
('Uncharted: Legacy of Thieves Collection', 'Aventura'),
('Ghost of Tsushima', 'Aventura'),
('Assassin''s Creed Valhalla', 'Ação'), ('Assassin''s Creed Valhalla', 'Aventura'),
('Assassin''s Creed Odyssey', 'Ação'), ('Assassin''s Creed Odyssey', 'Aventura'),
('Far Cry 6', 'Ação'), ('Far Cry 6', 'Aventura'),
('Resident Evil Village', 'Sobrevivência'),
('Dead Space', 'Sobrevivência'),
('Hogwarts Legacy', 'Ação'), ('Hogwarts Legacy', 'Aventura'),
('Star Wars Jedi: Survivor', 'Aventura'),
('Baldur''s Gate 3', 'Aventura'),
('Diablo IV', 'Ação'), ('Diablo IV', 'Aventura'),
('Monster Hunter: World', 'Ação'), ('Monster Hunter: World', 'Aventura'),
('Monster Hunter Wilds', 'Ação'), ('Monster Hunter Wilds', 'Aventura'),
('Need for Speed Heat', 'Corrida'),
('Rainbow Six Siege', 'Ação'),
('Terraria', 'Aventura'), ('Terraria', 'RPG'),
('Stardew Valley', 'Aventura'), ('Stardew Valley', 'RPG'),
('Hades', 'Ação'), ('Hades', 'Roguelike'),
('Hollow Knight', 'Ação'), ('Hollow Knight', 'Aventura'), ('Hollow Knight', 'Metroidvania'),
('Cuphead', 'Ação'), ('Cuphead', 'Plataforma'),
('It Takes Two', 'Plataforma'),
('Sekiro: Shadows Die Twice', 'Aventura'),
('Dark Souls III', 'Ação'), ('Dark Souls III', 'Aventura'),
('Dark Souls Remastered', 'Ação'), ('Dark Souls Remastered', 'Aventura'),
('Dark Souls II: Scholar of the First Sin', 'Ação'),
('Dark Souls II: Scholar of the First Sin', 'Aventura'),
('Black Myth: Wukong', 'Aventura'),
('Lies of P', 'Ação'), ('Lies of P', 'Aventura'),
('Sifu', 'Luta'), ('Sifu', 'Aventura'),
('Stray', 'Aventura'),
('Days Gone', 'Ação'), ('Days Gone', 'Sobrevivência'),
('DEATH STRANDING DIRECTOR''S CUT', 'Aventura'),
('Control Ultimate Edition', 'Aventura'),
('DOOM Eternal', 'Ação'), ('DOOM Eternal', 'FPS'),
('DOOM', 'Ação'),
('Titanfall 2', 'Ação'),
('Battlefield 1', 'Ação'), ('Battlefield V', 'Ação'),
('Battlefield 2042', 'Ação'),
('Borderlands 3', 'Ação'), ('Borderlands 3', 'FPS'),
('Tiny Tina''s Wonderlands', 'Ação'),
('Metro Exodus', 'Ação'), ('Metro Exodus', 'Sobrevivência'),
('Dying Light', 'Ação'), ('Dying Light', 'Horror'),
('Dying Light 2 Stay Human', 'Ação'), ('Dying Light 2 Stay Human', 'Horror'),
('Subnautica', 'Aventura'), ('Subnautica: Below Zero', 'Aventura'),
('No Man''s Sky', 'Aventura'), ('No Man''s Sky', 'RPG'),
('Grounded', 'Aventura'),
('The Long Dark', 'Aventura'),
('Sons Of The Forest', 'Horror'), ('Sons Of The Forest', 'Aventura'),
('Valheim', 'Aventura'), ('Valheim', 'RPG'),
('Palworld', 'Aventura'), ('Palworld', 'RPG'),
('Raft', 'Aventura'),
('Project Zomboid', 'RPG'), ('Project Zomboid', 'Horror'),
('Factorio', 'Estratégia'), ('Satisfactory', 'Estratégia'),
('DAVE THE DIVER', 'Simulação'),
('Sea of Stars', 'Aventura'),
('Balatro', 'Roguelike'),
('Slay the Spire', 'Roguelike'),
('Celeste', 'Plataforma'),
('Undertale', 'Aventura'),
('Ori and the Blind Forest: Definitive Edition', 'Metroidvania'),
('Ori and the Will of the Wisps', 'Metroidvania'),
('Persona 5 Royal', 'Aventura'),
('Persona 4 Golden', 'Aventura'),
('Final Fantasy VII Remake Intergrade', 'Ação'),
('FINAL FANTASY XV WINDOWS EDITION', 'Ação'),
('Yakuza: Like a Dragon', 'RPG'), ('Yakuza: Like a Dragon', 'Aventura'),
('Like a Dragon: Infinite Wealth', 'RPG'), ('Like a Dragon: Infinite Wealth', 'Aventura'),
('TEKKEN 8', 'Luta'), ('Street Fighter 6', 'Luta'), ('Mortal Kombat 1', 'Luta'),
('LEGO Star Wars: The Skywalker Saga', 'Ação'),
('A Plague Tale: Requiem', 'Ação'), ('A Plague Tale: Requiem', 'Sobrevivência'),
('A Plague Tale: Innocence', 'Ação'), ('A Plague Tale: Innocence', 'Sobrevivência'),
('Tomb Raider', 'Ação'), ('Tomb Raider', 'Plataforma'),
('Rise of the Tomb Raider', 'Ação'), ('Rise of the Tomb Raider', 'Plataforma'),
('Shadow of the Tomb Raider', 'Ação'), ('Shadow of the Tomb Raider', 'Plataforma'),
('Mafia: Definitive Edition', 'Aventura'), ('Mafia II: Definitive Edition', 'Aventura'),
('Kingdom Come: Deliverance II', 'Aventura'),
('Dragon''s Dogma 2', 'Aventura'),
('Hades II', 'Ação'), ('Hades II', 'Roguelike'),
('Cult of the Lamb', 'Roguelike'), ('Cult of the Lamb', 'Simulação'),
('Portal 2', 'Aventura'), ('Portal', 'Aventura'),
('Half-Life 2', 'Ação'), ('Half-Life: Alyx', 'Ação'),
('Left 4 Dead 2', 'Ação'), ('Left 4 Dead 2', 'Sobrevivência'),
('Killing Floor 2', 'Ação'), ('Killing Floor 2', 'Horror'),
('PAYDAY 2', 'Ação'),
('The Elder Scrolls V: Skyrim Special Edition', 'Ação'),
('Fallout 4', 'Ação'), ('Fallout 4', 'Aventura'),
('Fallout: New Vegas', 'Ação'), ('Fallout: New Vegas', 'Aventura'),
('The Elder Scrolls IV: Oblivion', 'Ação'),
('The Elder Scrolls III: Morrowind', 'Ação'),
('Divinity: Original Sin 2', 'Aventura'),
('Divinity: Original Sin', 'Aventura'),
('Pillars of Eternity', 'Aventura'),
('Pathfinder: Wrath of the Righteous', 'Aventura'),
('Dragon Age: Inquisition', 'Ação'), ('Dragon Age: Inquisition', 'Aventura'),
('Mass Effect Legendary Edition', 'Ação'), ('Mass Effect Legendary Edition', 'Aventura'),
('Dragon Age: Origins', 'Aventura'),
('Kingdoms of Amalur: Re-Reckoning', 'Ação'), ('Kingdoms of Amalur: Re-Reckoning', 'Aventura'),
('GreedFall', 'Ação'), ('GreedFall', 'Aventura'),
('Outward Definitive Edition', 'Aventura'), ('Outward Definitive Edition', 'Sobrevivência'),
('The Outer Worlds', 'Ação'), ('The Outer Worlds', 'Aventura'),
('Wasteland 3', 'Estratégia'), ('Wasteland 3', 'Aventura'),
('Disco Elysium - The Final Cut', 'Aventura'),
('Risk of Rain 2', 'Ação'), ('Risk of Rain 2', 'Roguelike'),
('Dead Cells', 'Ação'), ('Dead Cells', 'Metroidvania'), ('Dead Cells', 'Roguelike'),
('Enter the Gungeon', 'Ação'), ('Enter the Gungeon', 'Roguelike'),
('The Binding of Isaac: Rebirth', 'Roguelike'),
('Rogue Legacy 2', 'Ação'), ('Rogue Legacy 2', 'Roguelike'),
('Darkest Dungeon', 'Estratégia'), ('Darkest Dungeon', 'Roguelike'),
('Into the Breach', 'Estratégia'), ('FTL: Faster Than Light', 'Estratégia'),
('Sid Meier''s Civilization VI', 'Estratégia'),
('Age of Empires II: Definitive Edition', 'Estratégia'),
('Age of Empires IV', 'Estratégia'), ('Total War: WARHAMMER III', 'Estratégia'),
('XCOM 2', 'Estratégia'), ('Sid Meier''s Civilization V', 'Estratégia'),
('Cities: Skylines', 'Estratégia'), ('Cities: Skylines', 'Simulação'),
('Planet Coaster', 'Estratégia'), ('Planet Coaster', 'Simulação'),
('Planet Zoo', 'Estratégia'), ('Planet Zoo', 'Simulação'),
('Euro Truck Simulator 2', 'Simulação'), ('American Truck Simulator', 'Simulação'),
('F1 24', 'Corrida'), ('Assetto Corsa', 'Corrida'), ('DiRT Rally 2.0', 'Corrida'),
('Wreckfest', 'Corrida'), ('MotoGP 24', 'Corrida'),
('EA SPORTS FC 25', 'Esportes'), ('Football Manager 2024', 'Estratégia'),
('Football Manager 2024', 'Esportes'), ('WWE 2K24', 'Luta'),
('Golf With Your Friends', 'Esportes'), ('Tony Hawk''s Pro Skater 1 + 2', 'Esportes'),
('Riders Republic', 'Esportes'), ('The Crew Motorfest', 'Corrida'),
('Call of Duty: Black Ops III', 'Ação'),
('Ready or Not', 'Ação'), ('Insurgency: Sandstorm', 'Ação'),
('Squad', 'Ação'), ('Arma 3', 'Ação'), ('Hell Let Loose', 'Ação'),
('Sniper Elite 5', 'Ação'), ('Sniper Elite 5', 'FPS'),
('Total War: Three Kingdoms', 'Estratégia'),
('Back 4 Blood', 'Ação'), ('Back 4 Blood', 'FPS'), ('Back 4 Blood', 'Sobrevivência'),
('Battlefield 4', 'Ação'), ('Battlefield 4', 'FPS'),
('Remnant II', 'Ação'), ('Remnant II', 'Aventura'), ('Remnant II', 'RPG'),
('Halo: The Master Chief Collection', 'Ação'),
('Sniper Elite 4', 'Ação'), ('Sniper Elite 4', 'FPS'),
('Wolfenstein: The New Order', 'Ação'), ('Wolfenstein II: The New Colossus', 'Ação'),
('Prey', 'Ação'), ('Prey', 'Sobrevivência'),
('BioShock Remastered', 'Ação'), ('BioShock Infinite', 'Ação'),
('Amnesia: The Dark Descent', 'Sobrevivência'),
('Outlast', 'Sobrevivência'), ('Outlast 2', 'Sobrevivência'),
('SOMA', 'Aventura'), ('SOMA', 'Sobrevivência'),
('Little Nightmares', 'Aventura'), ('Little Nightmares', 'Plataforma'),
('Little Nightmares II', 'Aventura'), ('Little Nightmares II', 'Plataforma'),
('Phasmophobia', 'Sobrevivência'),
('The Forest', 'Aventura'), ('The Forest', 'Horror'),
('Don''t Starve Together', 'Aventura'), ('Don''t Starve Together', 'Roguelike'),
('7 Days to Die', 'Aventura'), ('7 Days to Die', 'Horror'),
('ARK: Survival Ascended', 'Aventura'), ('ARK: Survival Ascended', 'RPG'),
('Green Hell', 'Aventura'),
('Frostpunk', 'Estratégia'), ('Frostpunk', 'Simulação'),
('This War of Mine', 'Estratégia'), ('Oxygen Not Included', 'Estratégia'),
('Oxygen Not Included', 'Simulação'), ('RimWorld', 'Estratégia'), ('RimWorld', 'Simulação'),
('The Witness', 'Aventura'), ('Outer Wilds', 'Aventura'),
('The Stanley Parable: Ultra Deluxe', 'Aventura'),
('Firewatch', 'Aventura'), ('INSIDE', 'Plataforma'), ('LIMBO', 'Plataforma'),
('Journey', 'Aventura'), ('What Remains of Edith Finch', 'Aventura'),
('A Short Hike', 'Aventura'), ('GRIS', 'Plataforma');

INSERT IGNORE INTO jogo_categorias (jogo_id, categoria_id)
SELECT jogos.jogo_id, categorias.categoria_id
FROM catalogo_generos
JOIN jogos ON jogos.titulo = catalogo_generos.titulo
JOIN categorias
    ON categorias.categoria_id = (
        SELECT MIN(categoria_id)
        FROM categorias AS categoriaExistente
        WHERE categoriaExistente.nome = catalogo_generos.genero
    );

DROP TEMPORARY TABLE catalogo_generos;

CREATE TEMPORARY TABLE catalogo_plataformas (
    titulo VARCHAR(150) NOT NULL,
    plataforma VARCHAR(50) NOT NULL,
    PRIMARY KEY (titulo, plataforma)
) ENGINE=MEMORY;

INSERT IGNORE INTO catalogo_plataformas (titulo, plataforma) VALUES
('Minecraft', 'PlayStation 4'), ('Minecraft', 'PlayStation 5'),
('Minecraft', 'Xbox One'), ('Minecraft', 'Xbox Series X|S'), ('Minecraft', 'Nintendo Switch'),
('Grand Theft Auto V', 'PlayStation 4'), ('Grand Theft Auto V', 'PlayStation 5'),
('Grand Theft Auto V', 'Xbox One'), ('Grand Theft Auto V', 'Xbox Series X|S'),
('Red Dead Redemption 2', 'PlayStation 4'), ('Red Dead Redemption 2', 'Xbox One'),
('The Witcher 3: Wild Hunt', 'PlayStation 4'), ('The Witcher 3: Wild Hunt', 'PlayStation 5'),
('The Witcher 3: Wild Hunt', 'Xbox One'), ('The Witcher 3: Wild Hunt', 'Xbox Series X|S'),
('The Witcher 3: Wild Hunt', 'Nintendo Switch'),
('Cyberpunk 2077', 'PlayStation 4'), ('Cyberpunk 2077', 'PlayStation 5'),
('Cyberpunk 2077', 'Xbox One'), ('Cyberpunk 2077', 'Xbox Series X|S'),
('Elden Ring', 'PlayStation 4'), ('Elden Ring', 'PlayStation 5'),
('Elden Ring', 'Xbox One'), ('Elden Ring', 'Xbox Series X|S'),
('Resident Evil 4', 'PlayStation 4'), ('Resident Evil 4', 'PlayStation 5'),
('Resident Evil 4', 'Xbox Series X|S'),
('Forza Horizon 5', 'PlayStation 5'), ('Forza Horizon 5', 'Xbox One'),
('Forza Horizon 5', 'Xbox Series X|S'),
('God of War', 'PlayStation 4'), ('God of War Ragnarök', 'PlayStation 4'),
('God of War Ragnarök', 'PlayStation 5'),
('Marvel''s Spider-Man Remastered', 'PlayStation 5'),
('Marvel''s Spider-Man 2', 'PlayStation 5'),
('Horizon Zero Dawn', 'PlayStation 4'),
('Horizon Forbidden West', 'PlayStation 4'), ('Horizon Forbidden West', 'PlayStation 5'),
('The Last of Us Part I', 'PlayStation 5'),
('The Last of Us Part II', 'PlayStation 4'), ('The Last of Us Part II', 'PlayStation 5'),
('Uncharted: Legacy of Thieves Collection', 'PlayStation 5'),
('Ghost of Tsushima', 'PlayStation 4'), ('Ghost of Tsushima', 'PlayStation 5'),
('Assassin''s Creed Valhalla', 'PlayStation 4'), ('Assassin''s Creed Valhalla', 'PlayStation 5'),
('Assassin''s Creed Valhalla', 'Xbox One'), ('Assassin''s Creed Valhalla', 'Xbox Series X|S'),
('Assassin''s Creed Odyssey', 'PlayStation 4'), ('Assassin''s Creed Odyssey', 'Xbox One'),
('Far Cry 6', 'PlayStation 4'), ('Far Cry 6', 'PlayStation 5'),
('Far Cry 6', 'Xbox One'), ('Far Cry 6', 'Xbox Series X|S'),
('Resident Evil Village', 'PlayStation 4'), ('Resident Evil Village', 'PlayStation 5'),
('Resident Evil Village', 'Xbox One'), ('Resident Evil Village', 'Xbox Series X|S'),
('Dead Space', 'PlayStation 5'), ('Dead Space', 'Xbox Series X|S'),
('Hogwarts Legacy', 'PlayStation 4'), ('Hogwarts Legacy', 'PlayStation 5'),
('Hogwarts Legacy', 'Xbox One'), ('Hogwarts Legacy', 'Xbox Series X|S'),
('Hogwarts Legacy', 'Nintendo Switch'),
('Star Wars Jedi: Survivor', 'PlayStation 4'), ('Star Wars Jedi: Survivor', 'PlayStation 5'),
('Star Wars Jedi: Survivor', 'Xbox One'), ('Star Wars Jedi: Survivor', 'Xbox Series X|S'),
('Baldur''s Gate 3', 'PlayStation 5'), ('Baldur''s Gate 3', 'Xbox Series X|S'),
('Diablo IV', 'PlayStation 4'), ('Diablo IV', 'PlayStation 5'),
('Diablo IV', 'Xbox One'), ('Diablo IV', 'Xbox Series X|S'),
('Monster Hunter: World', 'PlayStation 4'), ('Monster Hunter: World', 'Xbox One'),
('Monster Hunter Wilds', 'PlayStation 5'), ('Monster Hunter Wilds', 'Xbox Series X|S'),
('Need for Speed Heat', 'PlayStation 4'), ('Need for Speed Heat', 'Xbox One'),
('Rainbow Six Siege', 'PlayStation 4'), ('Rainbow Six Siege', 'PlayStation 5'),
('Rainbow Six Siege', 'Xbox One'), ('Rainbow Six Siege', 'Xbox Series X|S'),
('Terraria', 'PlayStation 4'), ('Terraria', 'Xbox One'), ('Terraria', 'Nintendo Switch'),
('Stardew Valley', 'PlayStation 4'), ('Stardew Valley', 'Xbox One'), ('Stardew Valley', 'Nintendo Switch'),
('Hades', 'PlayStation 4'), ('Hades', 'PlayStation 5'),
('Hades', 'Xbox One'), ('Hades', 'Xbox Series X|S'), ('Hades', 'Nintendo Switch'),
('Hollow Knight', 'PlayStation 4'), ('Hollow Knight', 'Xbox One'), ('Hollow Knight', 'Nintendo Switch'),
('Cuphead', 'PlayStation 4'), ('Cuphead', 'Xbox One'), ('Cuphead', 'Nintendo Switch'),
('It Takes Two', 'PlayStation 4'), ('It Takes Two', 'PlayStation 5'),
('It Takes Two', 'Xbox One'), ('It Takes Two', 'Xbox Series X|S'), ('It Takes Two', 'Nintendo Switch'),
('Sekiro: Shadows Die Twice', 'PlayStation 4'), ('Sekiro: Shadows Die Twice', 'Xbox One'),
('Dark Souls III', 'PlayStation 4'), ('Dark Souls III', 'Xbox One'),
('Dark Souls Remastered', 'PlayStation 4'), ('Dark Souls Remastered', 'Xbox One'),
('Dark Souls Remastered', 'Nintendo Switch'),
('Dark Souls II: Scholar of the First Sin', 'PlayStation 4'), ('Dark Souls II: Scholar of the First Sin', 'Xbox One'),
('Black Myth: Wukong', 'PlayStation 5'), ('Lies of P', 'PlayStation 4'), ('Lies of P', 'PlayStation 5'),
('Lies of P', 'Xbox One'), ('Lies of P', 'Xbox Series X|S'),
('Sifu', 'PlayStation 4'), ('Sifu', 'PlayStation 5'), ('Stray', 'PlayStation 4'), ('Stray', 'PlayStation 5'),
('Days Gone', 'PlayStation 4'), ('Control Ultimate Edition', 'PlayStation 4'),
('Control Ultimate Edition', 'PlayStation 5'), ('DOOM Eternal', 'PlayStation 4'),
('DOOM Eternal', 'PlayStation 5'), ('DOOM Eternal', 'Xbox One'), ('DOOM Eternal', 'Xbox Series X|S'),
('DOOM', 'PlayStation 4'), ('DOOM', 'Xbox One'),
('Titanfall 2', 'PlayStation 4'), ('Titanfall 2', 'Xbox One'),
('Battlefield 1', 'PlayStation 4'), ('Battlefield 1', 'Xbox One'),
('Battlefield V', 'PlayStation 4'), ('Battlefield V', 'Xbox One'),
('Battlefield 2042', 'PlayStation 4'), ('Battlefield 2042', 'PlayStation 5'),
('Battlefield 2042', 'Xbox One'), ('Battlefield 2042', 'Xbox Series X|S'),
('Borderlands 3', 'PlayStation 4'), ('Borderlands 3', 'PlayStation 5'),
('Borderlands 3', 'Xbox One'), ('Borderlands 3', 'Xbox Series X|S'),
('Tiny Tina''s Wonderlands', 'PlayStation 4'), ('Tiny Tina''s Wonderlands', 'PlayStation 5'),
('Tiny Tina''s Wonderlands', 'Xbox One'), ('Tiny Tina''s Wonderlands', 'Xbox Series X|S'),
('Metro Exodus', 'PlayStation 4'), ('Metro Exodus', 'PlayStation 5'),
('Metro Exodus', 'Xbox One'), ('Metro Exodus', 'Xbox Series X|S'),
('Dying Light', 'PlayStation 4'), ('Dying Light', 'Xbox One'),
('Dying Light 2 Stay Human', 'PlayStation 4'), ('Dying Light 2 Stay Human', 'PlayStation 5'),
('Dying Light 2 Stay Human', 'Xbox One'), ('Dying Light 2 Stay Human', 'Xbox Series X|S'),
('Subnautica', 'PlayStation 4'), ('Subnautica', 'Xbox One'), ('Subnautica', 'Nintendo Switch'),
('Subnautica: Below Zero', 'PlayStation 4'), ('Subnautica: Below Zero', 'Xbox One'),
('Subnautica: Below Zero', 'Nintendo Switch'),
('No Man''s Sky', 'PlayStation 4'), ('No Man''s Sky', 'PlayStation 5'),
('No Man''s Sky', 'Xbox One'), ('No Man''s Sky', 'Xbox Series X|S'), ('No Man''s Sky', 'Nintendo Switch'),
('Grounded', 'Xbox One'), ('Grounded', 'Xbox Series X|S'), ('Grounded', 'Nintendo Switch'),
('The Long Dark', 'PlayStation 4'), ('The Long Dark', 'Xbox One'), ('The Long Dark', 'Nintendo Switch'),
('Valheim', 'Xbox One'), ('Valheim', 'Xbox Series X|S'),
('Palworld', 'Xbox One'), ('Palworld', 'Xbox Series X|S'),
('Factorio', 'Nintendo Switch'), ('Satisfactory', 'Xbox Series X|S'),
('DAVE THE DIVER', 'PlayStation 4'), ('DAVE THE DIVER', 'PlayStation 5'),
('DAVE THE DIVER', 'Nintendo Switch'),
('Sea of Stars', 'PlayStation 4'), ('Sea of Stars', 'PlayStation 5'),
('Sea of Stars', 'Xbox One'), ('Sea of Stars', 'Xbox Series X|S'), ('Sea of Stars', 'Nintendo Switch'),
('Balatro', 'PlayStation 4'), ('Balatro', 'PlayStation 5'),
('Balatro', 'Xbox One'), ('Balatro', 'Xbox Series X|S'), ('Balatro', 'Nintendo Switch'),
('Slay the Spire', 'PlayStation 4'), ('Slay the Spire', 'Xbox One'), ('Slay the Spire', 'Nintendo Switch'),
('Celeste', 'PlayStation 4'), ('Celeste', 'Xbox One'), ('Celeste', 'Nintendo Switch'),
('Undertale', 'PlayStation 4'), ('Undertale', 'Nintendo Switch'),
('Ori and the Blind Forest: Definitive Edition', 'Xbox One'),
('Ori and the Blind Forest: Definitive Edition', 'Nintendo Switch'),
('Ori and the Will of the Wisps', 'Xbox One'), ('Ori and the Will of the Wisps', 'Xbox Series X|S'),
('Ori and the Will of the Wisps', 'Nintendo Switch'),
('Persona 5 Royal', 'PlayStation 4'), ('Persona 5 Royal', 'PlayStation 5'),
('Persona 5 Royal', 'Xbox One'), ('Persona 5 Royal', 'Xbox Series X|S'), ('Persona 5 Royal', 'Nintendo Switch'),
('Persona 4 Golden', 'PlayStation 4'), ('Persona 4 Golden', 'Xbox One'),
('Persona 4 Golden', 'Nintendo Switch'),
('Final Fantasy VII Remake Intergrade', 'PlayStation 5'),
('FINAL FANTASY XV WINDOWS EDITION', 'PlayStation 4'), ('FINAL FANTASY XV WINDOWS EDITION', 'Xbox One'),
('Yakuza: Like a Dragon', 'PlayStation 4'), ('Yakuza: Like a Dragon', 'PlayStation 5'),
('Yakuza: Like a Dragon', 'Xbox One'), ('Yakuza: Like a Dragon', 'Xbox Series X|S'),
('Like a Dragon: Infinite Wealth', 'PlayStation 4'), ('Like a Dragon: Infinite Wealth', 'PlayStation 5'),
('Like a Dragon: Infinite Wealth', 'Xbox One'), ('Like a Dragon: Infinite Wealth', 'Xbox Series X|S'),
('TEKKEN 8', 'PlayStation 5'), ('TEKKEN 8', 'Xbox Series X|S'),
('Street Fighter 6', 'PlayStation 4'), ('Street Fighter 6', 'PlayStation 5'),
('Street Fighter 6', 'Xbox Series X|S'),
('Mortal Kombat 1', 'PlayStation 5'), ('Mortal Kombat 1', 'Xbox Series X|S'),
('Mortal Kombat 1', 'Nintendo Switch'),
('LEGO Star Wars: The Skywalker Saga', 'PlayStation 4'), ('LEGO Star Wars: The Skywalker Saga', 'PlayStation 5'),
('LEGO Star Wars: The Skywalker Saga', 'Xbox One'), ('LEGO Star Wars: The Skywalker Saga', 'Xbox Series X|S'),
('LEGO Star Wars: The Skywalker Saga', 'Nintendo Switch'),
('A Plague Tale: Requiem', 'PlayStation 5'), ('A Plague Tale: Requiem', 'Xbox Series X|S'),
('A Plague Tale: Innocence', 'PlayStation 4'), ('A Plague Tale: Innocence', 'Xbox One'),
('Tomb Raider', 'PlayStation 4'), ('Tomb Raider', 'Xbox One'),
('Rise of the Tomb Raider', 'PlayStation 4'), ('Rise of the Tomb Raider', 'Xbox One'),
('Shadow of the Tomb Raider', 'PlayStation 4'), ('Shadow of the Tomb Raider', 'Xbox One'),
('Mafia: Definitive Edition', 'PlayStation 4'), ('Mafia: Definitive Edition', 'Xbox One'),
('Mafia II: Definitive Edition', 'PlayStation 4'), ('Mafia II: Definitive Edition', 'Xbox One'),
('Kingdom Come: Deliverance II', 'PlayStation 5'), ('Kingdom Come: Deliverance II', 'Xbox Series X|S'),
('Dragon''s Dogma 2', 'PlayStation 5'), ('Dragon''s Dogma 2', 'Xbox Series X|S'),
('Cult of the Lamb', 'PlayStation 4'), ('Cult of the Lamb', 'PlayStation 5'),
('Cult of the Lamb', 'Xbox One'), ('Cult of the Lamb', 'Xbox Series X|S'), ('Cult of the Lamb', 'Nintendo Switch'),
('Portal 2', 'PlayStation 3'), ('Portal 2', 'Xbox 360'), ('Portal 2', 'Nintendo Switch'),
('Portal', 'PlayStation 3'), ('Portal', 'Xbox 360'), ('Portal', 'Nintendo Switch'),
('Half-Life 2', 'Xbox'), ('Left 4 Dead 2', 'Xbox 360'),
('PAYDAY 2', 'PlayStation 3'), ('PAYDAY 2', 'Xbox 360'),
('The Elder Scrolls V: Skyrim Special Edition', 'PlayStation 4'),
('The Elder Scrolls V: Skyrim Special Edition', 'PlayStation 5'),
('The Elder Scrolls V: Skyrim Special Edition', 'Xbox One'),
('The Elder Scrolls V: Skyrim Special Edition', 'Xbox Series X|S'),
('The Elder Scrolls V: Skyrim Special Edition', 'Nintendo Switch'),
('Fallout 4', 'PlayStation 4'), ('Fallout 4', 'PlayStation 5'),
('Fallout 4', 'Xbox One'), ('Fallout 4', 'Xbox Series X|S'),
('Fallout: New Vegas', 'Xbox 360'),
('The Elder Scrolls IV: Oblivion', 'Xbox 360'),
('Divinity: Original Sin 2', 'PlayStation 4'), ('Divinity: Original Sin 2', 'Xbox One'),
('Divinity: Original Sin 2', 'Nintendo Switch'),
('Dragon Age: Inquisition', 'PlayStation 4'), ('Dragon Age: Inquisition', 'Xbox One'),
('Mass Effect Legendary Edition', 'PlayStation 4'), ('Mass Effect Legendary Edition', 'Xbox One'),
('The Outer Worlds', 'PlayStation 4'), ('The Outer Worlds', 'Xbox One'),
('The Outer Worlds', 'Nintendo Switch'),
('Risk of Rain 2', 'PlayStation 4'), ('Risk of Rain 2', 'Xbox One'), ('Risk of Rain 2', 'Nintendo Switch'),
('Dead Cells', 'PlayStation 4'), ('Dead Cells', 'Xbox One'), ('Dead Cells', 'Nintendo Switch'),
('Enter the Gungeon', 'PlayStation 4'), ('Enter the Gungeon', 'Xbox One'), ('Enter the Gungeon', 'Nintendo Switch'),
('The Binding of Isaac: Rebirth', 'PlayStation 4'), ('The Binding of Isaac: Rebirth', 'Xbox One'),
('The Binding of Isaac: Rebirth', 'Nintendo Switch'),
('Rogue Legacy 2', 'PlayStation 4'), ('Rogue Legacy 2', 'PlayStation 5'),
('Rogue Legacy 2', 'Xbox One'), ('Rogue Legacy 2', 'Xbox Series X|S'), ('Rogue Legacy 2', 'Nintendo Switch'),
('Sid Meier''s Civilization VI', 'PlayStation 4'), ('Sid Meier''s Civilization VI', 'Xbox One'),
('Sid Meier''s Civilization VI', 'Nintendo Switch'),
('Age of Empires II: Definitive Edition', 'Xbox One'), ('Age of Empires II: Definitive Edition', 'Xbox Series X|S'),
('Age of Empires IV', 'Xbox One'), ('Age of Empires IV', 'Xbox Series X|S'),
('XCOM 2', 'PlayStation 4'), ('XCOM 2', 'Xbox One'), ('XCOM 2', 'Nintendo Switch'),
('Cities: Skylines', 'PlayStation 4'), ('Cities: Skylines', 'Xbox One'), ('Cities: Skylines', 'Nintendo Switch'),
('Planet Coaster', 'PlayStation 4'), ('Planet Coaster', 'Xbox One'),
('Planet Zoo', 'PlayStation 5'), ('Planet Zoo', 'Xbox Series X|S'),
('F1 24', 'PlayStation 5'), ('F1 24', 'Xbox Series X|S'),
('Assetto Corsa', 'PlayStation 4'), ('Assetto Corsa', 'Xbox One'),
('DiRT Rally 2.0', 'PlayStation 4'), ('DiRT Rally 2.0', 'Xbox One'),
('Wreckfest', 'PlayStation 4'), ('Wreckfest', 'Xbox One'), ('Wreckfest', 'Nintendo Switch'),
('MotoGP 24', 'PlayStation 4'), ('MotoGP 24', 'PlayStation 5'),
('MotoGP 24', 'Xbox One'), ('MotoGP 24', 'Xbox Series X|S'), ('MotoGP 24', 'Nintendo Switch'),
('EA SPORTS FC 25', 'PlayStation 4'), ('EA SPORTS FC 25', 'PlayStation 5'),
('EA SPORTS FC 25', 'Xbox One'), ('EA SPORTS FC 25', 'Xbox Series X|S'), ('EA SPORTS FC 25', 'Nintendo Switch'),
('WWE 2K24', 'PlayStation 4'), ('WWE 2K24', 'PlayStation 5'),
('WWE 2K24', 'Xbox One'), ('WWE 2K24', 'Xbox Series X|S'),
('Tony Hawk''s Pro Skater 1 + 2', 'PlayStation 4'), ('Tony Hawk''s Pro Skater 1 + 2', 'PlayStation 5'),
('Tony Hawk''s Pro Skater 1 + 2', 'Xbox One'), ('Tony Hawk''s Pro Skater 1 + 2', 'Xbox Series X|S'),
('Riders Republic', 'PlayStation 4'), ('Riders Republic', 'PlayStation 5'),
('Riders Republic', 'Xbox One'), ('Riders Republic', 'Xbox Series X|S'),
('The Crew Motorfest', 'PlayStation 4'), ('The Crew Motorfest', 'PlayStation 5'),
('The Crew Motorfest', 'Xbox One'), ('The Crew Motorfest', 'Xbox Series X|S'),
('Call of Duty: Black Ops III', 'PlayStation 4'), ('Call of Duty: Black Ops III', 'Xbox One'),
('Ready or Not', 'PlayStation 5'), ('Ready or Not', 'Xbox Series X|S'),
('Killing Floor 2', 'PlayStation 4'), ('Killing Floor 2', 'Xbox One'),
('Sniper Elite 5', 'PlayStation 4'), ('Sniper Elite 5', 'PlayStation 5'),
('Sniper Elite 5', 'Xbox One'), ('Sniper Elite 5', 'Xbox Series X|S'),
('Back 4 Blood', 'PlayStation 4'), ('Back 4 Blood', 'PlayStation 5'),
('Back 4 Blood', 'Xbox One'), ('Back 4 Blood', 'Xbox Series X|S'),
('Battlefield 4', 'PlayStation 3'), ('Battlefield 4', 'PlayStation 4'),
('Battlefield 4', 'Xbox 360'), ('Battlefield 4', 'Xbox One'),
('Remnant II', 'PlayStation 5'), ('Remnant II', 'Xbox Series X|S'),
('Sniper Elite 4', 'PlayStation 4'), ('Sniper Elite 4', 'Xbox One'),
('Sniper Elite 4', 'Nintendo Switch'),
('Halo: The Master Chief Collection', 'Xbox One'), ('Halo: The Master Chief Collection', 'Xbox Series X|S'),
('Prey', 'PlayStation 4'), ('Prey', 'Xbox One'),
('BioShock Remastered', 'PlayStation 4'), ('BioShock Remastered', 'Xbox One'),
('BioShock Infinite', 'PlayStation 3'), ('BioShock Infinite', 'Xbox 360'),
('Outlast', 'PlayStation 4'), ('Outlast', 'Nintendo Switch'),
('Outlast 2', 'PlayStation 4'), ('Outlast 2', 'Xbox One'), ('Outlast 2', 'Nintendo Switch'),
('SOMA', 'PlayStation 4'), ('SOMA', 'Xbox One'),
('Little Nightmares', 'PlayStation 4'), ('Little Nightmares', 'Xbox One'),
('Little Nightmares', 'Nintendo Switch'),
('Little Nightmares II', 'PlayStation 4'), ('Little Nightmares II', 'PlayStation 5'),
('Little Nightmares II', 'Xbox One'), ('Little Nightmares II', 'Xbox Series X|S'),
('Little Nightmares II', 'Nintendo Switch'),
('Phasmophobia', 'PlayStation 5'), ('Phasmophobia', 'Xbox Series X|S'),
('The Forest', 'PlayStation 4'), ('Don''t Starve Together', 'PlayStation 4'),
('Don''t Starve Together', 'Xbox One'), ('Don''t Starve Together', 'Nintendo Switch'),
('7 Days to Die', 'PlayStation 4'), ('7 Days to Die', 'Xbox One'),
('ARK: Survival Ascended', 'PlayStation 5'), ('ARK: Survival Ascended', 'Xbox Series X|S'),
('Green Hell', 'PlayStation 4'), ('Green Hell', 'Xbox One'), ('Green Hell', 'Nintendo Switch'),
('Frostpunk', 'PlayStation 4'), ('Frostpunk', 'Xbox One'),
('Frostpunk', 'Nintendo Switch'),
('This War of Mine', 'PlayStation 4'), ('This War of Mine', 'Xbox One'), ('This War of Mine', 'Nintendo Switch'),
('Oxygen Not Included', 'Nintendo Switch'),
('RimWorld', 'PlayStation 4'), ('RimWorld', 'Xbox One'),
('The Witness', 'PlayStation 4'), ('Outer Wilds', 'PlayStation 4'), ('Outer Wilds', 'Xbox One'),
('Firewatch', 'PlayStation 4'), ('Firewatch', 'Xbox One'), ('Firewatch', 'Nintendo Switch'),
('INSIDE', 'PlayStation 4'), ('INSIDE', 'Xbox One'), ('INSIDE', 'Nintendo Switch'),
('LIMBO', 'PlayStation 4'), ('LIMBO', 'Xbox One'), ('LIMBO', 'Nintendo Switch'),
('Journey', 'PlayStation 4'),
('What Remains of Edith Finch', 'PlayStation 4'), ('What Remains of Edith Finch', 'Xbox One'),
('A Short Hike', 'Nintendo Switch'), ('GRIS', 'PlayStation 4'), ('GRIS', 'Nintendo Switch');

INSERT IGNORE INTO jogo_plataformas (jogo_id, plataforma)
SELECT jogos.jogo_id, catalogo_plataformas.plataforma
FROM catalogo_plataformas
JOIN jogos ON jogos.titulo = catalogo_plataformas.titulo;

DROP TEMPORARY TABLE catalogo_plataformas;


-- ============================================================
-- AJUSTES FINAIS DO CATALOGO
-- ============================================================
-- Execute depois de importar louja.sql e criar jogo_categorias.
-- Atualiza o catalogo sem tocar em estoque ou preco.
SET @LOUJA_SQL_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

INSERT INTO categorias (nome)
SELECT genero.nome
FROM (
    SELECT 'Corrida' AS nome
    UNION ALL SELECT 'Estratégia'
    UNION ALL SELECT 'Luta'
    UNION ALL SELECT 'Metroidvania'
    UNION ALL SELECT 'Plataforma'
    UNION ALL SELECT 'Roguelike'
    UNION ALL SELECT 'Simulação'
) AS genero
WHERE NOT EXISTS (
    SELECT 1 FROM categorias WHERE categorias.nome = genero.nome
);

INSERT IGNORE INTO jogo_categorias (jogo_id, categoria_id)
SELECT jogos.jogo_id, categoriasDestino.categoria_id
FROM jogos
JOIN categorias AS categoriaCombinada
    ON categoriaCombinada.nome = 'Ação e Aventura'
CROSS JOIN (
    SELECT categoria_id, nome
    FROM categorias
    WHERE nome IN ('Ação', 'Aventura')
) AS categoriasDestino
LEFT JOIN jogo_categorias AS categoriasDoJogo
    ON categoriasDoJogo.jogo_id = jogos.jogo_id
   AND categoriasDoJogo.categoria_id = categoriaCombinada.categoria_id
WHERE jogos.categoria_id = categoriaCombinada.categoria_id
   OR categoriasDoJogo.jogo_id IS NOT NULL;

UPDATE jogos
SET categoria_id = (
    SELECT MIN(categoria_id)
    FROM categorias
    WHERE nome = 'Ação'
)
WHERE categoria_id IN (
    SELECT categoria_id
    FROM categorias
    WHERE nome = 'Ação e Aventura'
);

DELETE jogo_categorias
FROM jogo_categorias
JOIN categorias ON categorias.categoria_id = jogo_categorias.categoria_id
WHERE categorias.nome = 'Ação e Aventura';

DELETE FROM categorias
WHERE nome = 'Ação e Aventura';

UPDATE jogos AS jogo
JOIN (
    SELECT 'Minecraft' AS titulo, 'Sobrevivência' AS categoria, 'Explore mundos feitos de blocos, colete recursos e construa livremente enquanto enfrenta os perigos da sobrevivência.' AS descricao
    UNION ALL SELECT 'Grand Theft Auto V', 'Ação', 'Acompanhe três criminosos em Los Santos enquanto seus destinos se cruzam em assaltos, perseguições e disputas pelo poder.'
    UNION ALL SELECT 'Red Dead Redemption 2', 'Ação', 'Viva a jornada de Arthur Morgan e da gangue Van der Linde em um Velho Oeste à beira de desaparecer.'
    UNION ALL SELECT 'The Witcher 3: Wild Hunt', 'RPG', 'Como Geralt de Rívia, rastreie monstros e procure Ciri em um mundo aberto marcado por escolhas e consequências.'
    UNION ALL SELECT 'Cyberpunk 2077', 'RPG', 'Explore Night City como V, uma pessoa mercenária envolvida em uma busca por um implante ligado à imortalidade.'
    UNION ALL SELECT 'Elden Ring', 'RPG', 'Explore as Terras Intermédias, enfrente criaturas e descubra os segredos de um mundo de fantasia criado por sua própria jornada.'
    UNION ALL SELECT 'Resident Evil 4', 'Horror', 'Como Leon Kennedy, procure a filha do presidente em uma região isolada e sobreviva a inimigos tomados por uma ameaça desconhecida.'
    UNION ALL SELECT 'Forza Horizon 5', 'Corrida', 'Dispute corridas por diferentes regiões do México e monte sua coleção de carros em um festival de automobilismo em mundo aberto.'
    UNION ALL SELECT 'God of War', 'Ação', 'Kratos e seu filho Atreus atravessam terras nórdicas em uma jornada que testa sua relação e os coloca diante de deuses e monstros.'
    UNION ALL SELECT 'God of War Ragnarök', 'Ação', 'Kratos e Atreus percorrem os Nove Reinos enquanto tentam compreender as profecias que anunciam o Ragnarök.'
    UNION ALL SELECT 'Marvel''s Spider-Man Remastered', 'Ação', 'Balance por Nova York como Peter Parker e enfrente uma ameaça que coloca a cidade e seus moradores em risco.'
    UNION ALL SELECT 'Marvel''s Spider-Man 2', 'Ação', 'Peter Parker e Miles Morales protegem Nova York enquanto enfrentam novos inimigos e equilibram suas vidas pessoais.'
    UNION ALL SELECT 'Horizon Zero Dawn', 'RPG', 'Em um futuro dominado por máquinas, Aloy parte em busca de suas origens e dos segredos que transformaram o mundo.'
    UNION ALL SELECT 'Horizon Forbidden West', 'RPG', 'Aloy viaja para terras desconhecidas para investigar uma praga que ameaça a vida e enfrentar novas máquinas.'
    UNION ALL SELECT 'The Last of Us Part I', 'Ação', 'Joel e Ellie atravessam os Estados Unidos devastados por uma infecção em uma jornada de sobrevivência e confiança.'
    UNION ALL SELECT 'The Last of Us Part II', 'Ação', 'Acompanhe Ellie em uma jornada de vingança que explora o custo da violência em um mundo devastado.'
    UNION ALL SELECT 'Uncharted: Legacy of Thieves Collection', 'Ação', 'Nathan Drake e Chloe Frazer partem em expedições perigosas em busca de tesouros históricos e respostas do passado.'
    UNION ALL SELECT 'Ghost of Tsushima', 'Ação', 'Jin Sakai luta para proteger Tsushima da invasão mongol e precisa decidir até onde irá para salvar sua terra.'
    UNION ALL SELECT 'Assassin''s Creed Valhalla', 'RPG', 'Lidere Eivor e seu clã viking na busca por um novo lar na Inglaterra e participe de conflitos que moldam a região.'
    UNION ALL SELECT 'Assassin''s Creed Odyssey', 'RPG', 'Na Grécia Antiga, escolha seu caminho como mercenário e descubra a história de sua família durante a Guerra do Peloponeso.'
    UNION ALL SELECT 'Far Cry 6', 'FPS', 'Organize a resistência na ilha de Yara e lute contra o regime de Antón Castillo em um conflito de guerrilha.'
    UNION ALL SELECT 'Resident Evil Village', 'Horror', 'Ethan Winters chega a uma vila isolada para encontrar sua filha e encara criaturas e mistérios ligados à família Dimitrescu.'
    UNION ALL SELECT 'Dead Space', 'Horror', 'A bordo da nave Ishimura, Isaac Clarke precisa sobreviver a criaturas aterrorizantes e descobrir o que aconteceu com a tripulação.'
    UNION ALL SELECT 'Hogwarts Legacy', 'RPG', 'Estude magia em Hogwarts no século XIX e investigue um antigo poder que ameaça o mundo bruxo.'
    UNION ALL SELECT 'Star Wars Jedi: Survivor', 'Ação', 'Cal Kestis continua sua luta contra o Império e busca aliados e refúgio em uma galáxia sob domínio imperial.'
    UNION ALL SELECT 'Baldur''s Gate 3', 'RPG', 'Reúna companheiros e decida o destino de Faerûn em uma aventura de fantasia baseada nas regras de Dungeons & Dragons.'
    UNION ALL SELECT 'Diablo IV', 'RPG', 'Enfrente as forças demoníacas de Lilith em Santuário e escolha uma classe para explorar masmorras e missões.'
    UNION ALL SELECT 'Monster Hunter: World', 'RPG', 'Participe de expedições ao Novo Mundo, estude monstros e use os materiais obtidos para criar equipamentos.'
    UNION ALL SELECT 'Monster Hunter Wilds', 'RPG', 'Explore regiões selvagens em mudança, investigue ecossistemas e cace monstros em um mundo de condições extremas.'
    UNION ALL SELECT 'Need for Speed Heat', 'Corrida', 'Corra de dia em eventos oficiais e arrisque-se à noite em disputas ilegais enquanto foge da polícia de Palm City.'
    UNION ALL SELECT 'Rainbow Six Siege', 'FPS', 'Dispute confrontos táticos entre equipes de ataque e defesa usando operadores com habilidades e equipamentos distintos.'
    UNION ALL SELECT 'Terraria', 'Sobrevivência', 'Explore um mundo bidimensional, reúna materiais, construa abrigos e enfrente criaturas e chefes.'
    UNION ALL SELECT 'Stardew Valley', 'Simulação', 'Recupere uma fazenda, cultive a terra e construa relações com os moradores de uma comunidade rural.'
    UNION ALL SELECT 'Hades', 'Roguelike', 'Ajude Zagreus a escapar do Submundo em tentativas sucessivas, combinando armas e bênçãos dos deuses do Olimpo.'
    UNION ALL SELECT 'Hollow Knight', 'Metroidvania', 'Explore Hallownest, um reino subterrâneo em ruínas, e descubra seus segredos em combates e caminhos interligados.'
    UNION ALL SELECT 'Cuphead', 'Plataforma', 'Ajude Cuphead e Mugman a quitar uma dívida com o Diabo em fases de plataforma e batalhas contra chefes.'
    UNION ALL SELECT 'It Takes Two', 'Aventura', 'Dois jogadores controlam um casal transformado em bonecos e precisam cooperar para atravessar desafios variados.'
    UNION ALL SELECT 'Sekiro: Shadows Die Twice', 'Ação', 'Um shinobi parte para resgatar seu senhor em uma versão fantástica do Japão do período Sengoku.'
    UNION ALL SELECT 'Dark Souls III', 'RPG', 'Atravesse um reino em decadência e enfrente criaturas poderosas em uma jornada de fantasia sombria.'
    UNION ALL SELECT 'Dark Souls Remastered', 'RPG', 'Explore Lordran e enfrente seus desafios em uma aventura de fantasia sombria sobre a chama e seu ciclo.'
    UNION ALL SELECT 'Dark Souls II: Scholar of the First Sin', 'RPG', 'Busque uma cura para a maldição em Drangleic, um reino repleto de ruínas, inimigos e caminhos interligados.'
    UNION ALL SELECT 'Black Myth: Wukong', 'RPG', 'Assuma o papel do Predestinado e enfrente criaturas inspiradas na jornada mitológica chinesa de Sun Wukong.'
    UNION ALL SELECT 'Lies of P', 'RPG', 'Em uma cidade inspirada na Belle Époque, um autômato busca seu criador e enfrenta máquinas enlouquecidas.'
    UNION ALL SELECT 'Sifu', 'Ação', 'Um jovem artista marcial busca vingança contra os responsáveis pela morte de sua família, aprendendo com cada confronto.'
    UNION ALL SELECT 'Stray', 'Aventura', 'Um gato perdido explora uma cidade subterrânea habitada por robôs e procura um caminho de volta à superfície.'
    UNION ALL SELECT 'Days Gone', 'Ação', 'Deacon St. John cruza uma região devastada por uma pandemia enquanto procura respostas e tenta sobreviver.'
    UNION ALL SELECT 'DEATH STRANDING DIRECTOR''S CUT', 'Aventura', 'Sam Porter Bridges conecta comunidades isoladas em uma América fragmentada por um fenômeno sobrenatural.'
    UNION ALL SELECT 'Control Ultimate Edition', 'Ação', 'Jesse Faden investiga uma agência secreta alterada por uma força sobrenatural e procura seu irmão desaparecido.'
    UNION ALL SELECT 'DOOM Eternal', 'FPS', 'Enfrente uma invasão demoníaca na Terra em combates rápidos como o DOOM Slayer.'
    UNION ALL SELECT 'DOOM', 'FPS', 'Lute contra hordas demoníacas em uma instalação de pesquisa em Marte usando armas e movimentos rápidos.'
    UNION ALL SELECT 'Titanfall 2', 'FPS', 'Um piloto e seu titã formam uma parceria durante uma campanha de ficção científica e combates multiplayer.'
    UNION ALL SELECT 'Battlefield 1', 'FPS', 'Participe de diferentes histórias ambientadas nos campos de batalha da Primeira Guerra Mundial.'
    UNION ALL SELECT 'Battlefield V', 'FPS', 'Dispute batalhas da Segunda Guerra Mundial em campanhas para um jogador e confrontos multiplayer.'
    UNION ALL SELECT 'Battlefield 2042', 'FPS', 'Lute em conflitos de grande escala em um futuro próximo, com especialistas e cenários dinâmicos.'
    UNION ALL SELECT 'Borderlands 3', 'Ação', 'Explore Pandora e outros planetas em busca de tesouros enquanto enfrenta os líderes de um culto armado.'
    UNION ALL SELECT 'Tiny Tina''s Wonderlands', 'RPG', 'Entre em uma aventura de fantasia narrada por Tiny Tina e monte um personagem para enfrentar monstros e masmorras.'
    UNION ALL SELECT 'Metro Exodus', 'FPS', 'Artyom e outros sobreviventes deixam o metrô de Moscou para cruzar uma Rússia devastada por uma guerra nuclear.'
    UNION ALL SELECT 'Dying Light', 'Sobrevivência', 'Explore uma cidade em quarentena durante o dia e enfrente infectados mais perigosos após o anoitecer.'
    UNION ALL SELECT 'Dying Light 2 Stay Human', 'Sobrevivência', 'Aventure-se por uma cidade tomada por infectados e decida o destino de seus assentamentos e habitantes.'
    UNION ALL SELECT 'Subnautica', 'Sobrevivência', 'Sobreviva em um planeta oceânico alienígena enquanto explora profundezas, coleta recursos e busca uma saída.'
    UNION ALL SELECT 'Subnautica: Below Zero', 'Sobrevivência', 'Investigue o desaparecimento de sua irmã em uma região gelada de um planeta coberto por oceanos.'
    UNION ALL SELECT 'No Man''s Sky', 'Sobrevivência', 'Viaje por um universo gerado proceduralmente, explore planetas e construa uma jornada entre as estrelas.'
    UNION ALL SELECT 'Grounded', 'Sobrevivência', 'Sobreviva em um quintal onde os personagens foram reduzidos ao tamanho de insetos e investigue como isso aconteceu.'
    UNION ALL SELECT 'The Long Dark', 'Sobrevivência', 'Enfrente o frio, a fome e a vida selvagem após um desastre que deixou regiões remotas sem energia.'
    UNION ALL SELECT 'Sons Of The Forest', 'Sobrevivência', 'Procure um bilionário desaparecido em uma ilha isolada e sobreviva a perigos humanos e mutantes.'
    UNION ALL SELECT 'Valheim', 'Sobrevivência', 'Construa, explore e enfrente criaturas em um mundo de sobrevivência inspirado na mitologia nórdica.'
    UNION ALL SELECT 'Palworld', 'Sobrevivência', 'Explore ilhas, capture criaturas chamadas Pals e use suas habilidades para sobreviver e construir.'
    UNION ALL SELECT 'Raft', 'Sobrevivência', 'Sobreviva em alto-mar em uma pequena jangada, reúna recursos e procure pistas sobre o mundo inundado.'
    UNION ALL SELECT 'Project Zomboid', 'Sobrevivência', 'Tente sobreviver em uma cidade tomada por zumbis, administrando recursos, ferimentos e ameaças constantes.'
    UNION ALL SELECT 'Factorio', 'Estratégia', 'Projete e automatize uma fábrica em um planeta alienígena enquanto administra recursos e defende suas instalações.'
    UNION ALL SELECT 'Satisfactory', 'Simulação', 'Construa fábricas em primeira pessoa, automatize linhas de produção e explore um planeta alienígena.'
    UNION ALL SELECT 'DAVE THE DIVER', 'Simulação', 'Mergulhe durante o dia para pescar e administre um restaurante de sushi à noite.'
    UNION ALL SELECT 'Sea of Stars', 'RPG', 'Dois guerreiros ligados ao solstício enfrentam uma ameaça antiga em uma aventura inspirada nos RPGs clássicos.'
    UNION ALL SELECT 'Balatro', 'Estratégia', 'Monte combinações de pôquer e use curingas com efeitos especiais para superar rodadas cada vez mais difíceis.'
    UNION ALL SELECT 'Slay the Spire', 'Estratégia', 'Monte um baralho durante a subida de uma torre e combine cartas, relíquias e decisões táticas.'
    UNION ALL SELECT 'Celeste', 'Plataforma', 'Ajude Madeline a escalar a montanha Celeste em fases de plataforma que desafiam precisão e persistência.'
    UNION ALL SELECT 'Undertale', 'RPG', 'Explore o mundo subterrâneo dos monstros e escolha como lidar com seus habitantes em uma história sobre escolhas.'
    UNION ALL SELECT 'Ori and the Blind Forest: Definitive Edition', 'Metroidvania', 'Guie Ori por uma floresta em perigo, desbloqueando habilidades e caminhos em um mundo interligado.'
    UNION ALL SELECT 'Ori and the Will of the Wisps', 'Metroidvania', 'Ajude Ori a encontrar seu caminho em uma jornada por regiões desconhecidas e conectadas.'
    UNION ALL SELECT 'Persona 5 Royal', 'RPG', 'Lidere os Phantom Thieves entre a vida escolar e incursões sobrenaturais para confrontar adultos corruptos.'
    UNION ALL SELECT 'Persona 4 Golden', 'RPG', 'Investigue uma série de desaparecimentos em uma cidade rural enquanto conhece moradores e enfrenta um mundo misterioso.'
    UNION ALL SELECT 'Final Fantasy VII Remake Intergrade', 'RPG', 'Acompanhe Cloud e a resistência Avalanche em Midgar, em uma releitura de parte da história de Final Fantasy VII.'
    UNION ALL SELECT 'FINAL FANTASY XV WINDOWS EDITION', 'RPG', 'Noctis e seus companheiros viajam por Eos enquanto tentam recuperar o reino tomado pelo Império.'
    UNION ALL SELECT 'Yakuza: Like a Dragon', 'RPG', 'Ichiban Kasuga recomeça sua vida em Yokohama e reúne aliados em uma aventura com combate por turnos.'
    UNION ALL SELECT 'Like a Dragon: Infinite Wealth', 'RPG', 'Ichiban e Kiryu se encontram no Havaí em uma aventura sobre família, recomeços e conspirações.'
    UNION ALL SELECT 'TEKKEN 8', 'Luta', 'Lute em confrontos individuais com um elenco de personagens e acompanhe o novo capítulo da disputa entre os Mishima.'
    UNION ALL SELECT 'Street Fighter 6', 'Luta', 'Domine técnicas e estilos de luta em partidas competitivas, modos para um jogador e criação de personagens.'
    UNION ALL SELECT 'Mortal Kombat 1', 'Luta', 'Enfrente kombates brutais em uma nova linha do tempo criada pelo Deus do Fogo Liu Kang.'
    UNION ALL SELECT 'LEGO Star Wars: The Skywalker Saga', 'Aventura', 'Reviva os nove filmes da saga Star Wars em fases de aventura e exploração no universo LEGO.'
    UNION ALL SELECT 'A Plague Tale: Requiem', 'Aventura', 'Amicia e Hugo buscam uma forma de conter a doença de Hugo em uma jornada por uma França assolada pela guerra.'
    UNION ALL SELECT 'A Plague Tale: Innocence', 'Aventura', 'Amicia tenta proteger seu irmão Hugo enquanto foge da Inquisição e de enxames de ratos na França medieval.'
    UNION ALL SELECT 'Tomb Raider', 'Ação', 'A jovem Lara Croft precisa sobreviver a um naufrágio e escapar de uma ilha hostil.'
    UNION ALL SELECT 'Rise of the Tomb Raider', 'Ação', 'Lara Croft parte para a Sibéria em busca de uma cidade lendária e do segredo da imortalidade.'
    UNION ALL SELECT 'Shadow of the Tomb Raider', 'Ação', 'Lara tenta impedir uma catástrofe enquanto explora tumbas e regiões da América Latina.'
    UNION ALL SELECT 'Mafia: Definitive Edition', 'Ação', 'Tommy Angelo entra para a máfia de Lost Heaven e ascende em uma história ambientada nos anos 1930.'
    UNION ALL SELECT 'Mafia II: Definitive Edition', 'Ação', 'Vito Scaletta tenta construir uma vida melhor em Empire Bay enquanto se envolve com o crime organizado.'
    UNION ALL SELECT 'Kingdom Come: Deliverance II', 'RPG', 'Henry retorna à Boêmia medieval em uma aventura de mundo aberto marcada por conflitos políticos e escolhas.'
    UNION ALL SELECT 'Dragon''s Dogma 2', 'RPG', 'Assuma o papel do Arisen e atravesse um mundo de fantasia com companheiros controlados por inteligência artificial.'
    UNION ALL SELECT 'Hades II', 'Roguelike', 'Controle Melinoë em tentativas de enfrentar Cronos, combinando armas e bênçãos em cada incursão.'
    UNION ALL SELECT 'Cult of the Lamb', 'Roguelike', 'Lidere um culto em nome de uma entidade misteriosa, cuide de seus seguidores e enfrente masmorras em combates roguelike.'
) AS conteudo ON conteudo.titulo = jogo.titulo
JOIN (
    SELECT MIN(categoria_id) AS categoria_id, nome
    FROM categorias
    GROUP BY nome
) AS genero ON genero.nome = conteudo.categoria
SET jogo.categoria_id = genero.categoria_id,
    jogo.descricao = conteudo.descricao;

INSERT IGNORE INTO jogo_categorias (jogo_id, categoria_id)
SELECT jogos.jogo_id, categorias.categoria_id
FROM jogos
JOIN (
    SELECT 'Grand Theft Auto V' AS titulo
    UNION ALL SELECT 'Red Dead Redemption 2'
    UNION ALL SELECT 'God of War'
    UNION ALL SELECT 'God of War Ragnarök'
    UNION ALL SELECT 'Marvel''s Spider-Man Remastered'
    UNION ALL SELECT 'Marvel''s Spider-Man 2'
    UNION ALL SELECT 'The Last of Us Part I'
    UNION ALL SELECT 'The Last of Us Part II'
    UNION ALL SELECT 'Uncharted: Legacy of Thieves Collection'
    UNION ALL SELECT 'Ghost of Tsushima'
    UNION ALL SELECT 'Star Wars Jedi: Survivor'
    UNION ALL SELECT 'Sekiro: Shadows Die Twice'
    UNION ALL SELECT 'Sifu'
    UNION ALL SELECT 'Days Gone'
    UNION ALL SELECT 'Control Ultimate Edition'
    UNION ALL SELECT 'Borderlands 3'
    UNION ALL SELECT 'Tomb Raider'
    UNION ALL SELECT 'Rise of the Tomb Raider'
    UNION ALL SELECT 'Shadow of the Tomb Raider'
    UNION ALL SELECT 'Mafia: Definitive Edition'
    UNION ALL SELECT 'Mafia II: Definitive Edition'
) AS jogosAcaoAventura ON jogosAcaoAventura.titulo = jogos.titulo
CROSS JOIN (
    SELECT 'Ação' AS nome
    UNION ALL SELECT 'Aventura'
) AS generosSelecionados
JOIN categorias ON categorias.nome = generosSelecionados.nome;

SET SQL_SAFE_UPDATES = @LOUJA_SQL_SAFE_UPDATES;
SET @LOUJA_SQL_SAFE_UPDATES = NULL;