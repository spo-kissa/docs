<?php

$html = __DIR__;
$src  = "$html/preview";
$dst  = "$html/docs";

echo `rm -rf $dst`;

echo `cp -r $src $dst`;

