<?php
/**
 * Included first by every page.
 * Sets UTF-8 everywhere, starts the session, and picks the language.
 */
declare(strict_types=1);

mb_internal_encoding('UTF-8');
ini_set('default_charset', 'UTF-8');
header('Content-Type: text/html; charset=UTF-8');

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/i18n.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$GLOBALS['CURRENT_LANG'] = init_language();
