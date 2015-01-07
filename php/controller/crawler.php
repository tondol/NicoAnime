<?php

require_once 'channels.php';

class Controller_crawler extends Controller {
	function run() {
		$channels = new Model_channels();
		$this->set("channels", $channels->select_all_not_crawled());
		$this->render();
	}
}
