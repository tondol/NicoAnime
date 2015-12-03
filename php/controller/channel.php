<?php

require_once 'channels.php';
require_once 'videos.php';
require_once 'controller_anime.php';

class Controller_channel extends Controller_anime {
	function get_title($chain=null) {
		return $this->get_title_helper($chain, array(
			$this->chain => $this->channel['title'],
		));
	}
	function get_url($chain=null, $params=null) {
		return $this->get_url_helper($chain, $params, array(
			$this->chain => array('id' => $this->channel['id']),
		));
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
