<?php

require_once 'channels.php';
require_once 'videos.php';

class Controller_channel extends Controller {
	function get_title($chain=null) {	
		if ((is_null($chain) || $chain == $this->chain) && isset($this->get["id"])) {
			return $this->channel["title"];
		} else {
			return parent::get_title($chain);
		}
	}
	function get_uri($chain=null) {
		if ((is_null($chain) || $chain == $this->chain) && isset($this->get["id"])) {
			return parent::get_uri() . "?id=" . $this->channel["id"];
		} else {
			return parent::get_uri($chain);
		}
	}

	function run() {
		$channels = new Model_channels();
		$videos = new Model_videos();

		if (isset($this->get["id"])) {
			$this->channel = $channels->select($this->get["id"]);
			$this->set("channel", $this->channel);
			$this->set("videos", $videos->select_all_by_channel_id($this->get["id"]));
		}

		$this->render();
	}
}
