<?php
declare(strict_types=1);

$root = realpath(__DIR__ . '/../../');

$directories = [
    'app',
    'lib',
];

$skipFileNames = [
    'wsdl.xml',
    'wsi.xml',
];

$errorFiles = [];
foreach ($directories as $dir) {
    $Directory = new RecursiveDirectoryIterator(realpath($root . '/' . $dir));
    $Iterator = new RecursiveIteratorIterator($Directory);
    $Regex = new RegexIterator($Iterator, '/^.+(.xml)$/i', RecursiveRegexIterator::GET_MATCH);
    foreach($Regex as $val => $Regex){
        if (in_array(basename($val), $skipFileNames)) {
            echo "skip $val \n";
            continue;
        }
        $xml = simplexml_load_file($val);
        if ($xml) {
            echo "$val ✔️\n";
        } else {
            $errorFiles[] = $val;
            echo "$val ✔️\n";
        }
    }
}

if (count($errorFiles) > 0) {
    echo "FAILURE - Errors found in:\n";
    print_r($errorFiles);
    exit(1);
}

echo "SUCCESS - No Errors found";

