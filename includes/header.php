<?php
/**
 * Expects $pageTitle and optionally $metaDescription to be set by the page.
 */
$lang        = current_lang();
$currentFile = basename($_SERVER['SCRIPT_NAME']);
$navItems    = [
    'index.php'     => 'nav_home',
    'about.php'     => 'nav_about',
    'services.php'  => 'nav_services',
    'resources.php' => 'nav_resources',
];
// article.php belongs to the Resources menu item
$activeFile = ($currentFile === 'article.php') ? 'resources.php' : $currentFile;
?>
<!DOCTYPE html>
<html lang="<?= h($lang) ?>">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= h($pageTitle ?? '') ?> | <?= h(ui_strings()['site_name'] ?? 'Site') ?></title>
  <?php if (!empty($metaDescription)): ?>
  <meta name="description" content="<?= h($metaDescription) ?>">
  <?php endif; ?>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&amp;family=Noto+Sans+Devanagari:wght@400;600;700&amp;family=Noto+Sans+Odia:wght@400;600;700&amp;display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/style.css">
</head>
<body class="lang-<?= h($lang) ?>">

<header class="site-header">
  <div class="container header-inner">
    <a class="brand" href="index.php"><?= t('site_name') ?></a>

    <nav class="main-nav" aria-label="Main">
      <?php foreach ($navItems as $file => $key): ?>
        <a href="<?= h($file) ?>"<?= $file === $activeFile ? ' class="active" aria-current="page"' : '' ?>><?= t($key) ?></a>
      <?php endforeach; ?>
    </nav>

    <div class="lang-switch" role="group" aria-label="<?= t('language') ?>">
      <?php foreach (active_languages() as $code => $info): ?>
        <a href="<?= h(lang_url($code)) ?>"
           hreflang="<?= h($code) ?>" lang="<?= h($code) ?>"
           class="<?= $code === $lang ? 'current' : '' ?>"
           <?= $code === $lang ? 'aria-current="true"' : '' ?>><?= h($info['native_name']) ?></a>
      <?php endforeach; ?>
    </div>
  </div>
</header>

<main class="container">
