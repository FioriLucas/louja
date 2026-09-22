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
 'https://cdn.cloudflare.steamstatic.com/steam/apps/1313140/header.jpg', 0);
