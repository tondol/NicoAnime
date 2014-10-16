<?php
	$channel = $this->get("channel");
	$video = $this->get("video");
	$is_valid = $this->get("is_valid");
	$validation_error = $this->get("validation_error");

	if ($is_valid) {
		$group_class = "form-group";
	} else {
		$group_class = "form-group has-error";
	}
?>

<div class="page-header">
	<h2>confirm <small>確認</small></h2>
</div>

<form action="<?= h($this->get_url()) ?>" method="post" role="form">
	<fieldset disabled="disabled">
		<div class="form-group">
			<label>タイトル</label>
			<input type="text" value="<?= h($video['title']) ?>" class="form-control" />
		</div>
		<div class="form-group">
			<label>説明文</label>
			<textarea class="form-control"><?= h($video['description']) ?></textarea>
		</div>
	</fieldset>
	<div class="<?= h($group_class) ?>">
<?php if (!$is_valid): ?>
		<p class="help-block">
			<?= nl2br_h(implode("\n", $validation_error)) ?>
		</p>
<?php endif ?>
	</div>
	<button name="default" type="submit" class="btn btn-default">戻る</button>
</form>
