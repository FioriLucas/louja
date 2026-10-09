<?php
session_start();
require_once __DIR__ . '/../../../backend/config/conexao.php';
require_once __DIR__ . '/../../../backend/config/pedidos.php';

if (!isset($_SESSION['usr_id']) || ($_SESSION['usr_perfil'] ?? '') !== 'admin') {
    header('Location: ../login.php');
    exit;
}

garantirTabelasPedidos($pdo);

$statusPermitidos = ['pendente', 'pago', 'enviado', 'cancelado'];
$nomesStatus = [
    'pendente' => 'Pendente',
    'pago' => 'Pago',
    'enviado' => 'Enviado',
    'cancelado' => 'Cancelado'
];
$nomesPagamento = [
    'cartao' => 'Cartão',
    'pix' => 'Pix',
    'boleto' => 'Boleto'
];
$statusFiltro = $_GET['status'] ?? '';
if (!in_array($statusFiltro, $statusPermitidos, true)) {
    $statusFiltro = '';
}

$validarData = static function ($valor): bool {
    if (!is_string($valor) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $valor)) {
        return false;
    }
    $data = DateTimeImmutable::createFromFormat('!Y-m-d', $valor);
    return $data !== false && $data->format('Y-m-d') === $valor;
};
$dataInicio = $validarData($_GET['inicio'] ?? null) ? $_GET['inicio'] : '';
$dataFim = $validarData($_GET['fim'] ?? null) ? $_GET['fim'] : '';
$condicoes = [];
$parametros = [];

if ($statusFiltro !== '') {
    $condicoes[] = 'p.status = ?';
    $parametros[] = $statusFiltro;
}
if ($dataInicio !== '') {
    $condicoes[] = 'p.data_pedido >= ?';
    $parametros[] = $dataInicio . ' 00:00:00';
}
if ($dataFim !== '') {
    $fimExclusivo = (new DateTimeImmutable($dataFim))->modify('+1 day')->format('Y-m-d');
    $condicoes[] = 'p.data_pedido < ?';
    $parametros[] = $fimExclusivo . ' 00:00:00';
}
$whereSql = $condicoes ? ' WHERE ' . implode(' AND ', $condicoes) : '';

$mensagem = $_SESSION['flash_vendas'] ?? null;
unset($_SESSION['flash_vendas']);

$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS quantidade,
            COALESCE(SUM(CASE WHEN p.status IN ('pago', 'enviado') THEN p.valor_total ELSE 0 END), 0) AS total_recebido,
            COALESCE(SUM(CASE WHEN p.status = 'pendente' THEN 1 ELSE 0 END), 0) AS pendentes
     FROM pedidos AS p$whereSql"
);
$stmt->execute($parametros);
$resumo = $stmt->fetch();
$totalPedidos = (int) $resumo['quantidade'];
$porPagina = 50;
$totalPaginas = max(1, (int) ceil($totalPedidos / $porPagina));
$pagina = max(1, min($totalPaginas, (int) ($_GET['pagina'] ?? 1)));
$offset = ($pagina - 1) * $porPagina;

