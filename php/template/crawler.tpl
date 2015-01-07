<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<div class="page-header">
	<h1><?= h($this->get_title()) ?> <small>クロール</small></h1>
</div>

<div class="page-header">
	<h2>channels <small>クロール待ち</small></h2>
</div>

<?php if (count($this->get("channels"))): ?>
	<?php foreach ($this->get("channels") as $channel): ?>
		<?php
			$modified = $channel["modifiedAt"];
			$modified = empty($modified) ? "記録なし" : $modified;
			$crawled = $channel["crawledAt"];
			$crawled = empty($crawled) ? "記録なし" : $crawled;
		?>
<div class="panel panel-default">
	<div class="panel-heading">
		<a href="<?= h($this->get_url("channel")) ?>?id=<?= h($channel["id"]) ?>">
			<?= h($channel["title"]) ?>
		</a>
	</div>
	<div class="panel-body">
		登録日時 <?= h($channel["createdAt"]) ?> /
		更新日時 <?= h($modified) ?> /
		クロール日時 <?= h($crawled) ?>
	</div>
</div>
	<?php endforeach ?>
<?php else: ?>
<p>クロールが完了しました。</p>
<?php endif ?>

<div class="page-header">
	<h2>maintenance <small>管理</small></h2>
</div>

<p>
	<a href="<?= h($this->get_url("crawler/register")) ?>" class="btn btn-primary">
		クロール対象を登録する
	</a>
</p>

<?php $this->include_template('include/footer.tpl') ?>
