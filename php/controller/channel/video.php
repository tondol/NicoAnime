<?php

require_once 'channels.php';
require_once 'videos.php';

class Controller_channel_video extends Controller {
	function get_title($chain=null) {	
		return $this->video["title"];
	}
	function get_url($chain=null) {
		if ((is_null($chain) || $chain == $this->chain) && isset($this->get["id"])) {
			return parent::get_url() . "?id=" . $this->video["id"];
		} else if ($chain == "channel" && isset($this->get["id"])) {
			return parent::get_url($chain) . "?id=" . $this->channel["id"];
		} else {
			return parent::get_url($chain);
		}
	}

	function run() {
		$channels = new Model_channels();
		$videos = new Model_videos();

		if (isset($this->get["id"])) {
			$this->channel = $channels->select_by_video_id($this->get["id"]);
			$this->video = $videos->select($this->get["id"]);
			$this->set("channel", $this->channel);
			$this->set("video", $this->video);
		}

		$this->render();
	}
}
