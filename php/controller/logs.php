<?php

require_once 'channels.php';
require_once 'videos.php';
require_once 'logs.php';

class Controller_logs extends Controller {
	function run() {
		$channels = new Model_channels();
		$videos = new Model_videos();
		$logs = new Model_logs();
		$this->set("logs", $logs->select());
		$this->set("count_channels", $channels->count());
		$this->set("count_not_crawled_channels", $channels->count_not_crawled());
		$this->set("count_videos", $videos->count());
		$this->set("count_not_downloaded_videos", $videos->count_not_downloaded());
		$this->set("sum_filesize", $videos->sum_filesize());
		$this->render();
	}
}
