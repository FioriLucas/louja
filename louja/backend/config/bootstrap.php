<?php

define('PROJECT_ROOT', __DIR__);

define('CLASS', PROJECT_ROOT . "/Src/Class/");

// não é utilizado neste projeto
// require_once PROJECT_ROOT . '/vendor/autoload.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

date_default_timezone_set('America/Sao_Paulo');

//você pode definir as suas constantes pessoais para a db aqui. não de commit nesse arquivo (db_constants.php)! adicione ao git ignore
if (file_exists(PROJECT_ROOT . "/db_constants.php")) {
    require_once "db_constants.php";
}
//constantes padrão
if (!defined('DB_HOST')) {
    define('DB_HOST', 'localhost');
}
if (!defined('DB_PORT')) {
    define('DB_PORT', 3306);
}
if (!defined('DB_NAME')) {
    define('DB_NAME', 'loxjaDataBase');
}
if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', 'utf8mb4');
}
if (!defined('DB_USERNAME')) {
    define('DB_USERNAME', 'root');
}
if (!defined('DB_PASSWORD')) {
    define('DB_PASSWORD', '');}