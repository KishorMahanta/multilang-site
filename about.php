<?php
require_once __DIR__ . '/includes/bootstrap.php';

$page = get_page('about');
$pageTitle       = $page['title'] ?? '';
$metaDescription = $page['meta_description'] ?? '';

require __DIR__ . '/includes/header.php';
?>

<section class="page-head">
  <h1><?= h($page['title'] ?? '') ?></h1>
</section>

<section class="prose">
  <?= paragraphs($page['body'] ?? '') ?>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
