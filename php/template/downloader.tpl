<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<div class="page-header">
	<h1><?= h($this->get_title()) ?> <small>ダウンロード</small></h1>
</div>
<div class="page-header">
	<h2>videos <small>ダウンロード待ち</small></h2>
</div>

<?php if (count($this->get("videos"))): ?>
	<?php foreach ($this->get("videos") as $i => $video): ?>
<div class="panel panel-default">
	<div class="panel-heading">
		<a href="<?= h($this->get_url("channel/video")) ?>?id=<?= h($video["id"]) ?>">
			<?= h($video["title"]) ?>
		</a>
	</div>
	<div class="panel-body">
		登録日時 <?= h($video["createdAt"]) ?> /
		リトライ <?= h($video["retryCount"]) ?>
	</div>
</div>
	<?php endforeach ?>
<?php else: ?>
<p>ダウンロードが完了しました。</p>
<?php endif ?>

<?php $this->include_template('include/footer.tpl') ?>
