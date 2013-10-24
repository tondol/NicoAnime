<?php

class Model_videos {
	function __construct() {
		$this->config = &$GLOBALS["config"];
		$this->db = DB::get_instance();
	}

	function select($id) {
		$sql = "SELECT *" .
			" FROM `videos`" .
			" WHERE `id` = ?";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($id));
		return $statement->fetch(PDO::FETCH_ASSOC);
	}
	function select_by_channel_id($channel_id) {
		$sql = "SELECT *" .
			" FROM `videos`" .
			" WHERE `channelId` = ? AND `deletedAt` IS NULL" .
			" ORDER BY `downloadedAt` IS NULL DESC, `downloadedAt` DESC";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($channel_id));
		return $statement->fetchAll(PDO::FETCH_ASSOC);
	}
	function count() {
		$sql = "SELECT COUNT(*) AS `count`, SUM(`filesize`) AS `sum`" .
			" FROM `videos`" .
			" WHERE `deletedAt` IS NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($video_id));
		return $statement->fetchColumn();
	}
	function count_not_downloaded() {
		$sql = "SELECT COUNT(*) AS `count`" .
			" FROM `videos`" .
			" WHERE `downloadedAt` IS NULL AND `deletedAt` IS NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($video_id));
		return $statement->fetchColumn();
	}
	function sum_filesize() {
		$sql = "SELECT SUM(`filesize`) AS `sum`" .
			" FROM `videos`" .
			" WHERE `downloadedAt` IS NOT NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($video_id));
		return $statement->fetchColumn();
	}
}