<?php
$url = 'https://economia.awesomeapi.com.br/json/last/USD-BRL,CNY-BRL';
$contexto = stream_context_create([
    'http' => [
        'timeout' => 8,
        'header' => "Accept: application/json\r\n"
    ]
]);

header('Content-Type: application/json; charset=utf-8');

$json = @file_get_contents($url, false, $contexto);
if ($json === false) {
    http_response_code(502);
    echo json_encode(['erro' => 'Não foi possível consultar as cotações agora.']);
    exit;
}

$dados = json_decode($json, true);
$cotacoes = [];
foreach (['USDBRL' => 'USD', 'CNYBRL' => 'CNY'] as $par => $moeda) {
    $cotacao = $dados[$par] ?? null;
    if (!is_array($cotacao) || !is_numeric($cotacao['bid'] ?? null) || !is_numeric($cotacao['pctChange'] ?? null)) {
        http_response_code(502);
        echo json_encode(['erro' => 'A resposta da API de cotações está inválida.']);
        exit;
    }

    $cotacoes[$moeda] = [
        'bid' => (float) $cotacao['bid'],
        'pctChange' => (float) $cotacao['pctChange']
    ];
}

echo json_encode($cotacoes, JSON_UNESCAPED_UNICODE);
?>