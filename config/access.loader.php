<?php
return array_merge_recursive(require(FLUX_CONFIG_DIR.'/access.base.php'), require(FLUX_CONFIG_DIR.'/access.override.php'));
?>