<?php

require_once 'db.php';

class Model_videos {
	function __construct() {
		$this->config = &$GLOBALS["config"];
		$this->db = DB::get_instance();
	}

	function select($id) {
		// 論理削除済みのものも取得可能
		$sql = "SELECT `videos`.*, `channels`.`service`" .
			" FROM `videos`" .
			" LEFT JOIN `channels` ON `channels`.`id` = `videos`.`channelId`" .
			" WHERE `videos`.`id` = ?";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($id));
		return $statement->fetch(PDO::FETCH_ASSOC);
	}
	function select_all_by_channel_id($channel_id) {
		$sql = "SELECT `videos`.*, `channels`.`service`" .
			" FROM `videos`" .
			" LEFT JOIN `channels` ON `channels`.`id` = `videos`.`channelId`" .
			" WHERE `channelId` = ?" .
			" ORDER BY `downloadedAt` IS NULL ASC," .
                        " `deletedAt` IS NULL DESC," .
                        " `downloadedAt` DESC";
		$statement = $this->db->prepare($sql);
		$statement->execute(array($channel_id));
		return $statement->fetchAll(PDO::FETCH_ASSOC);
	}
	function select_all_not_downloaded() {
		// 論理削除されたものをダウンロード対象から除く
		$sql = "SELECT `videos`.*, `channels`.`service` FROM `videos`" .
			" LEFT JOIN `channels` ON `channels`.`id` = `videos`.`channelId`" .
			" WHERE `downloadedAt` IS NULL AND `deletedAt` IS NULL" .
			" ORDER BY `createdAt` ASC";
		$statement = $this->db->prepare($sql);
		$statement->execute();
		return $statement->fetchAll(PDO::FETCH_ASSOC);
	}
	function count() {
		$sql = "SELECT COUNT(*) AS `count`, SUM(`filesize`) AS `sum`" .
			" FROM `videos`" .
			" WHERE `deletedAt` IS NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute();
		return $statement->fetchColumn();
	}
	function delete_logically($id) {
		$sql = "UPDATE `videos`" .
			" SET `deletedAt` = ?" .
			" WHERE `id` = ?";
		$statement = $this->db->prepare($sql);
		return $statement->execute(array(
			current_date(),
			$id,
		));
	}
	function delete_by_channel_id($channel_id) {
		$sql = "DELETE FROM `videos`" .
			" WHERE `channelId` = ?";
		$statement = $this->db->prepare($sql);
		return $statement->execute(array($channel_id));
	}
	function count_not_downloaded() {
		$sql = "SELECT COUNT(*) AS `count`" .
			" FROM `videos`" .
			" WHERE `downloadedAt` IS NULL AND `deletedAt` IS NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute();
		return $statement->fetchColumn();
	}
	function sum_filesize() {
		$sql = "SELECT SUM(`filesize`) AS `sum`" .
			" FROM `videos`" .
			" WHERE `downloadedAt` IS NOT NULL AND `deletedAt` IS NULL";
		$statement = $this->db->prepare($sql);
		$statement->execute();
		return $statement->fetchColumn();
	}
}
