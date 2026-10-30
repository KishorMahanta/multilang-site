<?php
require_once __DIR__ . '/includes/bootstrap.php';

$page = get_page('services');
$pageTitle       = $page['title'] ?? '';
$metaDescription = $page['meta_description'] ?? '';

$services = get_services();

require __DIR__ . '/includes/header.php';
?>

<section class="page-head">
  <h1><?= h($page['title'] ?? '') ?></h1>
  <p class="lead"><?= h($page['body'] ?? '') ?></p>
</section>

<section class="grid">
  <?php foreach ($services as $s): ?>
    <article class="card">
      <div class="icon" aria-hidden="true"><?= h($s['icon']) ?></div>
      <h3><?= h($s['title']) ?></h3>
      <p><?= h($s['description']) ?></p>
    </article>
  <?php endforeach; ?>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
