<?php
return array_merge_recursive(require(FLUX_CONFIG_DIR.'/servers.base.php'), require(FLUX_CONFIG_DIR.'/servers.override.php'));
?>