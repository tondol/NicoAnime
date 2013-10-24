<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<?php
	$channel = $this->get("channel");
?>

<div class="page-header">
	<h1><?= h($channel["title"]) ?></h1>
</div>
<div class="page-header">
	<h2>videos <small>動画一覧</small></h2>
</div>

<div class="row">
<?php foreach ($this->get("videos") as $i => $video): ?>
	<?php
		$video_url = $this->get_url("channel/video") . "?id=" . $video["id"];
		$thumb_url = $this->get_static("contents/" . $video["nicoVideoId"] . ".jpg");
		$unavailable_url = $this->get_static("assets/images/unavailable.png");
		$filesize = sprintf("%.2f", $video["filesize"] / 1000000.0);
	?>
	<div class="col-sm-4 col-md-3">
		<div class="thumbnail">
	<?php if (isset($video["downloadedAt"])): ?>
			<a href="<?= h($video_url) ?>">
				<img src="<?= h($thumb_url) ?>" />
			</a>
	<?php else: ?>
				<img src="<?= h($unavailable_url) ?>" />
	<?php endif ?>
			<div class="caption">
				<p><?= h($video["title"]) ?></p>
	<?php if (isset($video["downloadedAt"])): ?>
				<p><a href="<?= h($video_url) ?>" class="btn btn-primary">
					再生する（<?= h($filesize) ?>MB）
				</a></p>
	<?php else: ?>
				<p><a class="btn btn-primary disabled">未ダウンロード</a></p>
	<?php endif ?>
			</div><!-- /caption -->
		</div><!-- /thumbnail -->
	</div><!-- /col -->
<?php endforeach ?>
</div><!-- /row -->

<?php if (!count($this->get("videos"))): ?>
<p>動画がありません。</p>
<?php endif ?>

<div class="page-header">
	<h2>summary <small>概要</small></h2>
</div>

<dl>
	<dt>説明文</dt>
	<dd><?= h($channel["description"]) ?></dd>
	<dt>キーワード</dt>
	<dd><?= h($channel["keywords"]) ?></dd>
	<dt>登録日時</dt>
	<dd><?= h($channel["createdAt"]) ?></dd>
	<dt>更新日時</dt>
<?php if (isset($channel["modifiedAt"])): ?>
	<dd><?= h($channel["modifiedAt"]) ?></dd>
<?php else: ?>
	<dd>記録なし</dd>
<?php endif ?>
	<dt>最終取得日時</dt>
<?php if (isset($channel["crawledAt"])): ?>
	<dd><?= h($channel["crawledAt"]) ?></dd>
<?php else: ?>
	<dd>記録なし</dd>
<?php endif ?>
</dl>

<p>
	<a href="http://ch.nicovideo.jp/<?= h($channel["nicoChannelId"]) ?>" class="btn btn-default">
		公式ページ
	</a>
</p>

<?php $this->include_template('include/footer.tpl') ?>
