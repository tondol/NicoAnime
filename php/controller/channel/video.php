<?php

require_once 'channels.php';
require_once 'videos.php';

class Controller_channel_video extends Controller {
	function get_title($chain=null) {	
		return $this->video["title"];
	}
	function get_url($chain=null, $params=null) {
		if ((is_null($chain) || $chain == $this->chain) && isset($this->video["id"])) {
			$params = array_merge(
				array('id' => $this->video['id']),
				is_null($params) ? array() : $params
			);
		} else if ($chain == "channel" && isset($this->video["id"])) {
			$params = array_merge(
				array('id' => $this->channel['id']),
				is_null($params) ? array() : $params
			);
		}
		return parent::get_url($chain, $params);
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
