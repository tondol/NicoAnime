<?php

require_once 'channels.php';
require_once 'videos.php';
require_once 'logs.php';
require_once 'controller_anime.php';

class Controller_channel_delete extends Controller_anime {
	private $db = null;
	private $is_valid = true;
	private $is_success = true;
	private $validation_error = array();
	private $submission_error = array();

	function get_url($chain=null, $params=null) {
		return $this->get_url_helper($chain, $params, array(
			$this->chain => array('id' => $this->channel['id']),
			'channel' => array('id' => $this->channel['id']),
		));
	}

	function get_channel() {
		$channels = new Model_channels();
		$this->channel = $channels->select($this->get['id']);
	}
	// @todo
	function clean_files($video) {
		$filename = $video["filename"];
		$filepath = $this->config["contents_dir"] . "/" . $filename;
		if (empty($filename)) {
			return;
		}
		if (file_exists($filepath)) {
			unlink($filepath);
		}

		$filename = $video["serviceVideoId"] . ".jpg";
		$filepath = $this->config["contents_dir"] . "/" . $filename;
		if (file_exists($filepath)) {
			unlink($filepath);
		}

		$filename = $video["serviceVideoId"] . ".xml";
		$filepath = $this->config["contents_dir"] . "/" . $filename;
		if (file_exists($filepath)) {
			unlink($filepath);
		}
	}

	function validate() {
		$this->get_channel();

		if (empty($this->channel)) {
			$this->is_valid = false;
			$this->validation_error[] =
				"無効なタイトルが指定されました。";
		}
		if ((isset($this->post["confirm"]) || isset($this->post["submit"])) &&
				$this->post["serviceChannelId"] != $this->channel["serviceChannelId"]) {
			$this->is_valid = false;
			$this->validation_error[] =
				"確認用のチャンネル名が正しくありません。";
		}

		return $this->is_valid;
	}
	function submit() {
		$channels = new Model_channels();
		$videos = new Model_videos();
		$logs = new Model_logs();

		$video_array = $videos->select_all_by_channel_id($this->channel["id"]);
		foreach ($video_array as $video) {
			$this->clean_files($video);
		}
		$videos->delete_by_channel_id($this->channel["id"]);
		$channels->delete($this->channel["id"]);
		$logs->d("front", "channel/delete: " . $this->channel["title"]);

		$this->is_success = true;
		return $this->is_success;
	}
	function run() {
		if (isset($this->post["confirm"])) {
			$this->validate();
			$this->set("channel", $this->channel);
		} else if (isset($this->post["submit"])) {
			$this->validate();
			$this->set("channel", $this->channel);

			if ($this->is_valid) {
				$this->submit();
			}
		} else {
			$this->validate();
			$this->set("channel", $this->channel);
		}

		$this->set("is_valid", $this->is_valid);
		$this->set("validation_error", $this->validation_error);
		$this->set("is_success", $this->is_success);
		$this->set("submission_error", $this->submission_error);
		$this->render();
	}
}
