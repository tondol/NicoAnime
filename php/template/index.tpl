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
			$thumbnail_url = $this->get_public("contents/" . $channel["nicoVideoId"] . ".jpg");
			$unavailable_url = $this->get_public("assets/images/unavailable.png");
			$channel_url = $this->get_url("channel") . "?id=" . $channel["id"];
		?>
	<div class="col-sm-4 col-md-3">
		<div class="thumbnail">
			<a href="<?= h($channel_url) ?>">
		<?php if (isset($channel["downloadedAt"])): ?>
				<img src="<?= h($thumbnail_url) ?>" />
		<?php else: ?>
				<img src="<?= h($unavailable_url) ?>" />
		<?php endif ?>
			</a>
			<div class="caption">
				<p><?= h($channel["title"]) ?></p>
				<p><a href="<?= h($channel_url) ?>" class="btn btn-primary">
					動画一覧を見る
				</a></p>
			</div><!-- /caption -->
		</div><!-- /thumbnail -->
	</div><!-- /col -->
	<?php endforeach ?>
</div><!-- /row -->
<?php else: ?>
<p>シリーズがありません。</p>
<?php endif ?>

<?php $this->include_template('include/footer.tpl') ?>
