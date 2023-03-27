<?php
header('Content-Type: application/json');

$dump = [
    'REMOTE_ADDR' => $_SERVER['REMOTE_ADDR'],
    'HTTP_X_FORWARDED_FOR' => $_SERVER['HTTP_X_FORWARDED_FOR']
];

echo json_encode($dump);