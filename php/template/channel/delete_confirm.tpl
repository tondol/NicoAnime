<?php
	$channel = $this->get("channel");
?>

<div class="page-header">
	<h2>confirm <small>確認</small></h2>
</div>

<form action="<?= h($this->get_url()) ?>" method="post" role="form">
	<fieldset disabled="disabled">
		<div class="form-group">
			<label>チャンネル名</label>
			<input type="text" value="<?= h($channel['serviceChannelId']) ?>" class="form-control" />
		</div>
		<div class="form-group">
			<label>タイトル</label>
			<input type="text" value="<?= h($channel['title']) ?>" class="form-control" />
		</div>
		<div class="form-group">
			<label>説明文</label>
			<textarea class="form-control"><?= h($channel['description']) ?></textarea>
		</div>
		<div class="form-group">
			<label>キーワード</label>
			<textarea class="form-control"><?= h($channel['keywords']) ?></textarea>
		</div>
	</fieldset>
	<input name="serviceChannelId" type="hidden" value="<?= h($channel['serviceChannelId']) ?>" />
	<button name="submit" type="submit" class="btn btn-danger">タイトルを本当に削除する</button>
	<button name="default" type="submit" class="btn btn-default">戻る</button>
</form>
