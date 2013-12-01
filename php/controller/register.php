<?php

require_once 'channels.php';

class Controller_register extends Controller {
	private $db = null;
	private $is_valid = true;
	private $is_success = true;
	private $validation_error = array();
	private $submission_error = array();

	function get_channel_id() {
		$pattern = "!http://ch\.nicovideo\.jp/([-0-9A-Z_a-z]+)!";
		if (preg_match($pattern, $this->post["url"], $matches)) {
			$this->channel_id = $matches[1];
		}
	}
	function get_channel_rss() {
		$url = "http://ch.nicovideo.jp/" . $this->channel_id . "/video?rss=2.0";
		$ns = "http://purl.org/dc/elements/1.1/";

		if ($response = @file_get_contents($url)) {
			$document = new SimpleXMLElement($response);
			$this->channel_title =
				(string)$document->channel->children($ns)->creator;
		}
	}
	function get_channel_html() {
		$url = "http://ch.nicovideo.jp/" . $this->channel_id;

		if ($response = @file_get_contents($url)) {
			$document = new DOMDocument();
			@$document->loadHTML($response);
			$metas = $document->getElementsByTagName("meta");

			foreach ($metas as $meta) {
				$name = $meta->getAttribute("name");
				$content = $meta->getAttribute("content");
				if ($name == "description") {
					$this->channel_description = $content;
				} else if ($name == "keywords") {
					$this->channel_keywords = $content;
				}
			}
		}
	}
	function get_channel() {
		$channels = new Model_channels();
		$this->channel = $channels->select_by_nico_channel_id($this->channel_id);
	}

	function validate() {
		$this->get_channel_id();
		$this->get_channel_rss();
		$this->get_channel_html();
		$this->get_channel();

		if (is_null($this->channel_id)) {
			$this->is_valid = false;
			$this->validation_error[] =
				"URLの形式が正しくありません。";
		} else if (is_null($this->channel_title)) {
			$this->is_valid = false;
			$this->validation_error[] =
				"RSSの取得に失敗しました。";
		} else if ($this->channel) {
			$this->is_valid = false;
			$this->validation_error[] =
				"このタイトルはすでに登録されています。";
		}

		return $this->is_valid;
	}
	function submit() {
		$channels = new Model_channels();
		$result = $channels->insert_into(
			$this->channel_id,
			$this->channel_title,
			$this->channel_description,
			$this->channel_keywords);

		if ($result) {
			$this->is_success = true;
		} else {
			$this->is_success = false;
			$this->submission_error[] =
				"タイトルの登録に失敗しました。";
		}

		return $this->is_success;
	}
	function run() {
		if (isset($this->post["confirm"])) {
			$this->validate();
			$this->set("channel_id", $this->channel_id);
			$this->set("channel_title", $this->channel_title);
			$this->set("channel_description", $this->channel_description);
			$this->set("channel_keywords", $this->channel_keywords);

		} else if (isset($this->post["submit"])) {
			$this->validate();
			$this->set("channel_id", $this->channel_id);
			$this->set("channel_title", $this->channel_title);
			$this->set("channel_description", $this->channel_description);
			$this->set("channel_keywords", $this->channel_keywords);

			if ($this->is_valid) {
				$this->submit();
			}
		}

		$this->set("is_valid", $this->is_valid);
		$this->set("validation_error", $this->validation_error);
		$this->set("is_success", $this->is_success);
		$this->set("submission_error", $this->submission_error);
		$this->render();
	}
}
