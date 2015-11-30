<?php
	$channel_id = $this->get("channel_id");
	$channel_title = $this->get("channel_title");
	$channel_description = $this->get("channel_description");
	$channel_keywords = $this->get("channel_keywords");
?>

<div class="page-header">
	<h2>confirm <small>確認</small></h2>
</div>

<form action="<?= h($this->get_uri()) ?>" method="post" role="form">
	<fieldset disabled="disabled">
		<div class="form-group">
			<label>チャンネル名</label>
			<input type="text" value="<?= h($channel_id) ?>" class="form-control" />
		</div>
		<div class="form-group">
			<label>タイトル</label>
			<input type="text" value="<?= h($channel_title) ?>" class="form-control" />
		</div>
		<div class="form-group">
			<label>説明文</label>
			<textarea class="form-control"><?= h($channel_description) ?></textarea>
		</div>
		<div class="form-group">
			<label>キーワード</label>
			<textarea class="form-control"><?= h($channel_keywords) ?></textarea>
		</div>
	</fieldset>
	<input name="url" type="hidden" value="<?= h($this->post["url"]) ?>" />
	<button name="submit" type="submit" class="btn btn-primary">登録する</button>
	<button name="default" type="submit" class="btn btn-default">戻る</button>
</form>
