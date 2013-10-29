<?php

require_once dirname(__FILE__) . '/config.php';
require_once dirname(__FILE__) . '/core/application.php';

$app = new Application();
$app->run();
