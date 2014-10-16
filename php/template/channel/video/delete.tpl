<?php $this->include_template('include/header.tpl') ?>
<?php $this->include_template('include/breadcrumb.tpl') ?>

<div class="page-header">
	<h1><?= h($this->get_title()) ?> <small>ビデオの削除</small></h1>
</div>

<?php
	$is_valid = $this->get("is_valid");
	$is_success = $this->get("is_success");

	if (isset($this->post["submit"])) {
		$this->include_template("channel/video/delete_submit.tpl");
	} else {
		if ($is_valid) {
			$this->include_template("channel/video/delete_confirm.tpl");
		} else {
			$this->include_template("channel/video/delete_default.tpl");
		}
	}
?>

<?php $this->include_template('include/footer.tpl') ?>