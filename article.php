<?php
/**
 * Single article, opened from the Resources page: article.php?slug=...
 */
require_once __DIR__ . '/includes/bootstrap.php';

$slug    = (string) ($_GET['slug'] ?? '');
$article = $slug !== '' ? get_article($slug) : null;

if (!$article) {
    http_response_code(404);
    $pageTitle = ui_strings()['not_found'] ?? 'Not found';
    require __DIR__ . '/includes/header.php';
    echo '<section class="page-head"><h1>' . t('not_found') . '</h1>';
    echo '<p><a class="link" href="resources.php">&larr; ' . t('back') . '</a></p></section>';
    require __DIR__ . '/includes/footer.php';
    exit;
}

$pageTitle       = $article['title'];
$metaDescription = $article['summary'];

require __DIR__ . '/includes/header.php';
?>

<article class="prose">
  <p><a class="link" href="resources.php#articles">&larr; <?= t('back') ?></a></p>
  <h1><?= h($article['title']) ?></h1>
  <p class="muted"><?= t('published_on') ?>: <?= h(format_date($article['published_at'])) ?></p>
  <p class="lead"><?= h($article['summary']) ?></p>
  <?= paragraphs($article['body']) ?>
</article>

<?php require __DIR__ . '/includes/footer.php'; ?>
