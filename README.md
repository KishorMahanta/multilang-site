# Multilingual PHP + MySQL website (Odia / English / Hindi)

Manual translations stored in MySQL. Four pages plus an article detail page.

## Pages

| File            | Page                                                         |
|-----------------|--------------------------------------------------------------|
| `index.php`     | 1. Home                                                      |
| `about.php`     | 2. About                                                     |
| `services.php`  | 3. Services                                                  |
| `resources.php` | 4. Resources: articles, FAQ accordion, contact form          |
| `article.php`   | Article detail, opened from the Resources page               |

## Setup (XAMPP / WAMP / any PHP 8+ host)

1. Copy the `multilang-site` folder into your web root (`htdocs` or `www`).
2. Import the database:
   `mysql -u root -p < schema.sql`
   (or open phpMyAdmin, choose Import, select `schema.sql`).
3. Edit `config.php` with your MySQL user and password.
4. Open `http://localhost/multilang-site/` in the browser.

Requirements: PHP 8.0+ with `pdo_mysql` and `mbstring`, MySQL 5.7+ or MariaDB 10.3+.

## How the language system works

1. Visitor clicks a language in the header, which links to `?lang=or`, `?lang=hi` or `?lang=en`.
2. `includes/i18n.php` validates the code against the `languages` table, saves it in a
   cookie (1 year) and the session, then redirects to the same page without `?lang=`.
3. On later visits the order is: cookie, session, browser `Accept-Language`, `DEFAULT_LANG`.
4. Every page reads text through helpers that fall back to English when a translation is missing.

## UTF-8 checklist (already done)

- Database and tables: `utf8mb4` / `utf8mb4_unicode_ci`
- PDO connection: `charset=utf8mb4` plus `SET NAMES utf8mb4`
- HTTP header: `Content-Type: text/html; charset=UTF-8`
- HTML: `<meta charset="UTF-8">` and `<html lang="...">`
- Fonts: Noto Sans Odia and Noto Sans Devanagari via Google Fonts
- Save any file you edit yourself as UTF-8 (no BOM)

## Database translation strategy

- **UI strings** (menu, buttons, labels): table `ui_translations`, one row per key per language.
  In templates use `t('key')`.
- **Content** (pages, services, articles, FAQs): a main table with language-independent data
  (slug, icon, date, order) and a `*_translations` table with one row per language.
- **Fallback**: queries `LEFT JOIN` the chosen language and English, then `COALESCE` them.

### Add a new language (example: Bengali)

```sql
INSERT INTO languages (code, name, native_name, sort_order) VALUES ('bn', 'Bengali', 'বাংলা', 4);
```

Then insert rows into `ui_translations` and each `*_translations` table with `lang_code = 'bn'`.
Anything you have not translated yet shows in English.

### Add a new article

```sql
INSERT INTO articles (id, slug, published_at) VALUES (4, 'my-new-article', '2026-10-29');
INSERT INTO article_translations (article_id, lang_code, title, summary, body) VALUES
(4, 'en', 'Title', 'Short summary', 'Paragraph one.\n\nParagraph two.'),
(4, 'hi', '...', '...', '...'),
(4, 'or', '...', '...', '...');
```

A blank line in `body` starts a new paragraph.

## Security notes

- All queries use prepared statements; all output goes through `h()` / `t()` (HTML-escaped).
- The contact form uses a CSRF token and a redirect after POST.
- For production, set `display_errors=Off` and use a dedicated MySQL user instead of `root`.
