<?php

define('PHP_DIR', dirname(__FILE__) . '/');
define('SYSTEM_DIR', dirname(PHP_DIR) . '/');
define('PUBLIC_DIR', SYSTEM_DIR . 'public/');
define('CORE_DIR', PHP_DIR . 'core/');
define('CONTROLLER_DIR', PHP_DIR . 'controller/');
define('TEMPLATE_DIR', PHP_DIR . 'template/');
define('SPYC_DIR', PHP_DIR . 'spyc/');

ini_set('display_errors', true);
ini_set('error_reporting', E_ALL ^ E_NOTICE);
ini_set('include_path', ini_get('include_path') . ':' . CORE_DIR . ':' . SPYC_DIR);
ini_set('date.timezone', "Asia/Tokyo");

require_once 'Spyc.php';

$config = array(
	'controller_dir' => CONTROLLER_DIR,
	'template_dir' => TEMPLATE_DIR,
	'public_dir' => PUBLIC_DIR,

	'application_uri' => 'https://anime.tondol.com/',
	'application_main' => 'index',
	'application_title' => 'NicoAnime',
	'application_missing' => 'missing',

	'chain' => array(
		'index' => 'index',
		'channel' => 'channel',
		'channel/video' => 'video',
		'channel/delete' => 'delete',
		'channel/video/delete' => 'delete',
		'crawler' => 'crawler',
		'crawler/register' => 'register',
		'downloader' => 'downloader',
		'logs' => 'logs',
		'help' => 'help',
		'missing' => 'missing',
	),
);

$config = array_merge($config, Spyc::YAMLLoad(SYSTEM_DIR . 'config.yml'));
