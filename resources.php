<?php
/**
 * Page 4: Resources. Contains three content blocks, all multilingual:
 *   1. Articles (links to article.php)
 *   2. FAQ accordion
 *   3. Contact form (saved to the database with the visitor's language)
 */
require_once __DIR__ . '/includes/bootstrap.php';

// ---------------------------------------------------------------------
// Contact form handling (POST -> redirect -> GET, so refresh won't resubmit)
// ---------------------------------------------------------------------
if (empty($_SESSION['csrf'])) {
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $status = 'invalid';

    $token = (string) ($_POST['csrf'] ?? '');
    if (hash_equals($_SESSION['csrf'], $token)) {
        $name    = trim((string) ($_POST['name'] ?? ''));
        $email   = trim((string) ($_POST['email'] ?? ''));
        $message = trim((string) ($_POST['message'] ?? ''));

        $valid = mb_strlen($name) >= 1 && mb_strlen($name) <= 100
              && mb_strlen($email) <= 150 && filter_var($email, FILTER_VALIDATE_EMAIL)
              && mb_strlen($message) >= 5 && mb_strlen($message) <= 2000;

        if ($valid) {
            try {
                $stmt = db()->prepare(
                    "INSERT INTO contact_messages (name, email, message, lang_code) VALUES (?, ?, ?, ?)"
                );
                $stmt->execute([$name, $email, $message, current_lang()]);
                $status = 'success';
            } catch (Throwable $e) {
                error_log($e->getMessage());
                $status = 'error';
            }
        }
    }

    $_SESSION['flash'] = $status;
    header('Location: resources.php#contact', true, 303);
    exit;
}

$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);

// ---------------------------------------------------------------------
// Page data
// ---------------------------------------------------------------------
$page = get_page('resources');
$pageTitle       = $page['title'] ?? '';
$metaDescription = $page['meta_description'] ?? '';

$articles = get_articles();
$faqs     = get_faqs();

require __DIR__ . '/includes/header.php';
?>

<section class="page-head">
  <h1><?= h($page['title'] ?? '') ?></h1>
  <p class="lead"><?= h($page['body'] ?? '') ?></p>
  <nav class="jump" aria-label="On this page">
    <a href="#articles"><?= t('articles') ?></a>
    <a href="#faq"><?= t('faq') ?></a>
    <a href="#contact"><?= t('contact_title') ?></a>
  </nav>
</section>

<!-- 1. Articles -->
<section id="articles" class="block">
  <h2><?= t('articles') ?></h2>
  <div class="grid">
    <?php foreach ($articles as $a): ?>
      <article class="card">
        <small class="muted"><?= t('published_on') ?>: <?= h(format_date($a['published_at'])) ?></small>
        <h3><?= h($a['title']) ?></h3>
        <p><?= h($a['summary']) ?></p>
        <a class="link" href="article.php?slug=<?= urlencode($a['slug']) ?>"><?= t('read_more') ?> &rarr;</a>
      </article>
    <?php endforeach; ?>
  </div>
</section>

<!-- 2. FAQ -->
<section id="faq" class="block">
  <h2><?= t('faq') ?></h2>
  <?php foreach ($faqs as $f): ?>
    <details class="faq">
      <summary><?= h($f['question']) ?></summary>
      <p><?= h($f['answer']) ?></p>
    </details>
  <?php endforeach; ?>
</section>

<!-- 3. Contact form -->
<section id="contact" class="block">
  <h2><?= t('contact_title') ?></h2>
  <p><?= t('contact_intro') ?></p>

  <?php if ($flash === 'success'): ?>
    <div class="notice ok" role="status"><?= t('msg_success') ?></div>
  <?php elseif ($flash === 'invalid'): ?>
    <div class="notice err" role="alert"><?= t('msg_invalid') ?></div>
  <?php elseif ($flash === 'error'): ?>
    <div class="notice err" role="alert"><?= t('msg_error') ?></div>
  <?php endif; ?>

  <form method="post" action="resources.php" class="form" novalidate>
    <input type="hidden" name="csrf" value="<?= h($_SESSION['csrf']) ?>">

    <label for="name"><?= t('label_name') ?></label>
    <input type="text" id="name" name="name" maxlength="100" required>

    <label for="email"><?= t('label_email') ?></label>
    <input type="email" id="email" name="email" maxlength="150" required>

    <label for="message"><?= t('label_message') ?></label>
    <textarea id="message" name="message" rows="5" maxlength="2000" required></textarea>

    <button class="btn" type="submit"><?= t('btn_send') ?></button>
  </form>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
