<?php

function garantirTabelasPedidos(PDO $pdo): void
{
    $pdo->exec("CREATE TABLE IF NOT EXISTS pedidos (
        pedido_id INT AUTO_INCREMENT PRIMARY KEY,
        usr_id INT NOT NULL,
        data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
        status ENUM('pendente', 'pago', 'enviado', 'cancelado') DEFAULT 'pendente',
        forma_pagamento ENUM('cartao', 'pix', 'boleto') NOT NULL DEFAULT 'pix',
        dados_cliente_verificados TINYINT(1) NOT NULL DEFAULT 0,
        dados_verificados_por INT DEFAULT NULL,
        dados_verificados_em DATETIME DEFAULT NULL,
        valor_total DECIMAL(10,2) DEFAULT 0.00,
        FOREIGN KEY (usr_id) REFERENCES usuarios(usr_id) ON DELETE CASCADE
    )");
    $pdo->exec("CREATE TABLE IF NOT EXISTS itens_pedido (
        item_id INT AUTO_INCREMENT PRIMARY KEY,
        pedido_id INT NOT NULL,
        jogo_id INT NOT NULL,
        quantidade INT NOT NULL DEFAULT 1,
        preco_unitario DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
        FOREIGN KEY (jogo_id) REFERENCES jogos(jogo_id) ON DELETE CASCADE
    )");

    $colunaPagamento = $pdo->query("SHOW COLUMNS FROM pedidos LIKE 'forma_pagamento'");
    if (!$colunaPagamento->fetch()) {
        $pdo->exec("ALTER TABLE pedidos ADD forma_pagamento ENUM('cartao', 'pix', 'boleto') NOT NULL DEFAULT 'pix'");
    }

    $colunasVerificacao = [
        'dados_cliente_verificados' => 'TINYINT(1) NOT NULL DEFAULT 0',
        'dados_verificados_por' => 'INT DEFAULT NULL',
        'dados_verificados_em' => 'DATETIME DEFAULT NULL'
    ];
    foreach ($colunasVerificacao as $nome => $definicao) {
        $coluna = $pdo->query("SHOW COLUMNS FROM pedidos LIKE '$nome'");
        if (!$coluna->fetch()) {
            $pdo->exec("ALTER TABLE pedidos ADD $nome $definicao");
        }
    }
}

function atualizarStatusPedido(PDO $pdo, int $pedidoId, string $novoStatus): void
{
    $statusPermitidos = ['pendente', 'pago', 'enviado', 'cancelado'];
    if (!in_array($novoStatus, $statusPermitidos, true)) {
        throw new RuntimeException('Status de pedido inválido.');
    }

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare('SELECT status FROM pedidos WHERE pedido_id = ? FOR UPDATE');
        $stmt->execute([$pedidoId]);
        $statusAnterior = $stmt->fetchColumn();

        if ($statusAnterior === false) {
            throw new RuntimeException('Pedido não encontrado.');
        }

        if ($statusAnterior !== $novoStatus) {
            $transicoesPermitidas = [
                'pendente' => ['pago', 'cancelado'],
                'pago' => ['enviado'],
                'enviado' => [],
                'cancelado' => []
            ];
            if (!in_array($novoStatus, $transicoesPermitidas[$statusAnterior] ?? [], true)) {
                throw new RuntimeException('Esta mudança de status não é permitida.');
            }
        }

        if ($statusAnterior === 'pendente' && $novoStatus === 'cancelado') {
            $stmtItens = $pdo->prepare('SELECT jogo_id, quantidade FROM itens_pedido WHERE pedido_id = ?');
            $stmtItens->execute([$pedidoId]);
            $itens = $stmtItens->fetchAll();
            $stmtRestaurar = $pdo->prepare('UPDATE jogos SET quantidade_estoque = quantidade_estoque + ? WHERE jogo_id = ?');

            foreach ($itens as $item) {
                $quantidade = (int) $item['quantidade'];
                $jogoId = (int) $item['jogo_id'];
                $stmtRestaurar->execute([$quantidade, $jogoId]);
            }
        }

        $stmt = $pdo->prepare('UPDATE pedidos SET status = ? WHERE pedido_id = ?');
        $stmt->execute([$novoStatus, $pedidoId]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $e;
    }
}