# fluxcp-docker

A shameless ripoff from https://github.com/cmilanf/docker-rathena-fluxcp to create a docker image for Hercules FluxCP (https://github.com/HerculesWS/FluxCP).

Item images was taken from https://rathena.org/board/files/file/2509-item-images/

## Config Override
To override the `config/servers.php`, mount your custom `server.php` file to `/var/www/fluxcp/config/servers.override.php`. Recursive array merge will be performed against the default `config/servers.php`, so you can just define config key that you want to replace.

The same mechanism can be used to override config on `config/access.php` and `config/application.php`. Other than these mentioned config files, you can just mount the whole from the host machine.

### Example
For example to change only the default server name from `FluxRO` to `ExampleRO`, create a new file `servers.override.php` with the following contents:
```php
<?php
return array(
  array(
    'ServerName' => 'FluxRO'
  )
);
?>
```
Then mount the file using something like `docker run --rm -v './servers.override.php:/var/www/fluxcp/config/servers.override.php' ...<this docker image>`
