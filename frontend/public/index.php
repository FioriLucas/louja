<?php
// Inicializa a sessão para verificar o status de login do usuário
session_start();

// Inclui a conexão subindo o diretório correto
require_once __DIR__ . '/../../backend/config/conexao.php';

// Busca os jogos com suas respectivas categorias
try {
    $sql = "SELECT j.jogo_id, j.titulo, j.preco, j.img_url, c.nome AS categoria 
            FROM jogos j
            INNER JOIN categorias c ON j.categoria_id = c.categoria_id
            WHERE j.ativo = 1
            ORDER BY j.jogo_id DESC";
            
    $stmt = $pdo->query($sql);
    $produtos = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $produtos = [];
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Louja - Game Store</title>
    <link rel="stylesheet" href="css/style.css?v=<?php echo time(); ?>">
    
    <!-- GSAP e ScrollTrigger CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/ScrollTrigger.min.js"></script>


</head>
<body>

    <!-- CABEÇALHO -->
    <header>
        <a href="#" class="brand">Louja</a>
        <nav>
            <ul>
                <li><a href="#">Coleção</a></li>
                <li><a href="#">Editorial</a></li>
                <li><a href="#">Buscar</a></li>
                
                <!-- BOTÃO DE LOGIN / PERFIL -->
                <?php if (isset($_SESSION['usr_id'])): ?>
                    <li>
                        <span class="user-name">Olá, <?= htmlspecialchars($_SESSION['usr_nome']) ?></span>
                        <a href="logout.php" class="btn-login" style="background-color: #dc2626;">Sair</a>
                    </li>
                <?php else: ?>
                    <li>
                        <a href="login/login.php" class="btn-login">Entrar</a>
                    </li>
                <?php endif; ?>
            </ul>
        </nav>
    </header>

    <!-- PRODUTOS -->
    <div class="outer-wrapper">
        <div class="horizontal-container" style="width: <?= max(count($produtos), 1) * 100 ?>vw;">
            
            <?php if (!empty($produtos)): ?>
                <?php foreach ($produtos as $produto): ?>
                    <section class="panel">
                        <div class="product-card">
                            <div class="image-container">
                                <img src="<?= htmlspecialchars($produto['img_url'] ?? 'img/placeholder.jpg') ?>" alt="<?= htmlspecialchars($produto['titulo']) ?>">
                            </div>
                            <div class="info-container">
                                <p class="category"><?= htmlspecialchars($produto['categoria']) ?></p>
                                <h2 class="title"><?= htmlspecialchars($produto['titulo']) ?></h2>
                                <p class="price">R$ <?= number_format($produto['preco'], 2, ',', '.') ?></p>
                            </div>
                        </div>
                    </section>
                <?php endforeach; ?>
            <?php else: ?>
                <section class="panel">
                    <div class="product-card" style="justify-content: center; text-align: center;">
                        <div class="info-container" style="width: 100%;">
                            <h2 class="title">NENHUM PRODUTO ENCONTRADO</h2>
                            <p class="category">Cadastre produtos no banco de dados para exibi-los aqui.</p>
                        </div>
                    </div>
                </section>
            <?php endif; ?>

        </div>
    </div>

    <!-- GSAP -->
    <script>
        gsap.registerPlugin(ScrollTrigger);

        const sections = gsap.utils.toArray(".panel");

        if (sections.length > 1) {
            gsap.to(sections, {
                xPercent: -100 * (sections.length - 1),
                ease: "none",
                scrollTrigger: {
                    trigger: ".horizontal-container",
                    pin: true,
                    scrub: 1,
                    end: () => "+=" + document.querySelector(".horizontal-container").offsetWidth
                }
            });
        }
    </script>
</body>
</html>