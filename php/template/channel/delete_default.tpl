<?php
	$channel = $this->get("channel");
	$is_valid = $this->get("is_valid");
	$validation_error = $this->get("validation_error");

	if ($is_valid) {
		$group_class = "form-group";
	} else {
		$group_class = "form-group has-error";
	}
?>

<div class="page-header">
	<h2>input <small>入力</small></h2>
</div>

<form action="<?= h($this->get_url()) ?>" method="post" role="form">
	<fieldset disabled="disabled">
		<div class="form-group">
			<label>チャンネル名</label>
			<input type="text" value="<?= h($channel['nicoChannelId']) ?>" class="form-control" />
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
	<div class="<?= h($group_class) ?>">
		<label for="nicoChannelId">チャンネル名（確認）</label>
		<input name="nicoChannelId" type="text" class="form-control" />
<?php if (!$is_valid): ?>
		<p class="help-block">
			<?= nl2br_h(implode("\n", $validation_error)) ?>
		</p>
<?php endif ?>
	</div>
	<button name="confirm" type="submit" class="btn btn-primary">確認する</button>
</form>
