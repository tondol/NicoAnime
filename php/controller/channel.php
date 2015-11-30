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
	function get_url($chain=null, $params=null) {
		if ((is_null($chain) || $chain == $this->chain) && isset($this->get["id"])) {
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
			$this->channel = $channels->select($this->get["id"]);
			$this->set("channel", $this->channel);
			$this->set("videos", $videos->select_all_by_channel_id($this->get["id"]));
		}

		$this->render();
	}
}
