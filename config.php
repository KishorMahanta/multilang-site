<?php
/**
 * Site configuration - edit these values for your server.
 */

// Database
define('DB_HOST', 'localhost');
define('DB_NAME', 'multilang_site');
define('DB_USER', 'root');
define('DB_PASS', '');

// Language settings
define('DEFAULT_LANG', 'en');                 // used when nothing else matches
define('LANG_COOKIE', 'site_lang');           // cookie that remembers the choice
define('LANG_COOKIE_DAYS', 365);              // how long the choice is remembered