$stmt = $pdo->prepare("SELECT p.pedido_id, p.data_pedido, p.status, p.valor_total, p.forma_pagamento,
                              u.nome AS cliente, u.email,
                              COALESCE(itens.resumo, '') AS resumo_itens
                       FROM pedidos AS p
                       JOIN usuarios AS u ON u.usr_id = p.usr_id
                       LEFT JOIN (
                           SELECT ip.pedido_id,
                                  GROUP_CONCAT(CONCAT(ip.quantidade, 'x ', j.titulo) ORDER BY j.titulo SEPARATOR ', ') AS resumo
                           FROM itens_pedido AS ip
                           JOIN jogos AS j ON j.jogo_id = ip.jogo_id
                           GROUP BY ip.pedido_id
                       ) AS itens ON itens.pedido_id = p.pedido_id$whereSql
                       ORDER BY p.data_pedido DESC, p.pedido_id DESC
                       LIMIT $porPagina OFFSET $offset");
$stmt->execute($parametros);
$pedidos = $stmt->fetchAll();

$urlPagina = static function (int $numero) use ($statusFiltro, $dataInicio, $dataFim): string {
    $filtros = array_filter([
        'status' => $statusFiltro,
        'inicio' => $dataInicio,
        'fim' => $dataFim,
        'pagina' => $numero
    ], static fn($valor) => $valor !== '');
    return 'vendas.php?' . http_build_query($filtros);
};
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendas - Admin Louja</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<header>
    <a href="../index.php" class="logo">
        <img src="../../../docs/logolouja.png" alt="Louja">
    </a>
    <nav>
        <a href="index.php">Jogos</a>
        <a href="vendas.php" aria-current="page">Vendas</a>
        <span>Ol&aacute;, <?= htmlspecialchars($_SESSION['usr_nome'] ?? 'Admin') ?></span>
        <a href="../index.php">Voltar para a loja</a>
        <a href="../logout.php">Sair</a>
    </nav>
</header>

<main class="admin">
    <div class="admin-cabecalho">
        <div>
            <h1>Relat&oacute;rio de vendas</h1>
            <p>Consulte pedidos, acompanhe pagamentos e atualize o status das vendas.</p>
        </div>
    </div>

    <form method="get" class="vendas-filtros" aria-label="Filtrar vendas">
        <label>
            <span>Status</span>
            <select name="status">
                <option value="">Todos</option>
                <?php foreach ($nomesStatus as $valor => $nome): ?>
                    <option value="<?= $valor ?>" <?= $statusFiltro === $valor ? 'selected' : '' ?>><?= $nome ?></option>
                <?php endforeach; ?>
            </select>
        </label>
        <label>
            <span>De</span>
            <input type="date" name="inicio" value="<?= htmlspecialchars($dataInicio) ?>">
        </label>
        <label>
            <span>Até</span>
            <input type="date" name="fim" value="<?= htmlspecialchars($dataFim) ?>">
        </label>
        <button class="botao" type="submit">Filtrar</button>
        <a href="vendas.php">Limpar</a>
    </form>

    <?php if ($mensagem): ?>
        <p class="vendas-mensagem <?= $mensagem['tipo'] === 'erro' ? 'vendas-mensagem-erro' : '' ?>" role="status">
            <?= htmlspecialchars($mensagem['texto']) ?>
        </p>
    <?php endif; ?>

    <section class="vendas-resumo" aria-label="Resumo das vendas filtradas">
        <article>
            <span>Pedidos</span>
            <strong><?= number_format($totalPedidos, 0, ',', '.') ?></strong>
        </article>
        <article>
            <span>Total recebido</span>
            <strong>R$ <?= number_format((float) $resumo['total_recebido'], 2, ',', '.') ?></strong>
        </article>
        <article>
            <span>Pendentes</span>
            <strong><?= number_format((int) $resumo['pendentes'], 0, ',', '.') ?></strong>
        </article>
    </section>

    <div class="vendas-tabela-wrap">
        <table class="vendas-tabela">
            <thead>
                <tr>
                    <th>Pedido</th>
                    <th>Cliente</th>
                    <th>Itens</th>
                    <th>Pagamento</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Análise</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($pedidos as $pedido): ?>
                    <tr>
                        <td><a class="venda-detalhe-link" href="venda.php?id=<?= (int) $pedido['pedido_id'] ?>">#<?= (int) $pedido['pedido_id'] ?></a><br><small><?= htmlspecialchars(date('d/m/Y H:i', strtotime($pedido['data_pedido']))) ?></small></td>
                        <td><?= htmlspecialchars($pedido['cliente']) ?><br><small><?= htmlspecialchars($pedido['email']) ?></small></td>
                        <td><?= htmlspecialchars($pedido['resumo_itens'] ?: 'Sem itens') ?></td>
                        <td><?= htmlspecialchars($nomesPagamento[$pedido['forma_pagamento']] ?? 'N&atilde;o informado') ?></td>
                        <td>R$ <?= number_format((float) $pedido['valor_total'], 2, ',', '.') ?></td>
                        <td><span class="vendas-status vendas-status-<?= htmlspecialchars($pedido['status']) ?>"><?= htmlspecialchars($nomesStatus[$pedido['status']] ?? $pedido['status']) ?></span></td>
                        <td><a class="venda-detalhe-link" href="venda.php?id=<?= (int) $pedido['pedido_id'] ?>">Conferir dados</a></td>
                    </tr>
                <?php endforeach; ?>
                <?php if (!$pedidos): ?>
                    <tr><td colspan="7" class="vendas-vazio">Nenhum pedido encontrado para estes filtros.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <?php if ($totalPaginas > 1): ?>
        <nav class="vendas-paginacao" aria-label="Paginação de vendas">
            <?php if ($pagina > 1): ?><a href="<?= htmlspecialchars($urlPagina($pagina - 1)) ?>">Anterior</a><?php endif; ?>
            <span>Página <?= $pagina ?> de <?= $totalPaginas ?></span>
            <?php if ($pagina < $totalPaginas): ?><a href="<?= htmlspecialchars($urlPagina($pagina + 1)) ?>">Próxima</a><?php endif; ?>
        </nav>
    <?php endif; ?>
</main>
</body>
</html>