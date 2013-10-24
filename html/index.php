<?php

ini_set('display_errors', true);
ini_set('error_reporting', E_ALL ^ E_NOTICE);

require_once 'config.php';
require_once 'application.php';

$app = new Application();
$app->run();
