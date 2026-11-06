CREATE DATABASE IF NOT EXISTS louja 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE louja;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE itens_pedido;
TRUNCATE TABLE jogos;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE IF NOT EXISTS usuarios (
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

CREATE TABLE IF NOT EXISTS categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

INSERT INTO categorias (nome) VALUES
('RPG'),
('Ação'),
('Aventura'),
('Horror'),
('Sobrevivência'),
('FPS'),
('Esportes');
USE louja;

CREATE TABLE IF NOT exists jogos (
    jogo_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
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



INSERT INTO jogos
(categoria_id, titulo, descricao, plataforma, preco,
 quantidade_estoque, img_url, destaque_carrossel)
VALUES

(5, 'Minecraft',
 'Jogo sandbox de sobrevivência e construção.',
 'PC', 99.00, 20,
 'https://images.igdb.com/igdb/image/upload/t_cover_big/co2l8f.jpg', 1),

(2, 'Grand Theft Auto V',
 'Jogo de ação e mundo aberto.',
 'PC', 99.90, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/271590/header.jpg', 1),

(2, 'Red Dead Redemption 2',
 'Aventura de ação em mundo aberto ambientada no Velho Oeste.',
 'PC', 299.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1174180/header.jpg', 1),

(1, 'The Witcher 3: Wild Hunt',
 'RPG de mundo aberto com exploração e narrativa.',
 'PC', 149.99, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/292030/header.jpg', 1),

(1, 'Cyberpunk 2077',
 'RPG de ação ambientado em um futuro distópico.',
 'PC', 199.90, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1091500/header.jpg', 1),

(1, 'Elden Ring',
 'RPG de ação em um vasto mundo de fantasia.',
 'PC', 229.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg', 1),

(4, 'Resident Evil 4',
 'Jogo de horror e ação com elementos de sobrevivência.',
 'PC', 169.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2050650/header.jpg', 1),

(7, 'Forza Horizon 5',
 'Jogo de corrida em mundo aberto.',
 'PC', 249.00, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1551360/header.jpg', 1),



(2, 'God of War',
 'Aventura de ação baseada na mitologia nórdica.',
 'PC', 199.90, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1593500/header.jpg', 0),

(2, 'God of War Ragnarök',
 'Aventura de ação com Kratos e Atreus.',
 'PC', 249.90, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2322010/header.jpg', 0),

(2, 'Marvel''s Spider-Man Remastered',
 'Aventura de ação baseada no Homem-Aranha.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1817070/header.jpg', 0),

(2, 'Marvel''s Spider-Man 2',
 'Aventura de ação com Peter Parker e Miles Morales.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2651280/header.jpg', 0),

(1, 'Horizon Zero Dawn',
 'RPG de ação em um mundo pós-apocalíptico.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1151640/header.jpg', 0),

(1, 'Horizon Forbidden West',
 'RPG de ação e exploração em mundo aberto.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2420110/header.jpg', 0),

(2, 'The Last of Us Part I',
 'Aventura de ação focada em narrativa e sobrevivência.',
 'PC', 249.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1888930/header.jpg', 0),

(2, 'The Last of Us Part II',
 'Aventura de ação focada em narrativa.',
 'PC', 249.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2531310/header.jpg', 0),

(3, 'Uncharted: Legacy of Thieves Collection',
 'Aventura de ação com exploração e enigmas.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1659420/header.jpg', 0),

(2, 'Ghost of Tsushima',
 'Ação e exploração no Japão feudal.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2215430/header.jpg', 0),

(1, 'Assassin''s Creed Valhalla',
 'RPG de ação ambientado na Era Viking.',
 'PC', 199.90, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2208920/header.jpg', 0),

(1, 'Assassin''s Creed Odyssey',
 'RPG de ação ambientado na Grécia Antiga.',
 'PC', 199.90, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/812140/header.jpg', 0),

(6, 'Far Cry 6',
 'FPS de ação em mundo aberto.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2369390/header.jpg', 0),

(4, 'Resident Evil Village',
 'Jogo de horror e sobrevivência.',
 'PC', 139.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1196590/header.jpg', 0),

(4, 'Dead Space',
 'Horror de sobrevivência ambientado no espaço.',
 'PC', 249.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1693980/header.jpg', 0),

(1, 'Hogwarts Legacy',
 'RPG de aventura ambientado no universo de Harry Potter.',
 'PC', 249.90, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/990080/header.jpg', 0),

(3, 'Star Wars Jedi: Survivor',
 'Aventura de ação ambientada no universo Star Wars.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1774580/header.jpg', 0),

(1, 'Baldur''s Gate 3',
 'RPG baseado no universo de Dungeons & Dragons.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1086940/header.jpg', 0),

(1, 'Diablo IV',
 'RPG de ação com combate e exploração.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2344520/header.jpg', 0),

(1, 'Monster Hunter: World',
 'RPG de ação focado em caça e exploração.',
 'PC', 139.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/582010/header.jpg', 0),

(1, 'Monster Hunter Wilds',
 'RPG de ação focado em caça de monstros.',
 'PC', 299.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2246340/header.jpg', 0),

(7, 'Need for Speed Heat',
 'Jogo de corrida focado em carros e perseguições.',
 'PC', 199.90, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1222680/header.jpg', 0),

(6, 'Rainbow Six Siege',
 'FPS tático multiplayer.',
 'PC', 79.90, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/359550/header.jpg', 0),

(5, 'Terraria',
 'Sandbox de aventura, exploração e sobrevivência.',
 'PC', 19.99, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/105600/header.jpg', 0),

(1, 'Stardew Valley',
 'RPG e simulador de fazenda.',
 'PC', 24.99, 15,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/413150/header.jpg', 0),

(2, 'Hades',
 'Roguelike de ação baseado na mitologia grega.',
 'PC', 73.99, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1145360/header.jpg', 0),

(3, 'Hollow Knight',
 'Aventura de exploração em um mundo subterrâneo.',
 'PC', 46.99, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/367520/header.jpg', 0),

(2, 'Cuphead',
 'Jogo de ação e plataforma com estilo de animação clássica.',
 'PC', 36.99, 12,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/268910/header.jpg', 0),

(3, 'It Takes Two',
 'Aventura cooperativa para dois jogadores.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1426210/header.jpg', 0),

(2, 'Sekiro: Shadows Die Twice',
 'Jogo de ação com combate baseado em espadas.',
 'PC', 274.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/814380/header.jpg', 0),

(1, 'Dark Souls III',
 'RPG de ação conhecido por sua dificuldade.',
 'PC', 229.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/374320/header.jpg', 0),

(1, 'Dark Souls Remastered',
 'RPG de ação e fantasia sombria.',
 'PC', 199.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/570940/header.jpg', 0),

(1, 'Dark Souls II: Scholar of the First Sin',
 'RPG de ação em um mundo sombrio.',
 'PC', 149.90, 8,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/335300/header.jpg', 0),

(1, 'Black Myth: Wukong',
 'RPG de ação inspirado na mitologia chinesa.',
 'PC', 299.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2358720/header.jpg', 0),

(1, 'Lies of P',
 'RPG de ação inspirado na história de Pinóquio.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1627720/header.jpg', 0),

(2, 'Sifu',
 'Jogo de ação focado em artes marciais.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2138710/header.jpg', 0),

(3, 'Stray',
 'Aventura em um mundo futurista habitado por robôs.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1332010/header.jpg', 0),

(2, 'Days Gone',
 'Aventura de ação em um mundo pós-apocalíptico.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1259420/header.jpg', 0),

(3, 'DEATH STRANDING DIRECTOR''S CUT',
 'Aventura de exploração e entrega em um mundo devastado.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1850570/header.jpg', 0),

(2, 'Control Ultimate Edition',
 'Ação e aventura com elementos sobrenaturais.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/870780/header.jpg', 0),

(6, 'DOOM Eternal',
 'FPS de ação em ritmo acelerado.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/782330/header.jpg', 0),

(6, 'DOOM',
 'FPS de ação ambientado em um complexo futurista.',
 'PC', 129.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/379720/header.jpg', 0),

(6, 'Titanfall 2',
 'FPS com campanha e partidas multiplayer.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1237970/header.jpg', 0),

(6, 'Battlefield 1',
 'FPS ambientado durante a Primeira Guerra Mundial.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1238840/header.jpg', 0),

(6, 'Battlefield V',
 'FPS multiplayer ambientado na Segunda Guerra Mundial.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1238810/header.jpg', 0),

(6, 'Battlefield 2042',
 'FPS multiplayer ambientado em um futuro próximo.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1517290/header.jpg', 0),

(2, 'Borderlands 3',
 'RPG de ação com exploração e cooperação.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/397540/header.jpg', 0),

(1, 'Tiny Tina''s Wonderlands',
 'RPG de ação e fantasia.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1286680/header.jpg', 0),

(6, 'Metro Exodus',
 'FPS de sobrevivência em um mundo pós-apocalíptico.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/412020/header.jpg', 0),

(5, 'Dying Light',
 'Sobrevivência e exploração em uma cidade infestada.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/239140/header.jpg', 0),

(5, 'Dying Light 2 Stay Human',
 'Aventura de sobrevivência em um mundo pós-apocalíptico.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/534380/header.jpg', 0),

(5, 'Subnautica',
 'Sobrevivência e exploração em um planeta oceânico.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/264710/header.jpg', 0),

(5, 'Subnautica: Below Zero',
 'Sobrevivência e exploração em uma região congelada.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/848450/header.jpg', 0),

(5, 'No Man''s Sky',
 'Exploração e sobrevivência em um universo procedural.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/275850/header.jpg', 0),

(5, 'Grounded',
 'Aventura e sobrevivência em um quintal gigantesco.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/962130/header.jpg', 0),

(5, 'The Long Dark',
 'Sobrevivência em um ambiente selvagem e congelado.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/305620/header.jpg', 0),

(5, 'Sons Of The Forest',
 'Sobrevivência e exploração em uma ilha misteriosa.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1326470/header.jpg', 0),

(5, 'Valheim',
 'Sobrevivência e exploração em um mundo inspirado na mitologia nórdica.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/892970/header.jpg', 0),

(5, 'Palworld',
 'Sobrevivência, exploração e construção em mundo aberto.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1623730/header.jpg', 0),

(5, 'Raft',
 'Sobrevivência e exploração em alto-mar.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/648800/header.jpg', 0),

(5, 'Project Zomboid',
 'RPG de sobrevivência em um mundo pós-apocalíptico.',
 'PC', 79.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/108600/header.jpg', 0),

(5, 'Factorio',
 'Construção e gerenciamento de fábricas.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/427520/header.jpg', 0),

(5, 'Satisfactory',
 'Construção e gerenciamento de fábricas em primeira pessoa.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/526870/header.jpg', 0),

(3, 'DAVE THE DIVER',
 'Aventura, exploração submarina e gerenciamento de restaurante.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1868140/header.jpg', 0),

(1, 'Sea of Stars',
 'RPG inspirado nos clássicos do gênero.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1244090/header.jpg', 0),

(1, 'Balatro',
 'Roguelike baseado em combinações de cartas.',
 'PC', 49.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2379780/header.jpg', 0),

(1, 'Slay the Spire',
 'Roguelike estratégico baseado em cartas.',
 'PC', 49.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/646570/header.jpg', 0),

(3, 'Celeste',
 'Jogo de plataforma e aventura.',
 'PC', 59.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/504230/header.jpg', 0),

(1, 'Undertale',
 'RPG independente focado em personagens e escolhas.',
 'PC', 39.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/391540/header.jpg', 0),

(3, 'Ori and the Blind Forest: Definitive Edition',
 'Aventura e plataforma em um mundo fantástico.',
 'PC', 59.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/387290/header.jpg', 0),

(3, 'Ori and the Will of the Wisps',
 'Aventura e plataforma com exploração.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1057090/header.jpg', 0),

(1, 'Persona 5 Royal',
 'RPG japonês focado em história e relacionamentos.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1687950/header.jpg', 0),

(1, 'Persona 4 Golden',
 'RPG japonês com investigação e relacionamentos.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1113000/header.jpg', 0),

(1, 'Final Fantasy VII Remake Intergrade',
 'RPG de ação baseado em um clássico da franquia.',
 'PC', 349.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1462040/header.jpg', 0),

(1, 'FINAL FANTASY XV WINDOWS EDITION',
 'RPG de ação e aventura em mundo aberto.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/637650/header.jpg', 0),

(2, 'Yakuza: Like a Dragon',
 'RPG de ação com história e combate por turnos.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1235140/header.jpg', 0),

(2, 'Like a Dragon: Infinite Wealth',
 'RPG de aventura com história e exploração.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2072450/header.jpg', 0),

(2, 'TEKKEN 8',
 'Jogo de luta competitivo.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1778820/header.jpg', 0),

(2, 'Street Fighter 6',
 'Jogo de luta com diversos modos de jogo.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/header.jpg', 0),

(2, 'Mortal Kombat 1',
 'Jogo de luta com diversos personagens.',
 'PC', 249.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1971870/header.jpg', 0),

(3, 'LEGO Star Wars: The Skywalker Saga',
 'Aventura baseada na saga Star Wars.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/920210/header.jpg', 0),

(3, 'A Plague Tale: Requiem',
 'Aventura narrativa ambientada em um período histórico.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1182900/header.jpg', 0),

(3, 'A Plague Tale: Innocence',
 'Aventura narrativa com exploração e sobrevivência.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/752590/header.jpg', 0),

(3, 'Tomb Raider',
 'Aventura de ação e exploração.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/203160/header.jpg', 0),

(3, 'Rise of the Tomb Raider',
 'Aventura de ação e exploração.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/391220/header.jpg', 0),

(3, 'Shadow of the Tomb Raider',
 'Aventura de ação em ambientes variados.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/750920/header.jpg', 0),

(2, 'Mafia: Definitive Edition',
 'Aventura de ação ambientada em uma cidade dos anos 1930.',
 'PC', 199.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1030840/header.jpg', 0),

(2, 'Mafia II: Definitive Edition',
 'Aventura de ação com narrativa cinematográfica.',
 'PC', 149.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1030830/header.jpg', 0),

(1, 'Kingdom Come: Deliverance II',
 'RPG de ação ambientado na Europa medieval.',
 'PC', 299.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1771300/header.jpg', 0),

(1, 'Dragon''s Dogma 2',
 'RPG de ação com exploração e combate.',
 'PC', 299.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/2054970/header.jpg', 0),

(2, 'Hades II',
 'Roguelike de ação com mitologia grega.',
 'PC', 99.90, 10,
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1145350/header.jpg', 0),

(3, 'Cult of the Lamb',
 'Aventura e gerenciamento com elementos roguelike.',
 'PC', 99.90, 10,
 'https://image.api.playstation.com/vulcan/ap/rnd/202512/1518/ea3296f59652aea59db01dd6668c93f1dd23102f84d18807.png', 0);

INSERT INTO jogos
(categoria_id, titulo, descricao, plataforma, preco,
 quantidade_estoque, img_url, destaque_carrossel)
VALUES
(3, 'Portal 2',
 'Resolva quebra-cabeças usando portais em uma instalação de testes cheia de desafios.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/620/library_600x900_2x.jpg', 0),
(3, 'Portal',
 'Use uma arma de portais para superar salas de teste e desvendar os planos da Aperture Science.',
 'PC', 19.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/400/library_600x900_2x.jpg', 0),
(6, 'Half-Life 2',
 'Enfrente uma força invasora em uma aventura de tiro em primeira pessoa com foco na narrativa.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/220/library_600x900_2x.jpg', 0),
(6, 'Half-Life: Alyx',
 'Explore a resistência à Combine em uma aventura de realidade virtual ambientada no universo Half-Life.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/546560/library_600x900_2x.jpg', 0),
(4, 'Left 4 Dead 2',
 'Trabalhe em equipe para atravessar campanhas repletas de infectados e situações imprevisíveis.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/550/library_600x900_2x.jpg', 0),
(6, 'Killing Floor 2',
 'Enfrente hordas de criaturas em partidas cooperativas de tiro em primeira pessoa.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/232090/library_600x900_2x.jpg', 0),
(6, 'PAYDAY 2',
 'Planeje e execute assaltos cooperativos em uma variedade de missões.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/218620/library_600x900_2x.jpg', 0),
(1, 'The Elder Scrolls V: Skyrim Special Edition',
 'Explore uma província fantástica, complete missões e desenvolva seu personagem em um RPG de mundo aberto.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/489830/library_600x900_2x.jpg', 0),
(1, 'Fallout 4',
 'Explore um mundo pós-apocalíptico, construa assentamentos e procure seu filho desaparecido.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/377160/library_600x900_2x.jpg', 0),
(1, 'Fallout: New Vegas',
 'Atravesse o deserto de Mojave e escolha como as facções disputarão o futuro de New Vegas.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/22380/library_600x900_2x.jpg', 0),
(1, 'The Elder Scrolls IV: Oblivion',
 'Percorra Cyrodiil e tente impedir que portais demoníacos ameacem o império.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/22330/library_600x900_2x.jpg', 0),
(1, 'The Elder Scrolls III: Morrowind',
 'Descubra os mistérios de Vvardenfell em um RPG de fantasia com exploração livre.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/22320/library_600x900_2x.jpg', 0),
(1, 'Divinity: Original Sin 2',
 'Reúna aliados e tome decisões que moldam uma aventura de RPG tático em Rivellon.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/435150/library_600x900_2x.jpg', 0),
(1, 'Divinity: Original Sin',
 'Explore Rivellon em um RPG por turnos que permite cooperar e combinar habilidades.',
 'PC', 89.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/373420/library_600x900_2x.jpg', 0),
(1, 'Pillars of Eternity',
 'Investigue um mistério ligado às almas em um RPG de fantasia com escolhas e companheiros.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/291650/library_600x900_2x.jpg', 0),
(1, 'Pathfinder: Wrath of the Righteous',
 'Lidere uma cruzada contra forças demoníacas em um RPG de fantasia baseado em escolhas.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1184370/library_600x900_2x.jpg', 0),
(1, 'Dragon Age: Inquisition',
 'Forme uma equipe de heróis e investigue uma ameaça que atravessa o continente de Thedas.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1222690/library_600x900_2x.jpg', 0),
(1, 'Mass Effect Legendary Edition',
 'Acompanhe a jornada do comandante Shepard nesta coleção de RPGs de ficção científica.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1328670/library_600x900_2x.jpg', 0),
(1, 'Dragon Age: Origins',
 'Escolha sua origem e reúna aliados para enfrentar uma antiga ameaça em Ferelden.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/47810/library_600x900_2x.jpg', 0),
(1, 'Kingdoms of Amalur: Re-Reckoning',
 'Personalize seu herói e explore um mundo de fantasia em uma aventura de RPG de ação.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1041720/library_600x900_2x.jpg', 0),
(1, 'GreedFall',
 'Explore uma ilha desconhecida e negocie alianças em uma aventura de fantasia e intriga.',
 'PC', 89.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/606880/library_600x900_2x.jpg', 0),
(1, 'Outward Definitive Edition',
 'Prepare-se para sobreviver e explorar um mundo de fantasia sem deixar de lado as necessidades do personagem.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/794260/library_600x900_2x.jpg', 0),
(1, 'The Outer Worlds',
 'Explore colônias espaciais e tome decisões que afetam o destino de seus habitantes.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/578650/library_600x900_2x.jpg', 0),
(1, 'Wasteland 3',
 'Comande uma equipe em combates táticos e enfrente escolhas difíceis em um Colorado congelado.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/719040/library_600x900_2x.jpg', 0),
(1, 'Disco Elysium - The Final Cut',
 'Investigue um assassinato e construa a personalidade de um detetive por meio de diálogos e escolhas.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/632470/library_600x900_2x.jpg', 0),
(2, 'Risk of Rain 2',
 'Enfrente criaturas em planetas hostis e combine itens em partidas de ação roguelike.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/632360/library_600x900_2x.jpg', 0),
(2, 'Dead Cells',
 'Lute e explore cenários que mudam a cada tentativa em um jogo de ação e plataforma.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/588650/library_600x900_2x.jpg', 0),
(2, 'Enter the Gungeon',
 'Desça por uma masmorra repleta de armas, inimigos e salas geradas a cada partida.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/311690/library_600x900_2x.jpg', 0),
(2, 'The Binding of Isaac: Rebirth',
 'Enfrente criaturas e descubra combinações de itens em uma aventura roguelike.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/250900/library_600x900_2x.jpg', 0),
(2, 'Rogue Legacy 2',
 'Explore um castelo em constante mudança e continue a aventura com cada nova geração de heróis.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1253920/library_600x900_2x.jpg', 0),
(1, 'Darkest Dungeon',
 'Monte um grupo de aventureiros e enfrente expedições que testam suas habilidades e seu equilíbrio.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/262060/library_600x900_2x.jpg', 0),
(1, 'Into the Breach',
 'Comande equipes de mechas em batalhas táticas por turnos para proteger cidades de criaturas gigantes.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/590380/library_600x900_2x.jpg', 0),
(1, 'FTL: Faster Than Light',
 'Administre uma nave e sua tripulação durante uma viagem espacial com eventos aleatórios.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/212680/library_600x900_2x.jpg', 0),
(1, 'Sid Meier''s Civilization VI',
 'Construa uma civilização ao longo da história e dispute espaço, ciência e influência.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/289070/library_600x900_2x.jpg', 0),
(1, 'Age of Empires II: Definitive Edition',
 'Desenvolva sua civilização e comande exércitos em campanhas e partidas de estratégia em tempo real.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/813780/library_600x900_2x.jpg', 0),
(1, 'Age of Empires IV',
 'Lidere uma civilização em campanhas históricas e batalhas de estratégia em tempo real.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1466860/library_600x900_2x.jpg', 0),
(1, 'Total War: WARHAMMER III',
 'Comande facções fantásticas em campanhas de estratégia e batalhas em larga escala.',
 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1142710/library_600x900_2x.jpg', 0),
(1, 'XCOM 2',
 'Organize a resistência humana e conduza esquadrões em combates táticos por turnos.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/268500/library_600x900_2x.jpg', 0),
(1, 'Sid Meier''s Civilization V',
 'Expanda seu império e conduza uma civilização desde a antiguidade até a era moderna.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/8930/library_600x900_2x.jpg', 0),
(3, 'Cities: Skylines',
 'Planeje bairros, serviços e transportes para construir uma cidade em expansão.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/255710/library_600x900_2x.jpg', 0),
(3, 'Planet Coaster',
 'Projete parques temáticos, crie montanhas-russas e gerencie a experiência dos visitantes.',
 'PC', 129.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/493340/library_600x900_2x.jpg', 0),
(3, 'Planet Zoo',
 'Projete habitats e cuide de animais em um jogo de construção e gerenciamento de zoológicos.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/703080/library_600x900_2x.jpg', 0),
(7, 'Euro Truck Simulator 2',
 'Dirija caminhões por estradas europeias e desenvolva sua própria empresa de transporte.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/227300/library_600x900_2x.jpg', 0),
(7, 'American Truck Simulator',
 'Transporte cargas por cidades e rodovias dos Estados Unidos ao volante de caminhões.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/270880/library_600x900_2x.jpg', 0),
(7, 'F1 24',
 'Dispute corridas de Fórmula 1 e progrida na carreira de piloto.',
 'PC', 299.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2488620/library_600x900_2x.jpg', 0),
(7, 'Assetto Corsa',
 'Dirija carros licenciados em circuitos com foco em simulação de automobilismo.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/244210/library_600x900_2x.jpg', 0),
(7, 'DiRT Rally 2.0',
 'Compita em etapas de rali e gerencie seu carro em diferentes tipos de terreno.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/690790/library_600x900_2x.jpg', 0),
(7, 'Wreckfest',
 'Dispute corridas de contato e derbies de demolição em circuitos com veículos destrutíveis.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/228380/library_600x900_2x.jpg', 0),
(7, 'MotoGP 24',
 'Participe do campeonato de motovelocidade e dispute corridas em circuitos oficiais.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2581700/library_600x900_2x.jpg', 0),
(7, 'EA SPORTS FC 25',
 'Monte seu time e dispute partidas de futebol em diferentes modos de jogo.',
 'PC', 299.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2669320/library_600x900_2x.jpg', 0),
(7, 'Football Manager 2024',
 'Assuma o comando de um clube e tome decisões sobre elenco, tática e temporada.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/library_600x900_2x.jpg', 0),
(7, 'WWE 2K24',
 'Crie lutas e participe de diferentes modos no universo do wrestling profissional.',
 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2315690/library_600x900_2x.jpg', 0),
(7, 'Golf With Your Friends',
 'Jogue minigolfe com amigos em pistas criativas e partidas multiplayer.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/431240/library_600x900_2x.jpg', 0),
(7, 'Tony Hawk''s Pro Skater 1 + 2',
 'Reviva pistas clássicas e execute manobras de skate em desafios solo ou multiplayer.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2395210/library_600x900_2x.jpg', 0),
(7, 'Riders Republic',
 'Explore um mundo aberto e pratique esportes de ação como ciclismo, esqui e snowboard.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2290180/library_600x900_2x.jpg', 0),
(7, 'The Crew Motorfest',
 'Corra em um festival automobilístico de mundo aberto ambientado no Havaí.',
 'PC', 249.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2698940/library_600x900_2x.jpg', 0),
(6, 'Call of Duty: Black Ops III',
 'Enfrente missões de tiro em primeira pessoa com campanha, modo cooperativo e multiplayer.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/311210/library_600x900_2x.jpg', 0),
(6, 'Ready or Not',
 'Coordene uma equipe policial em operações táticas com planejamento e cooperação.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1144200/library_600x900_2x.jpg', 0),
(6, 'Insurgency: Sandstorm',
 'Participe de combates táticos em primeira pessoa com foco em equipes e objetivos.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/581320/library_600x900_2x.jpg', 0),
(6, 'Squad',
 'Trabalhe em equipe em batalhas multiplayer de larga escala com comunicação e estratégia.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/393380/library_600x900_2x.jpg', 0),
(6, 'Arma 3',
 'Crie operações militares e participe de missões em um amplo sandbox tático.',
 'PC', 119.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/107410/library_600x900_2x.jpg', 0),
(6, 'Hell Let Loose',
 'Participe de batalhas multiplayer em larga escala ambientadas na Segunda Guerra Mundial.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/686810/library_600x900_2x.jpg', 0),
(6, 'Sniper Elite 5',
 'Infiltre-se em operações da Segunda Guerra Mundial usando furtividade e tiros de precisão.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1029690/library_600x900_2x.jpg', 0),
(1, 'Total War: Three Kingdoms',
 'Lidere uma facção chinesa em campanhas estratégicas e batalhas em tempo real.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/779340/library_600x900_2x.jpg', 0),
(6, 'Back 4 Blood',
 'Forme uma equipe de sobreviventes e enfrente hordas de infectados em campanhas cooperativas.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/924970/library_600x900_2x.jpg', 0),
(6, 'Battlefield 4',
 'Participe de combates de tiro em primeira pessoa em cenários de guerra modernos.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1238860/library_600x900_2x.jpg', 0),
(1, 'Remnant II',
 'Explore mundos devastados e enfrente criaturas em uma aventura de ação cooperativa.',
 'PC', 179.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1282100/library_600x900_2x.jpg', 0),
(6, 'Halo: The Master Chief Collection',
 'Acompanhe campanhas e partidas multiplayer de diferentes capítulos da série Halo.',
 'PC', 149.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/976730/library_600x900_2x.jpg', 0),
(6, 'Sniper Elite 4',
 'Use furtividade, armadilhas e tiros de precisão em operações ambientadas na Itália durante a guerra.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/312660/library_600x900_2x.jpg', 0),
(6, 'Wolfenstein: The New Order',
 'Lute contra um regime totalitário em uma campanha de tiro em primeira pessoa.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/201810/library_600x900_2x.jpg', 0),
(6, 'Wolfenstein II: The New Colossus',
 'Lidere a resistência em uma aventura de ação e tiro em uma realidade alternativa.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/612880/library_600x900_2x.jpg', 0),
(4, 'Prey',
 'Investigue uma estação espacial e enfrente formas de vida alienígenas usando recursos e habilidades.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/480490/library_600x900_2x.jpg', 0),
(6, 'BioShock Remastered',
 'Explore a cidade submarina de Rapture e descubra os acontecimentos que levaram à sua queda.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/409710/library_600x900_2x.jpg', 0),
(6, 'BioShock Infinite',
 'Viaje à cidade flutuante de Columbia em uma aventura de tiro e ficção científica.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/8870/library_600x900_2x.jpg', 0),
(4, 'Amnesia: The Dark Descent',
 'Explore um castelo sombrio e tente sobreviver enquanto recupera as memórias do protagonista.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/57300/library_600x900_2x.jpg', 0),
(4, 'Outlast',
 'Investigue um hospital abandonado sem armas e tente escapar de seus habitantes.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/238320/library_600x900_2x.jpg', 0),
(4, 'Outlast 2',
 'Investigue um mistério em uma região isolada e fuja dos perigos que cercam a comunidade.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/414700/library_600x900_2x.jpg', 0),
(4, 'SOMA',
 'Descubra os segredos de uma instalação submarina em uma aventura de ficção científica e horror.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/282140/library_600x900_2x.jpg', 0),
(4, 'Little Nightmares',
 'Ajude Six a escapar de uma embarcação sombria repleta de perigos e enigmas.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/424840/library_600x900_2x.jpg', 0),
(4, 'Little Nightmares II',
 'Guie Mono e Six por cenários inquietantes em uma aventura de plataforma e horror.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/860510/library_600x900_2x.jpg', 0),
(4, 'Phasmophobia',
 'Investigue locais assombrados em equipe e reúna evidências sobre presenças paranormais.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/739630/library_600x900_2x.jpg', 0),
(5, 'The Forest',
 'Sobreviva em uma floresta após um acidente, reúna recursos e construa um abrigo.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/242760/library_600x900_2x.jpg', 0),
(5, 'Don''t Starve Together',
 'Reúna recursos e coopere para sobreviver em um mundo selvagem cheio de ameaças.',
 'PC', 27.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/322330/library_600x900_2x.jpg', 0),
(5, '7 Days to Die',
 'Construa defesas, explore o mundo e prepare-se para enfrentar hordas de zumbis.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/251570/library_600x900_2x.jpg', 0),
(5, 'ARK: Survival Ascended',
 'Sobreviva em uma ilha habitada por dinossauros, construa bases e explore em grupo.',
 'PC', 199.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2399830/library_600x900_2x.jpg', 0),
(5, 'Green Hell',
 'Use recursos da floresta amazônica para sobreviver e investigar o desaparecimento de sua equipe.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/815370/library_600x900_2x.jpg', 0),
(1, 'Frostpunk',
 'Administre uma cidade em um inverno extremo e tome decisões para manter a comunidade viva.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/library_600x900_2x.jpg', 0),
(5, 'This War of Mine',
 'Ajude um grupo de civis a sobreviver em uma cidade sitiada e administrar recursos escassos.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/282070/library_600x900_2x.jpg', 0),
(5, 'Oxygen Not Included',
 'Mantenha uma colônia subterrânea funcionando ao administrar oxigênio, energia e alimentos.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/457140/library_600x900_2x.jpg', 0),
(5, 'RimWorld',
 'Gerencie uma colônia em um planeta distante enquanto eventos imprevisíveis mudam cada história.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/294100/library_600x900_2x.jpg', 0),
(3, 'The Witness',
 'Explore uma ilha e resolva quebra-cabeças visuais conectados ao ambiente.',
 'PC', 59.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/210970/library_600x900_2x.jpg', 0),
(3, 'Outer Wilds',
 'Investigue um sistema solar preso em um ciclo e descubra os vestígios de uma civilização antiga.',
 'PC', 99.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/753640/library_600x900_2x.jpg', 0),
(3, 'The Stanley Parable: Ultra Deluxe',
 'Explore um escritório e descubra diferentes caminhos em uma aventura narrativa interativa.',
 'PC', 79.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1703340/library_600x900_2x.jpg', 0),
(3, 'Firewatch',
 'Trabalhe como vigia em uma floresta e investigue acontecimentos estranhos por meio de conversas no rádio.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/383870/library_600x900_2x.jpg', 0),
(3, 'INSIDE',
 'Atravesse cenários misteriosos em uma aventura de plataforma sem diálogos.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/304430/library_600x900_2x.jpg', 0),
(3, 'LIMBO',
 'Guie um garoto por ambientes perigosos em uma aventura de plataforma em tons de cinza.',
 'PC', 19.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/48000/library_600x900_2x.jpg', 0),
(3, 'Journey',
 'Atravesse um vasto deserto em uma aventura de exploração com encontros online opcionais.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/638230/library_600x900_2x.jpg', 0),
(3, 'What Remains of Edith Finch',
 'Explore a casa da família Finch e conheça histórias narrativas sobre seus antigos moradores.',
 'PC', 49.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/501300/library_600x900_2x.jpg', 0),
(3, 'A Short Hike',
 'Explore uma ilha no seu próprio ritmo enquanto ajuda seus moradores e alcança o topo da montanha.',
 'PC', 29.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1055540/library_600x900_2x.jpg', 0),
(3, 'GRIS',
 'Acompanhe uma jovem por cenários ilustrados em uma aventura de plataforma e exploração.',
 'PC', 39.90, 10, 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/683320/library_600x900_2x.jpg', 0);

/*Forza 5 */
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202501/2717/0c5df2b67b23263d055f3b78aeb77a6ce4668bb078fced77.jpg'
where jogo_id = 8;
/*resident evil 4 */
UPDATE jogos
SET img_url = 'https://assets.nintendo.com/image/upload/q_auto/f_auto/store/software/switch/70010000012858/f4d4fd20c956621c4a342a8cade2e366f0e3cd43765bb52eccd0fea32b1606ce'
where jogo_id = 7;
/*Elden Ring */
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202110/2000/YMUoJUYNX0xWk6eTKuZLr5Iw.jpg'
where jogo_id = 6;
/*CYBERPUNK 2077 */
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202111/3013/bxSj4jO0KBqUgAbH3zuNjCje.jpg'
where jogo_id = 5;
/*THE WITCHER 3 */
UPDATE jogos
SET img_url = 'https://assets.nintendo.com/image/upload/c_fill,w_1200/q_auto:best/f_auto/dpr_2.0/store/software/switch2/70010000128692/da1a51c79e918768af5d1556e7416c0bc906665606fd273622ecbbd5cc8cfa26'
where jogo_id = 4;
/*Red dead redemption 2 */
UPDATE jogos
SET img_url = 'https://cdn2.unrealengine.com/Diesel/productv2/heather/home/EGS_RockstarGames_RedDeadRedemption2_G1A_00-1920x1080-308f101576da37225c889173094f373f2afc56c1.jpg'
where jogo_id = 3;
/*gta V*/
UPDATE jogos
SET img_url = 'https://assetsio.gnwcdn.com/eurogamer-zjp1vx.jpg?width=1200&height=600&fit=crop&enable=upscale&auto=webp'
where jogo_id = 2;
/*Minecraft */
UPDATE jogos
SET img_url = 'https://sm.ign.com/ign_br/screenshot/default/tmp-cgtjz0-bb7faa1483782db2-minecraft-horizontal-key-art_n1te.jpg'
where jogo_id = 1;

/*cult of the lamb*/
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202512/1518/ea3296f59652aea59db01dd6668c93f1dd23102f84d18807.png'
where jogo_id = 100;
/*Hades II */
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202603/2318/cabc65dfd2ab1ffa31f51b20b7128ac69491ea9858c0daa3.png'
where jogo_id = 99;
/*Dragon''s Dogma 2*/
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202305/3007/2fff756fa904befe46b838dd6f27fa49f6b53d9f3dbbb776.png'
where jogo_id = 98;
/*Kingdom Come: Deliverance II*/
UPDATE jogos
SET img_url = 'https://image.api.playstation.com/vulcan/ap/rnd/202408/1208/05a84ce968125d79fa36484c5a756a1c8d9b05622aae21c1.png'
where jogo_id = 97;
/*Mafia II: Definitive Edition*/
UPDATE jogos
SET img_url = 'https://assets-prd.ignimgs.com/2020/07/07/mafia-ii-button-fin-1594154630039.jpg?crop=1%3A1%2Csmart&format=jpg&auto=webp&quality=80'
where jogo_id = 96;
/*Mafia: Definitive Edition*/
UPDATE jogos
SET img_url = 'https://cdn1.epicgames.com/ee8802651a004c48999169fa32eb4903/offer/EGS_MafiaDefinitiveEditionPreOrder_Hangar13_S2-1200x1600-3674a5caa0e10eca89feb4dba0484112.jpg'
where jogo_id = 95;

-- God of War
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1593500/library_600x900_2x.jpg'
WHERE jogo_id = 9;

-- God of War Ragnarök
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2322010/library_600x900_2x.jpg'
WHERE jogo_id = 10;

-- Marvel's Spider-Man Remastered
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1817070/library_600x900_2x.jpg'
WHERE jogo_id = 11;

-- Marvel's Spider-Man 2
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2651280/library_600x900_2x.jpg'
WHERE jogo_id = 12;

-- Horizon Zero Dawn
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1151640/library_600x900_2x.jpg'
WHERE jogo_id = 13;

-- Horizon Forbidden West
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2420110/library_600x900_2x.jpg'
WHERE jogo_id = 14;

-- The Last of Us Part I
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1888930/library_600x900_2x.jpg'
WHERE jogo_id = 15;

-- The Last of Us Part II
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2531310/library_600x900_2x.jpg'
WHERE jogo_id = 16;

-- Uncharted: Legacy of Thieves Collection
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1659420/library_600x900_2x.jpg'
WHERE jogo_id = 17;

-- Ghost of Tsushima
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2215430/library_600x900_2x.jpg'
WHERE jogo_id = 18;

-- Assassin's Creed Valhalla
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2208920/library_600x900_2x.jpg'
WHERE jogo_id = 19;

-- Assassin's Creed Odyssey
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/812140/library_600x900_2x.jpg'
WHERE jogo_id = 20;

-- Far Cry 6
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2369390/library_600x900_2x.jpg'
WHERE jogo_id = 21;

-- Resident Evil Village
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1196590/library_600x900_2x.jpg'
WHERE jogo_id = 22;

-- Dead Space
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1693980/library_600x900_2x.jpg'
WHERE jogo_id = 23;

-- Hogwarts Legacy
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/990080/library_600x900_2x.jpg'
WHERE jogo_id = 24;

-- Star Wars Jedi: Survivor
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1774580/library_600x900_2x.jpg'
WHERE jogo_id = 25;

-- Baldur's Gate 3
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1086940/library_600x900_2x.jpg'
WHERE jogo_id = 26;

-- Diablo IV
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2344520/library_600x900_2x.jpg'
WHERE jogo_id = 27;

-- Monster Hunter: World
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/582010/library_600x900_2x.jpg'
WHERE jogo_id = 28;

-- Monster Hunter Wilds
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2246340/library_600x900_2x.jpg'
WHERE jogo_id = 29;

-- Need for Speed Heat
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1222680/library_600x900_2x.jpg'
WHERE jogo_id = 30;

-- Rainbow Six Siege
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/359550/library_600x900_2x.jpg'
WHERE jogo_id = 31;

-- Terraria
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/105600/library_600x900_2x.jpg'
WHERE jogo_id = 32;

-- Stardew Valley
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/413150/library_600x900_2x.jpg'
WHERE jogo_id = 33;

-- Hades
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1145360/library_600x900_2x.jpg'
WHERE jogo_id = 34;

-- Hollow Knight
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/367520/library_600x900_2x.jpg'
WHERE jogo_id = 35;

-- Cuphead
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/268910/library_600x900_2x.jpg'
WHERE jogo_id = 36;

-- It Takes Two
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1426210/library_600x900_2x.jpg'
WHERE jogo_id = 37;

-- Sekiro: Shadows Die Twice
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/814380/library_600x900_2x.jpg'
WHERE jogo_id = 38;

-- Dark Souls III
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/374320/library_600x900_2x.jpg'
WHERE jogo_id = 39;

-- Dark Souls Remastered
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/570940/library_600x900_2x.jpg'
WHERE jogo_id = 40;

-- Dark Souls II: Scholar of the First Sin
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/335300/library_600x900_2x.jpg'
WHERE jogo_id = 41;

-- Black Myth: Wukong
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2358720/library_600x900_2x.jpg'
WHERE jogo_id = 42;

-- Lies of P
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1627720/library_600x900_2x.jpg'
WHERE jogo_id = 43;

-- Sifu
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2138710/library_600x900_2x.jpg'
WHERE jogo_id = 44;

-- Stray
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1332010/library_600x900_2x.jpg'
WHERE jogo_id = 45;

-- Days Gone
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1259420/library_600x900_2x.jpg'
WHERE jogo_id = 46;

-- DEATH STRANDING DIRECTOR'S CUT
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1850570/library_600x900_2x.jpg'
WHERE jogo_id = 47;

-- Control Ultimate Edition
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/870780/library_600x900_2x.jpg'
WHERE jogo_id = 48;

-- DOOM Eternal
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/782330/library_600x900_2x.jpg'
WHERE jogo_id = 49;

-- DOOM
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/379720/library_600x900_2x.jpg'
WHERE jogo_id = 50;

-- Titanfall 2
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1237970/library_600x900_2x.jpg'
WHERE jogo_id = 51;

-- Battlefield 1
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1238840/library_600x900_2x.jpg'
WHERE jogo_id = 52;

-- Battlefield V
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1238810/library_600x900_2x.jpg'
WHERE jogo_id = 53;

-- Battlefield 2042
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1517290/library_600x900_2x.jpg'
WHERE jogo_id = 54;

-- Borderlands 3
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/397540/library_600x900_2x.jpg'
WHERE jogo_id = 55;

-- Tiny Tina's Wonderlands
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1286680/library_600x900_2x.jpg'
WHERE jogo_id = 56;

-- Metro Exodus
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/412020/library_600x900_2x.jpg'
WHERE jogo_id = 57;

-- Dying Light
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239140/library_600x900_2x.jpg'
WHERE jogo_id = 58;

-- Dying Light 2 Stay Human
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/534380/library_600x900_2x.jpg'
WHERE jogo_id = 59;

-- Subnautica
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/264710/library_600x900_2x.jpg'
WHERE jogo_id = 60;

-- Subnautica: Below Zero
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/848450/library_600x900_2x.jpg'
WHERE jogo_id = 61;

-- No Man's Sky
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/275850/library_600x900_2x.jpg'
WHERE jogo_id = 62;

-- Grounded
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/962130/library_600x900_2x.jpg'
WHERE jogo_id = 63;

-- The Long Dark
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/305620/library_600x900_2x.jpg'
WHERE jogo_id = 64;

-- Sons Of The Forest
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1326470/library_600x900_2x.jpg'
WHERE jogo_id = 65;

-- Valheim
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/892970/library_600x900_2x.jpg'
WHERE jogo_id = 66;

-- Palworld
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1623730/library_600x900_2x.jpg'
WHERE jogo_id = 67;

-- Raft
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/648800/library_600x900_2x.jpg'
WHERE jogo_id = 68;

-- Project Zomboid
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/108600/library_600x900_2x.jpg'
WHERE jogo_id = 69;

-- Factorio
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/427520/library_600x900_2x.jpg'
WHERE jogo_id = 70;

-- Satisfactory
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/526870/library_600x900_2x.jpg'
WHERE jogo_id = 71;

-- DAVE THE DIVER
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1868140/library_600x900_2x.jpg'
WHERE jogo_id = 72;

-- Sea of Stars
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1244090/library_600x900_2x.jpg'
WHERE jogo_id = 73;

-- Balatro
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2379780/library_600x900_2x.jpg'
WHERE jogo_id = 74;

-- Slay the Spire
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/646570/library_600x900_2x.jpg'
WHERE jogo_id = 75;

-- Celeste
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/504230/library_600x900_2x.jpg'
WHERE jogo_id = 76;

-- Undertale
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/391540/library_600x900_2x.jpg'
WHERE jogo_id = 77;

-- Ori and the Blind Forest: Definitive Edition
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/387290/library_600x900_2x.jpg'
WHERE jogo_id = 78;

-- Ori and the Will of the Wisps
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1057090/library_600x900_2x.jpg'
WHERE jogo_id = 79;

-- Persona 5 Royal
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1687950/library_600x900_2x.jpg'
WHERE jogo_id = 80;

-- Persona 4 Golden
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1113000/library_600x900_2x.jpg'
WHERE jogo_id = 81;

-- Final Fantasy VII Remake Intergrade
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1462040/library_600x900_2x.jpg'
WHERE jogo_id = 82;

-- FINAL FANTASY XV WINDOWS EDITION
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/637650/library_600x900_2x.jpg'
WHERE jogo_id = 83;

-- Yakuza: Like a Dragon
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1235140/library_600x900_2x.jpg'
WHERE jogo_id = 84;

-- Like a Dragon: Infinite Wealth
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2072450/library_600x900_2x.jpg'
WHERE jogo_id = 85;

-- TEKKEN 8
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1778820/library_600x900_2x.jpg'
WHERE jogo_id = 86;

-- Street Fighter 6
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1364780/library_600x900_2x.jpg'
WHERE jogo_id = 87;

-- Mortal Kombat 1
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1971870/library_600x900_2x.jpg'
WHERE jogo_id = 88;

-- LEGO Star Wars: The Skywalker Saga
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/920210/library_600x900_2x.jpg'
WHERE jogo_id = 89;

-- A Plague Tale: Requiem
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1182900/library_600x900_2x.jpg'
WHERE jogo_id = 90;

-- A Plague Tale: Innocence
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/752590/library_600x900_2x.jpg'
WHERE jogo_id = 91;

-- Tomb Raider
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/203160/library_600x900_2x.jpg'
WHERE jogo_id = 92;

-- Rise of the Tomb Raider
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/391220/library_600x900_2x.jpg'
WHERE jogo_id = 93;

-- Shadow of the Tomb Raider
UPDATE jogos
SET img_url = 'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/750920/library_600x900_2x.jpg'
WHERE jogo_id = 94;