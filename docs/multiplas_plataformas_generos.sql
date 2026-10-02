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