<?php
	$links = array();
	$stack = array();

	$main = $this->config["application_main"];
	if ($this->get_chain() != $main) {
		$name = $this->get_name($main);
		$uri = $this->get_uri($main);
		$links[] = "<a href=\"" . $uri . "\">" . $name . "</a>";
	}

	$exploded = explode(DIRECTORY_SEPARATOR, $this->get_chain());
	foreach ($exploded as $value) {
		array_push($stack, $value);
		$chain = implode(DIRECTORY_SEPARATOR, $stack);

		$name = $this->get_name($chain);
		$uri = $this->get_uri($chain);
		$links[] = "<a href=\"" . $uri . "\">" . $name . "</a>";
	}
?>
<ul class="breadcrumb">
	<li><?= implode("</li>&nbsp;<li>", $links) ?></li>
</ul><!-- /breadcrumb -->
