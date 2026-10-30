-- =====================================================================
--  Multilingual site: Odia (or) / English (en) / Hindi (hi)
--  Import with:  mysql -u root -p < schema.sql
--  Everything is utf8mb4 so Odia and Devanagari text is stored safely.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS multilang_site
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE multilang_site;

SET NAMES utf8mb4;

DROP TABLE IF EXISTS contact_messages;
DROP TABLE IF EXISTS faq_translations;
DROP TABLE IF EXISTS faqs;
DROP TABLE IF EXISTS article_translations;
DROP TABLE IF EXISTS articles;
DROP TABLE IF EXISTS service_translations;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS page_translations;
DROP TABLE IF EXISTS pages;
DROP TABLE IF EXISTS ui_translations;
DROP TABLE IF EXISTS languages;

-- ---------------------------------------------------------------------
-- 1. Languages (add a row here to enable a new language)
-- ---------------------------------------------------------------------
CREATE TABLE languages (
  code        VARCHAR(5)   NOT NULL,
  name        VARCHAR(50)  NOT NULL,
  native_name VARCHAR(50)  NOT NULL,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order  INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 2. UI strings (menu, buttons, labels) - one row per key per language
-- ---------------------------------------------------------------------
CREATE TABLE ui_translations (
  id        INT          NOT NULL AUTO_INCREMENT,
  lang_code VARCHAR(5)   NOT NULL,
  t_key     VARCHAR(80)  NOT NULL,
  t_value   TEXT         NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_lang_key (lang_code, t_key),
  CONSTRAINT fk_ui_lang FOREIGN KEY (lang_code) REFERENCES languages(code)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. Pages (home, about, services, resources) + translations
-- ---------------------------------------------------------------------
CREATE TABLE pages (
  id   INT         NOT NULL AUTO_INCREMENT,
  slug VARCHAR(50) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_page_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE page_translations (
  page_id          INT          NOT NULL,
  lang_code        VARCHAR(5)   NOT NULL,
  title            VARCHAR(200) NOT NULL,
  meta_description VARCHAR(300) NOT NULL DEFAULT '',
  body             TEXT         NOT NULL,
  PRIMARY KEY (page_id, lang_code),
  CONSTRAINT fk_pt_page FOREIGN KEY (page_id)   REFERENCES pages(id)         ON DELETE CASCADE,
  CONSTRAINT fk_pt_lang FOREIGN KEY (lang_code) REFERENCES languages(code)   ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 4. Services + translations
-- ---------------------------------------------------------------------
CREATE TABLE services (
  id         INT         NOT NULL AUTO_INCREMENT,
  icon       VARCHAR(10) NOT NULL DEFAULT '',
  sort_order INT         NOT NULL DEFAULT 0,
  is_active  TINYINT(1)  NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE service_translations (
  service_id  INT          NOT NULL,
  lang_code   VARCHAR(5)   NOT NULL,
  title       VARCHAR(200) NOT NULL,
  description TEXT         NOT NULL,
  PRIMARY KEY (service_id, lang_code),
  CONSTRAINT fk_st_service FOREIGN KEY (service_id) REFERENCES services(id)    ON DELETE CASCADE,
  CONSTRAINT fk_st_lang    FOREIGN KEY (lang_code)  REFERENCES languages(code) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 5. Articles (shown on page 4 "Resources" and on article.php)
-- ---------------------------------------------------------------------
CREATE TABLE articles (
  id           INT         NOT NULL AUTO_INCREMENT,
  slug         VARCHAR(80) NOT NULL,
  published_at DATE        NOT NULL,
  is_active    TINYINT(1)  NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_article_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE article_translations (
  article_id INT          NOT NULL,
  lang_code  VARCHAR(5)   NOT NULL,
  title      VARCHAR(200) NOT NULL,
  summary    VARCHAR(400) NOT NULL,
  body       TEXT         NOT NULL,
  PRIMARY KEY (article_id, lang_code),
  CONSTRAINT fk_at_article FOREIGN KEY (article_id) REFERENCES articles(id)    ON DELETE CASCADE,
  CONSTRAINT fk_at_lang    FOREIGN KEY (lang_code)  REFERENCES languages(code) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 6. FAQs (also on page 4)
-- ---------------------------------------------------------------------
CREATE TABLE faqs (
  id         INT        NOT NULL AUTO_INCREMENT,
  sort_order INT        NOT NULL DEFAULT 0,
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE faq_translations (
  faq_id    INT          NOT NULL,
  lang_code VARCHAR(5)   NOT NULL,
  question  VARCHAR(300) NOT NULL,
  answer    TEXT         NOT NULL,
  PRIMARY KEY (faq_id, lang_code),
  CONSTRAINT fk_ft_faq  FOREIGN KEY (faq_id)    REFERENCES faqs(id)       ON DELETE CASCADE,
  CONSTRAINT fk_ft_lang FOREIGN KEY (lang_code) REFERENCES languages(code) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 7. Contact form submissions (visitor input, stored with the language used)
-- ---------------------------------------------------------------------
CREATE TABLE contact_messages (
  id         INT          NOT NULL AUTO_INCREMENT,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(150) NOT NULL,
  message    TEXT         NOT NULL,
  lang_code  VARCHAR(5)   NOT NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================================
--  SEED DATA
-- =====================================================================

INSERT INTO languages (code, name, native_name, is_active, sort_order) VALUES
('en', 'English', 'English', 1, 1),
('hi', 'Hindi',   'हिन्दी',   1, 2),
('or', 'Odia',    'ଓଡ଼ିଆ',    1, 3);

-- ---------------------------------------------------------------------
-- UI strings
-- ---------------------------------------------------------------------
INSERT INTO ui_translations (lang_code, t_key, t_value) VALUES
-- English
('en','site_name','Odisha Tech Hub'),
('en','nav_home','Home'),
('en','nav_about','About'),
('en','nav_services','Services'),
('en','nav_resources','Resources'),
('en','language','Language'),
('en','read_more','Read more'),
('en','back','Back to resources'),
('en','articles','Articles'),
('en','faq','Frequently asked questions'),
('en','contact_title','Contact us'),
('en','contact_intro','Send us a message and we will reply soon.'),
('en','label_name','Name'),
('en','label_email','Email'),
('en','label_message','Message'),
('en','btn_send','Send message'),
('en','msg_success','Thank you! Your message has been received.'),
('en','msg_error','Something went wrong. Please try again.'),
('en','msg_invalid','Please fill in all fields correctly.'),
('en','footer_rights','All rights reserved'),
('en','published_on','Published'),
('en','cta_home','View our services'),
('en','not_found','Page not found'),
-- Hindi
('hi','site_name','ओडिशा टेक हब'),
('hi','nav_home','मुखपृष्ठ'),
('hi','nav_about','हमारे बारे में'),
('hi','nav_services','सेवाएँ'),
('hi','nav_resources','संसाधन'),
('hi','language','भाषा'),
('hi','read_more','और पढ़ें'),
('hi','back','संसाधनों पर वापस जाएँ'),
('hi','articles','लेख'),
('hi','faq','अक्सर पूछे जाने वाले प्रश्न'),
('hi','contact_title','हमसे संपर्क करें'),
('hi','contact_intro','हमें संदेश भेजें, हम जल्द उत्तर देंगे।'),
('hi','label_name','नाम'),
('hi','label_email','ईमेल'),
('hi','label_message','संदेश'),
('hi','btn_send','संदेश भेजें'),
('hi','msg_success','धन्यवाद! आपका संदेश मिल गया है।'),
('hi','msg_error','कुछ गलत हुआ। कृपया फिर से प्रयास करें।'),
('hi','msg_invalid','कृपया सभी फ़ील्ड सही से भरें।'),
('hi','footer_rights','सर्वाधिकार सुरक्षित'),
('hi','published_on','प्रकाशित'),
('hi','cta_home','हमारी सेवाएँ देखें'),
('hi','not_found','पृष्ठ नहीं मिला'),
-- Odia
('or','site_name','ଓଡ଼ିଶା ଟେକ୍ ହବ୍'),
('or','nav_home','ମୂଳପୃଷ୍ଠା'),
('or','nav_about','ଆମ ବିଷୟରେ'),
('or','nav_services','ସେବାସମୂହ'),
('or','nav_resources','ଅଧିକ ସୂଚନା'),
('or','language','ଭାଷା'),
('or','read_more','ଅଧିକ ପଢ଼ନ୍ତୁ'),
('or','back','ସୂଚନା ପୃଷ୍ଠାକୁ ଫେରନ୍ତୁ'),
('or','articles','ଲେଖାସମୂହ'),
('or','faq','ବାରମ୍ବାର ପଚରାଯାଉଥିବା ପ୍ରଶ୍ନ'),
('or','contact_title','ଆମ ସହ ଯୋଗାଯୋଗ କରନ୍ତୁ'),
('or','contact_intro','ଆମକୁ ବାର୍ତ୍ତା ପଠାନ୍ତୁ, ଆମେ ଶୀଘ୍ର ଉତ୍ତର ଦେବୁ।'),
('or','label_name','ନାମ'),
('or','label_email','ଇମେଲ୍'),
('or','label_message','ବାର୍ତ୍ତା'),
('or','btn_send','ବାର୍ତ୍ତା ପଠାନ୍ତୁ'),
('or','msg_success','ଧନ୍ୟବାଦ! ଆପଣଙ୍କ ବାର୍ତ୍ତା ମିଳିଛି।'),
('or','msg_error','କିଛି ତ୍ରୁଟି ଘଟିଛି। ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ।'),
('or','msg_invalid','ଦୟାକରି ସମସ୍ତ ଘର ସଠିକ୍ ଭାବରେ ପୂରଣ କରନ୍ତୁ।'),
('or','footer_rights','ସର୍ବସ୍ୱତ୍ୱ ସଂରକ୍ଷିତ'),
('or','published_on','ପ୍ରକାଶିତ'),
('or','cta_home','ଆମ ସେବା ଦେଖନ୍ତୁ'),
('or','not_found','ପୃଷ୍ଠା ମିଳିଲା ନାହିଁ');

-- ---------------------------------------------------------------------
-- Pages
-- ---------------------------------------------------------------------
INSERT INTO pages (id, slug) VALUES
(1, 'home'),
(2, 'about'),
(3, 'services'),
(4, 'resources');

INSERT INTO page_translations (page_id, lang_code, title, meta_description, body) VALUES
-- Home
(1,'en','Welcome to Odisha Tech Hub','Simple, reliable websites and software for businesses in Odisha and across India.','We build simple, reliable websites and software for businesses across Odisha and India. Choose your language and explore our work.'),
(1,'hi','ओडिशा टेक हब में आपका स्वागत है','ओडिशा और पूरे भारत के व्यवसायों के लिए सरल और भरोसेमंद वेबसाइट और सॉफ़्टवेयर।','हम ओडिशा और पूरे भारत के व्यवसायों के लिए सरल और भरोसेमंद वेबसाइट व सॉफ़्टवेयर बनाते हैं। अपनी भाषा चुनें और हमारा काम देखें।'),
(1,'or','ଓଡ଼ିଶା ଟେକ୍ ହବ୍‌କୁ ସ୍ୱାଗତ','ଓଡ଼ିଶା ଏବଂ ସମଗ୍ର ଭାରତର ବ୍ୟବସାୟ ପାଇଁ ସରଳ ଓ ଭରସାଯୋଗ୍ୟ ୱେବସାଇଟ୍ ଏବଂ ସଫ୍ଟୱେୟାର।','ଆମେ ଓଡ଼ିଶା ଏବଂ ସମଗ୍ର ଭାରତର ବ୍ୟବସାୟ ପାଇଁ ସରଳ ଓ ଭରସାଯୋଗ୍ୟ ୱେବସାଇଟ୍ ଏବଂ ସଫ୍ଟୱେୟାର ତିଆରି କରୁ। ନିଜ ଭାଷା ବାଛନ୍ତୁ ଏବଂ ଆମ କାମ ଦେଖନ୍ତୁ।'),
-- About
(2,'en','About us','Who we are and why language matters to us.','Odisha Tech Hub started in Bhubaneswar with a small team that wanted local businesses to have a strong online presence in their own language. Today we design, build and maintain websites, and we believe every customer should be able to read them in the language they are most comfortable with.'),
(2,'hi','हमारे बारे में','हम कौन हैं और भाषा हमारे लिए क्यों मायने रखती है।','ओडिशा टेक हब की शुरुआत भुवनेश्वर में एक छोटी टीम के साथ हुई, जो चाहती थी कि स्थानीय व्यवसायों की ऑनलाइन मौजूदगी उनकी अपनी भाषा में मज़बूत हो। आज हम वेबसाइट डिज़ाइन, निर्माण और रखरखाव करते हैं, और मानते हैं कि हर ग्राहक अपनी सबसे सहज भाषा में इन्हें पढ़ सके।'),
(2,'or','ଆମ ବିଷୟରେ','ଆମେ କିଏ ଏବଂ ଭାଷା ଆମ ପାଇଁ କାହିଁକି ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ।','ଓଡ଼ିଶା ଟେକ୍ ହବ୍ ଭୁବନେଶ୍ୱରରେ ଏକ ଛୋଟ ଦଳ ସହ ଆରମ୍ଭ ହୋଇଥିଲା, ଯେଉଁମାନେ ଚାହୁଁଥିଲେ ଯେ ସ୍ଥାନୀୟ ବ୍ୟବସାୟର ଅନଲାଇନ୍ ଉପସ୍ଥିତି ସେମାନଙ୍କ ନିଜ ଭାଷାରେ ଦୃଢ଼ ହେଉ। ଆଜି ଆମେ ୱେବସାଇଟ୍ ଡିଜାଇନ୍, ନିର୍ମାଣ ଓ ରକ୍ଷଣାବେକ୍ଷଣ କରୁ, ଏବଂ ବିଶ୍ୱାସ କରୁ ଯେ ପ୍ରତ୍ୟେକ ଗ୍ରାହକ ନିଜର ସବୁଠାରୁ ସହଜ ଭାଷାରେ ଏହା ପଢ଼ିପାରିବା ଉଚିତ।'),
-- Services
(3,'en','Our services','What we can build and look after for you.','From a first design to long-term support, we cover the whole life of your website.'),
(3,'hi','हमारी सेवाएँ','हम आपके लिए क्या बना और संभाल सकते हैं।','पहले डिज़ाइन से लेकर लंबे समय की सहायता तक, हम आपकी वेबसाइट के पूरे जीवनकाल का ध्यान रखते हैं।'),
(3,'or','ଆମ ସେବାସମୂହ','ଆମେ ଆପଣଙ୍କ ପାଇଁ କଣ ତିଆରି ଓ ଦେଖାଶୁଣା କରିପାରିବୁ।','ପ୍ରଥମ ଡିଜାଇନ୍‌ଠାରୁ ଦୀର୍ଘକାଳୀନ ସହାୟତା ପର୍ଯ୍ୟନ୍ତ, ଆମେ ଆପଣଙ୍କ ୱେବସାଇଟ୍‌ର ସମ୍ପୂର୍ଣ୍ଣ ଜୀବନକାଳର ଯତ୍ନ ନେଉ।'),
-- Resources (page 4)
(4,'en','Resources','Articles, answers to common questions and a contact form.','Read our articles, find quick answers to common questions, or send us a message. Everything on this page follows the language you selected.'),
(4,'hi','संसाधन','लेख, आम सवालों के जवाब और संपर्क फ़ॉर्म।','हमारे लेख पढ़ें, आम सवालों के त्वरित जवाब पाएँ, या हमें संदेश भेजें। इस पेज की सारी सामग्री आपकी चुनी हुई भाषा में दिखती है।'),
(4,'or','ଅଧିକ ସୂଚନା','ଲେଖା, ସାଧାରଣ ପ୍ରଶ୍ନର ଉତ୍ତର ଏବଂ ଯୋଗାଯୋଗ ଫର୍ମ।','ଆମ ଲେଖା ପଢ଼ନ୍ତୁ, ସାଧାରଣ ପ୍ରଶ୍ନର ଶୀଘ୍ର ଉତ୍ତର ପାଆନ୍ତୁ, କିମ୍ବା ଆମକୁ ବାର୍ତ୍ତା ପଠାନ୍ତୁ। ଏହି ପୃଷ୍ଠାର ସମସ୍ତ ବିଷୟବସ୍ତୁ ଆପଣ ବାଛିଥିବା ଭାଷାରେ ଦେଖାଯାଏ।');

-- ---------------------------------------------------------------------
-- Services
-- ---------------------------------------------------------------------
INSERT INTO services (id, icon, sort_order, is_active) VALUES
(1, '🎨', 1, 1),
(2, '💻', 2, 1),
(3, '🛠️', 3, 1);

INSERT INTO service_translations (service_id, lang_code, title, description) VALUES
(1,'en','Website design','Clean, mobile-friendly designs that load fast and look good in every language.'),
(1,'hi','वेबसाइट डिज़ाइन','साफ़-सुथरे, मोबाइल-अनुकूल डिज़ाइन जो तेज़ी से खुलते हैं और हर भाषा में अच्छे दिखते हैं।'),
(1,'or','ୱେବସାଇଟ୍ ଡିଜାଇନ୍','ସ୍ୱଚ୍ଛ, ମୋବାଇଲ୍‌ ଉପଯୋଗୀ ଡିଜାଇନ୍ ଯାହା ଶୀଘ୍ର ଖୋଲେ ଏବଂ ପ୍ରତ୍ୟେକ ଭାଷାରେ ସୁନ୍ଦର ଦେଖାଯାଏ।'),
(2,'en','Web development','PHP and MySQL applications built to be secure, fast and easy to maintain.'),
(2,'hi','वेब डेवलपमेंट','PHP और MySQL आधारित एप्लिकेशन जो सुरक्षित, तेज़ और आसानी से संभालने योग्य हैं।'),
(2,'or','ୱେବ୍ ଡେଭଲପମେଣ୍ଟ','PHP ଏବଂ MySQL ଆଧାରିତ ଆପ୍ଲିକେସନ୍ ଯାହା ସୁରକ୍ଷିତ, ଦ୍ରୁତ ଓ ସହଜରେ ରକ୍ଷଣାବେକ୍ଷଣ ଯୋଗ୍ୟ।'),
(3,'en','Maintenance and support','Regular updates, backups and quick help whenever something needs fixing.'),
(3,'hi','रखरखाव और सहायता','नियमित अपडेट, बैकअप और ज़रूरत पड़ने पर तुरंत मदद।'),
(3,'or','ରକ୍ଷଣାବେକ୍ଷଣ ଓ ସହାୟତା','ନିୟମିତ ଅପଡେଟ୍, ବ୍ୟାକଅପ୍ ଏବଂ ଆବଶ୍ୟକ ସମୟରେ ଶୀଘ୍ର ସହାୟତା।');

-- ---------------------------------------------------------------------
-- Articles
-- ---------------------------------------------------------------------
INSERT INTO articles (id, slug, published_at, is_active) VALUES
(1, 'why-your-own-language-matters', '2026-09-05', 1),
(2, 'why-manual-translation', '2026-09-20', 1),
(3, 'keeping-your-website-safe', '2026-10-10', 1);

INSERT INTO article_translations (article_id, lang_code, title, summary, body) VALUES
(1,'en','Why a website in your own language matters','Customers trust and buy more when they can read in their own language.',
'Visitors stay longer and trust a business more when the website speaks their language. In Odisha, many customers prefer reading in Odia, while others use Hindi or English.

Offering all three on the same page layout lets every visitor feel at home, and it can improve enquiries and sales.'),
(1,'hi','अपनी भाषा में वेबसाइट क्यों ज़रूरी है','अपनी भाषा में पढ़ने पर ग्राहक ज़्यादा भरोसा करते हैं और ज़्यादा खरीदते हैं।',
'जब वेबसाइट आगंतुक की अपनी भाषा में होती है तो वे ज़्यादा देर रुकते हैं और व्यवसाय पर अधिक भरोसा करते हैं। ओडिशा में कई ग्राहक ओड़िया पढ़ना पसंद करते हैं, जबकि अन्य हिंदी या अंग्रेज़ी का उपयोग करते हैं।

एक ही पेज लेआउट में तीनों भाषाएँ देने से हर आगंतुक को अपनापन महसूस होता है, और इससे पूछताछ व बिक्री बढ़ सकती है।'),
(1,'or','ନିଜ ଭାଷାରେ ୱେବସାଇଟ୍ କାହିଁକି ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ','ନିଜ ଭାଷାରେ ପଢ଼ିପାରିଲେ ଗ୍ରାହକ ଅଧିକ ବିଶ୍ୱାସ କରନ୍ତି ଏବଂ ଅଧିକ କିଣନ୍ତି।',
'ୱେବସାଇଟ୍ ଯେତେବେଳେ ଆଗନ୍ତୁକଙ୍କ ନିଜ ଭାଷାରେ ଥାଏ, ସେମାନେ ଅଧିକ ସମୟ ରହନ୍ତି ଏବଂ ବ୍ୟବସାୟ ଉପରେ ଅଧିକ ବିଶ୍ୱାସ କରନ୍ତି। ଓଡ଼ିଶାରେ ଅନେକ ଗ୍ରାହକ ଓଡ଼ିଆ ପଢ଼ିବାକୁ ପସନ୍ଦ କରନ୍ତି, ଯେତେବେଳେ ଅନ୍ୟମାନେ ହିନ୍ଦୀ କିମ୍ବା ଇଂରାଜୀ ବ୍ୟବହାର କରନ୍ତି।

ଗୋଟିଏ ପୃଷ୍ଠା ଲେଆଉଟ୍‌ରେ ତିନୋଟି ଭାଷା ଦେଲେ ପ୍ରତ୍ୟେକ ଆଗନ୍ତୁକ ଆପଣାପଣ ଅନୁଭବ କରନ୍ତି, ଏବଂ ଏହା ପଚରାଉଚରା ଓ ବିକ୍ରୟ ବଢ଼ାଇପାରେ।'),

(2,'en','How manual translation keeps quality high','Human-written translations read naturally and avoid the errors machines make.',
'Manual translation means a person writes each version of your text. It reads naturally, respects local expressions and avoids the awkward phrasing that automatic tools sometimes produce.

In this site every translation is stored in the database, so you can review and edit it at any time without touching the code.'),
(2,'hi','मैन्युअल अनुवाद गुणवत्ता कैसे बनाए रखता है','इंसान द्वारा लिखे अनुवाद स्वाभाविक पढ़ते हैं और मशीन की गलतियों से बचते हैं।',
'मैन्युअल अनुवाद का मतलब है कि कोई व्यक्ति आपके पाठ का हर संस्करण स्वयं लिखता है। यह स्वाभाविक लगता है, स्थानीय अभिव्यक्तियों का सम्मान करता है और स्वचालित टूल की अटपटी भाषा से बचाता है।

इस साइट में हर अनुवाद डेटाबेस में सहेजा जाता है, इसलिए आप कोड को छुए बिना कभी भी उसे देख और संपादित कर सकते हैं।'),
(2,'or','ମାନୁଆଲ୍ ଅନୁବାଦ ଗୁଣବତ୍ତା କିପରି ବଜାୟ ରଖେ','ମଣିଷ ଲିଖିତ ଅନୁବାଦ ସ୍ୱାଭାବିକ ପଢ଼ାଯାଏ ଏବଂ ମେସିନ୍‌ର ଭୁଲରୁ ରକ୍ଷା କରେ।',
'ମାନୁଆଲ୍ ଅନୁବାଦ ଅର୍ଥ ହେଉଛି ଜଣେ ବ୍ୟକ୍ତି ଆପଣଙ୍କ ଲେଖାର ପ୍ରତ୍ୟେକ ସଂସ୍କରଣ ନିଜେ ଲେଖନ୍ତି। ଏହା ସ୍ୱାଭାବିକ ଲାଗେ, ସ୍ଥାନୀୟ ଅଭିବ୍ୟକ୍ତିକୁ ସମ୍ମାନ ଦିଏ ଏବଂ ସ୍ୱୟଂଚାଳିତ ଟୁଲ୍‌ର ଅଜବ ଭାଷାରୁ ରକ୍ଷା କରେ।

ଏହି ସାଇଟ୍‌ରେ ପ୍ରତ୍ୟେକ ଅନୁବାଦ ଡାଟାବେସ୍‌ରେ ସଞ୍ଚିତ ହୁଏ, ତେଣୁ ଆପଣ କୋଡ୍ ଛୁଇଁନଥାଇ ଯେକୌଣସି ସମୟରେ ଏହା ଦେଖିପାରିବେ ଓ ସମ୍ପାଦନ କରିପାରିବେ।'),

(3,'en','Keeping your website safe','A few simple habits protect your site and your visitors.',
'Keep PHP and your database updated, use prepared statements for every query and escape all output. Back up the database regularly and store the copy away from the server.

Use strong passwords, serve the site over HTTPS and limit who can edit the content.'),
(3,'hi','अपनी वेबसाइट को सुरक्षित रखना','कुछ सरल आदतें आपकी साइट और आगंतुकों को सुरक्षित रखती हैं।',
'PHP और डेटाबेस को अपडेट रखें, हर क्वेरी में प्रिपेयर्ड स्टेटमेंट का उपयोग करें और सभी आउटपुट को एस्केप करें। डेटाबेस का नियमित बैकअप लें और उसे सर्वर से अलग स्थान पर रखें।

मज़बूत पासवर्ड रखें, साइट को HTTPS पर चलाएँ और सामग्री संपादित करने वालों को सीमित रखें।'),
(3,'or','ଆପଣଙ୍କ ୱେବସାଇଟ୍ ସୁରକ୍ଷିତ ରଖିବା','କିଛି ସରଳ ଅଭ୍ୟାସ ଆପଣଙ୍କ ସାଇଟ୍ ଏବଂ ଆଗନ୍ତୁକଙ୍କୁ ସୁରକ୍ଷିତ ରଖେ।',
'PHP ଏବଂ ଡାଟାବେସ୍ ଅପଡେଟ୍ ରଖନ୍ତୁ, ପ୍ରତ୍ୟେକ କ୍ୱେରୀରେ ପ୍ରିପେୟାର୍ଡ ଷ୍ଟେଟମେଣ୍ଟ ବ୍ୟବହାର କରନ୍ତୁ ଏବଂ ସମସ୍ତ ଆଉଟପୁଟ୍ ଏସ୍କେପ୍ କରନ୍ତୁ। ଡାଟାବେସ୍‌ର ନିୟମିତ ବ୍ୟାକଅପ୍ ନିଅନ୍ତୁ ଏବଂ ତାକୁ ସର୍ଭରଠାରୁ ଅଲଗା ସ୍ଥାନରେ ରଖନ୍ତୁ।

ଶକ୍ତିଶାଳୀ ପାସୱାର୍ଡ ବ୍ୟବହାର କରନ୍ତୁ, ସାଇଟ୍ HTTPS ରେ ଚଲାନ୍ତୁ ଏବଂ ବିଷୟବସ୍ତୁ ସମ୍ପାଦନ କରିପାରୁଥିବା ଲୋକଙ୍କୁ ସୀମିତ ରଖନ୍ତୁ।');

-- ---------------------------------------------------------------------
-- FAQs
-- ---------------------------------------------------------------------
INSERT INTO faqs (id, sort_order, is_active) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1);

INSERT INTO faq_translations (faq_id, lang_code, question, answer) VALUES
(1,'en','Can I add more languages later?','Yes. Add a row in the languages table, then add translations for each page, service, article and FAQ.'),
(1,'hi','क्या मैं बाद में और भाषाएँ जोड़ सकता हूँ?','हाँ। languages टेबल में एक पंक्ति जोड़ें, फिर हर पेज, सेवा, लेख और FAQ के अनुवाद जोड़ें।'),
(1,'or','ମୁଁ ପରେ ଅଧିକ ଭାଷା ଯୋଡ଼ିପାରିବି କି?','ହଁ। languages ଟେବୁଲରେ ଏକ ଧାଡ଼ି ଯୋଡ଼ନ୍ତୁ, ତାପରେ ପ୍ରତ୍ୟେକ ପୃଷ୍ଠା, ସେବା, ଲେଖା ଓ FAQ ପାଇଁ ଅନୁବାଦ ଯୋଡ଼ନ୍ତୁ।'),
(2,'en','Is my language choice remembered?','Yes. It is saved in a cookie for one year, so you see the same language next time.'),
(2,'hi','क्या मेरी भाषा की पसंद याद रखी जाती है?','हाँ। यह एक साल के लिए कुकी में सहेजी जाती है, इसलिए अगली बार आपको वही भाषा दिखेगी।'),
(2,'or','ମୋର ଭାଷା ପସନ୍ଦ ମନେ ରଖାଯାଏ କି?','ହଁ। ଏହା ଏକ ବର୍ଷ ପାଇଁ କୁକିରେ ସଞ୍ଚିତ ହୁଏ, ତେଣୁ ପରବର୍ତ୍ତୀ ଥର ଆପଣ ସେହି ଭାଷା ଦେଖିବେ।'),
(3,'en','What if a translation is missing?','The site falls back to English so the page never shows empty text.'),
(3,'hi','अगर कोई अनुवाद उपलब्ध न हो तो?','साइट अंग्रेज़ी पर वापस आ जाती है, ताकि पेज पर कभी खाली टेक्स्ट न दिखे।'),
(3,'or','ଯଦି କୌଣସି ଅନୁବାଦ ନଥାଏ ତେବେ?','ସାଇଟ୍ ଇଂରାଜୀକୁ ଫେରିଯାଏ, ଯାହାଫଳରେ ପୃଷ୍ଠାରେ କେବେ ଖାଲି ଲେଖା ଦେଖାଯାଏ ନାହିଁ।');
