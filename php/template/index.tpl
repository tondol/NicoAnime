<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<div class="page-header">
	<h1>NicoAnime</h1>
</div>

<p>初めての方は<a href="<?= h($this->get_url("help")) ?>">help</a>をどうぞ。</p>

<div class="page-header">
	<h2>channels <small>タイトル一覧</small></h2>
</div>

<?php if (count($this->get("channels"))): ?>
<div class="row">
	<?php foreach ($this->get("channels") as $channel): ?>
		<?php
			$thumbnail_url = $this->config["contents_dir_url"] . "/" . $channel["serviceVideoId"] . ".jpg";
			$channel_url = $this->get_url("channel") . "?id=" . $channel["id"];
		?>
	<div class="col-sm-4 col-md-3">
		<div class="thumbnail">
			<a href="<?= h($channel_url) ?>">
		<?php if (isset($channel["downloadedAt"])): ?>
				<img src="<?= h($thumbnail_url) ?>" />
		<?php else: ?>
				<div class="text-box"><span>NOW DOWNLOADING</span></div>
		<?php endif ?>
			</a>
			<div class="caption">
				<p><?= h($channel["title"]) ?></p>
		<?php if (isset($channel["downloadedAt"])): ?>
				<p><a href="<?= h($channel_url) ?>" class="btn btn-primary">
					動画一覧を見る
				</a></p>
		<?php else: ?>
				<p><a href="<?= h($channel_url) ?>" class="btn btn-info">
					未ダウンロード
				</a></p>
		<?php endif ?>
			</div><!-- /caption -->
		</div><!-- /thumbnail -->
	</div><!-- /col -->
	<?php endforeach ?>
</div><!-- /row -->
<?php else: ?>
<p>シリーズがありません。</p>
<?php endif ?>

<?php $this->include_template('include/footer.tpl') ?>
