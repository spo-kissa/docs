<?php

$git  = 'https://github.com/spo-kissa/docs.git';
$html = __DIR__;
$base = dirname($html);
$user = 'daisuke';
$sudo = "sudo -u $user";

echo '<strong>rm</strong><br />';

echo `$sudo rm -rf $base/preview`;

echo '<br /><strong>git clone</strong><br />';

echo `$sudo git clone {$git} $base/preview 2>&1`;

echo '<br /><strong>docker run</strong><br />';
$host = 'unix:///run/user/1001/docker.sock';
$pref = "$sudo DOCKER_HOST={$host}";

$cmd  = "{$pref} docker run --rm -v $base/preview/spo-docs:/docs squidfunk/mkdocs-material build";
echo `$cmd  2>&1`;

echo '<br /><strong>rm</strong><br />';

echo `$sudo rm -rf $html/preview`;

echo '<br /><strong>mv</strong><br />';

echo `$sudo mv $base/preview/spo-docs/site $html/preview`;

echo '<br /><strong>All done</strong><br />';


echo '<a href="/preview/">プレビュー</a>';
