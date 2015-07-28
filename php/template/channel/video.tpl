<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<?php
	$video = $this->get("video");
	$video_url = $this->config["contents_url"] . $video["filename"];
	$thumb_url = $this->config["contents_url"] . $video["nicoVideoId"] . ".jpg";
	$comments_url = $this->config["contents_url"] . $video["nicoVideoId"] . ".xml";
	$filesize = sprintf("%.2f", $video["filesize"] / 1000000.0);
?>

<div class="page-header">
	<h1><?= h($this->get_title()) ?></h1>
</div>
<div class="page-header">
	<h2>player <small>再生</small></h2>
</div>

<div id="player"></div> 
<script type="text/javascript">
	var player = jwplayer("player");
	player.setup({
		file: "<?= h($video_url) ?>",
		image: "<?= h($thumb_url) ?>",
		width: 640,
		height: 360
	});
</script>

<div class="page-header">
	<h2>summary <small>概要</small></h2>
</div>

<dl>
	<dt>説明文</dt>
	<dd><?= h($video["description"]) ?></dd>
	<dt>登録日時</dt>
<?php if (isset($video["createdAt"])): ?>
	<dd><?= h($video["createdAt"]) ?></dd>
<?php else: ?>
	<dd>記録なし</dd>
<?php endif ?>
	<dt>ダウンロード日時</dt>
<?php if (isset($video["downloadedAt"])): ?>
	<dd><?= h($video["downloadedAt"]) ?></dd>
<?php else: ?>
	<dd>記録なし</dd>
<?php endif ?>
</dl>

<p>
	<a href="<?= h($video_url) ?>" class="btn btn-primary">
		動画のダウンロード（<?= h($filesize) ?>MB）
	</a>
	<a href="<?= h($comments_url) ?>" class="btn btn-default">
		コメントのダウンロード
	</a>
	<a href="http://www.nicovideo.jp/watch/<?= h($video["nicoVideoId"]) ?>" class="btn btn-default">
		公式動画
	</a>
</p>

<div class="page-header">
	<h2>maintenance <small>管理</small></h2>
</div>

<p>
<?php
	$delete_url = $this->get_url("channel/video/delete") . "?id=" . $this->video['id'];
?>
	<a href="<?= h($delete_url) ?>" class="btn btn-danger">この動画を削除する</a>
</p>

<?php $this->include_template('include/footer.tpl') ?>
