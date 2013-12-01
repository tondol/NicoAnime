<?php

require_once 'channels.php';

class Controller_index extends Controller {
	function run() {
		$channels = new Model_channels();
		$this->set("channels", $channels->select_all_with_videos());
		$this->render();
	}
}
