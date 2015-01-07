<?php

require_once 'videos.php';

class Controller_downloader extends Controller {
	function run() {
		$videos = new Model_videos();
		$this->set("videos", $videos->select_all_not_downloaded());
		$this->render();
	}
}
