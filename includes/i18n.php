<?php
/**
 * Language handling:
 *  - list of active languages (from the database)
 *  - choosing the current language (?lang=xx -> cookie -> session -> browser -> default)
 *  - UI string lookup with English fallback
 *  - content helpers that read the translation tables
 */

// ---------------------------------------------------------------------
// Languages
// ---------------------------------------------------------------------
function active_languages(): array
{
    static $langs = null;
    if ($langs === null) {
        $rows  = db()->query(
            "SELECT code, name, native_name FROM languages WHERE is_active = 1 ORDER BY sort_order"
        )->fetchAll();
        $langs = [];
        foreach ($rows as $r) {
            $langs[$r['code']] = $r;
        }
    }
    return $langs;
}

function is_valid_lang(?string $code): bool
{
    return $code !== null && isset(active_languages()[$code]);
}

function remember_lang(string $code): void
{
    $_SESSION['lang'] = $code;
    setcookie(LANG_COOKIE, $code, [
        'expires'  => time() + 60 * 60 * 24 * LANG_COOKIE_DAYS,
        'path'     => '/',
        'secure'   => !empty($_SERVER['HTTPS']),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
}

function detect_browser_lang(): ?string
{
    $header = $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '';
    foreach (explode(',', $header) as $part) {
        $code = strtolower(substr(trim(explode(';', $part)[0]), 0, 2));
        if (is_valid_lang($code)) {
            return $code;
        }
    }
    return null;
}

/**
 * Decide the language for this request. Called once from bootstrap.php.
 */
function init_language(): string
{
    // 1. Explicit choice: ?lang=hi  -> save it, then redirect to a clean URL
    if (isset($_GET['lang'])) {
        $requested = (string) $_GET['lang'];
        if (is_valid_lang($requested)) {
            remember_lang($requested);
        }
        $query = $_GET;
        unset($query['lang']);
        $path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
        $target = $path . ($query ? '?' . http_build_query($query) : '');
        header('Location: ' . $target, true, 303);
        exit;
    }

    // 2. Cookie (survives browser restarts)
    $cookie = $_COOKIE[LANG_COOKIE] ?? null;
    if (is_valid_lang($cookie)) {
        $_SESSION['lang'] = $cookie;
        return $cookie;
    }

    // 3. Session
    $session = $_SESSION['lang'] ?? null;
    if (is_valid_lang($session)) {
        return $session;
    }

    // 4. Browser language, 5. default
    $browser = detect_browser_lang();
    if ($browser !== null) {
        return $browser;
    }
    return is_valid_lang(DEFAULT_LANG) ? DEFAULT_LANG : (string) array_key_first(active_languages());
}

function current_lang(): string
{
    return $GLOBALS['CURRENT_LANG'];
}

/** URL of the current page with ?lang=xx, used by the language selector. */
function lang_url(string $code): string
{
    $path  = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
    $query = $_GET;
    $query['lang'] = $code;
    return $path . '?' . http_build_query($query);
}

// ---------------------------------------------------------------------
// UI strings (menu, buttons, labels)
// ---------------------------------------------------------------------
function ui_strings(): array
{
    static $strings = null;
    if ($strings === null) {
        $lang = current_lang();
        $stmt = db()->prepare("SELECT t_key, t_value FROM ui_translations WHERE lang_code = ?");

        // Start with English, then overwrite with the chosen language
        $stmt->execute([DEFAULT_LANG]);
        $strings = array_column($stmt->fetchAll(), 't_value', 't_key');

        if ($lang !== DEFAULT_LANG) {
            $stmt->execute([$lang]);
            $strings = array_replace($strings, array_column($stmt->fetchAll(), 't_value', 't_key'));
        }
    }
    return $strings;
}

/** Escape for HTML output. */
function h(?string $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Translated UI string, already HTML-escaped. */
function t(string $key): string
{
    $strings = ui_strings();
    return h($strings[$key] ?? $key);
}

/** Render plain text paragraphs (blank line = new paragraph), escaped. */
function paragraphs(string $text): string
{
    $out = '';
    foreach (preg_split('/\R{2,}/u', trim($text)) as $p) {
        $out .= '<p>' . nl2br(h(trim($p))) . "</p>\n";
    }
    return $out;
}

// ---------------------------------------------------------------------
// Content (translation tables with fallback to English)
// ---------------------------------------------------------------------
function get_page(string $slug): ?array
{
    $sql = "SELECT p.slug,
                   COALESCE(t.title, f.title)                     AS title,
                   COALESCE(t.meta_description, f.meta_description) AS meta_description,
                   COALESCE(t.body, f.body)                       AS body
            FROM pages p
            LEFT JOIN page_translations t ON t.page_id = p.id AND t.lang_code = :lang
            LEFT JOIN page_translations f ON f.page_id = p.id AND f.lang_code = :fallback
            WHERE p.slug = :slug";
    $stmt = db()->prepare($sql);
    $stmt->execute([':lang' => current_lang(), ':fallback' => DEFAULT_LANG, ':slug' => $slug]);
    return $stmt->fetch() ?: null;
}

function get_services(): array
{
    $sql = "SELECT s.id, s.icon,
                   COALESCE(t.title, f.title)             AS title,
                   COALESCE(t.description, f.description) AS description
            FROM services s
            LEFT JOIN service_translations t ON t.service_id = s.id AND t.lang_code = :lang
            LEFT JOIN service_translations f ON f.service_id = s.id AND f.lang_code = :fallback
            WHERE s.is_active = 1
            ORDER BY s.sort_order";
    $stmt = db()->prepare($sql);
    $stmt->execute([':lang' => current_lang(), ':fallback' => DEFAULT_LANG]);
    return $stmt->fetchAll();
}

function get_articles(): array
{
    $sql = "SELECT a.id, a.slug, a.published_at,
                   COALESCE(t.title, f.title)     AS title,
                   COALESCE(t.summary, f.summary) AS summary
            FROM articles a
            LEFT JOIN article_translations t ON t.article_id = a.id AND t.lang_code = :lang
            LEFT JOIN article_translations f ON f.article_id = a.id AND f.lang_code = :fallback
            WHERE a.is_active = 1
            ORDER BY a.published_at DESC";
    $stmt = db()->prepare($sql);
    $stmt->execute([':lang' => current_lang(), ':fallback' => DEFAULT_LANG]);
    return $stmt->fetchAll();
}

function get_article(string $slug): ?array
{
    $sql = "SELECT a.id, a.slug, a.published_at,
                   COALESCE(t.title, f.title)     AS title,
                   COALESCE(t.summary, f.summary) AS summary,
                   COALESCE(t.body, f.body)       AS body
            FROM articles a
            LEFT JOIN article_translations t ON t.article_id = a.id AND t.lang_code = :lang
            LEFT JOIN article_translations f ON f.article_id = a.id AND f.lang_code = :fallback
            WHERE a.slug = :slug AND a.is_active = 1";
    $stmt = db()->prepare($sql);
    $stmt->execute([':lang' => current_lang(), ':fallback' => DEFAULT_LANG, ':slug' => $slug]);
    return $stmt->fetch() ?: null;
}

function get_faqs(): array
{
    $sql = "SELECT q.id,
                   COALESCE(t.question, f.question) AS question,
                   COALESCE(t.answer, f.answer)     AS answer
            FROM faqs q
            LEFT JOIN faq_translations t ON t.faq_id = q.id AND t.lang_code = :lang
            LEFT JOIN faq_translations f ON f.faq_id = q.id AND f.lang_code = :fallback
            WHERE q.is_active = 1
            ORDER BY q.sort_order";
    $stmt = db()->prepare($sql);
    $stmt->execute([':lang' => current_lang(), ':fallback' => DEFAULT_LANG]);
    return $stmt->fetchAll();
}

/** Format a DATE value in a simple, language-neutral way. */
function format_date(string $date): string
{
    $ts = strtotime($date);
    return $ts ? date('d-m-Y', $ts) : h($date);
}
