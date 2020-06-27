%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: html.pl
% Description: DCG definition of an HTML file.
%	This is basically your static website's template.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

page(Entry, Title, Subtitle, Date) -->
	doctype,
	newline,
	html(Entry, Title, Subtitle, Date),
	newline.

html(Entry, Title, Subtitle, Date) -->
	html_open,
	newline,
	head(Title),
	newline,
	body(Entry, Title, Subtitle, Date),
	newline,
	html_close.

head(Title) -->
	head_open,
	newline, tab,
	title(Title),
	newline, tab,
	meta,
	newline, tab,
	styles,
	newline, tab,
	rss,
	newline,
	head_close.

body(Entry, Title, Subtitle, Date) -->
	body_open,
	newline, tab,
	header(Title),
	newline, tab,
	article(Entry, Title, Subtitle, Date),
	newline, tab,
	footer,
	newline,
	body_close.

header(Title) -->
	header_open,
	newline, tab, tab,
	header_title(Title),
	newline, tab, tab,
	header_subtitle,
	newline, tab,
	header_close.

article(Entry, Title, Subtitle, Date) -->
	article_open,
	newline, tab, tab,
	article_header(Title, Subtitle, Date),
	newline, tab, tab,
	div_entry_open,
	newline,
	anything(Entry),
	newline, tab, tab,
	div_entry_close,
	newline, tab,
	article_close,
	{ [First|_] = Entry,  char_code('<', First) }.

% An article without a title, subtitle, or metadata.
article_header(null, null, null) --> [].

% An article without a subtitle or metadata.
article_header(Title, null, null) -->
	article_title(Title).

% An article without a subtitle.
article_header(Title, null, Date) -->
	article_title(Title),
	newline, tab, tab,
	article_meta(Date).

% An article without metadata.
article_header(Title, Subtitle, null) -->
	article_title(Title),
	newline, tab, tab,
	article_subtitle(Subtitle).

% An article with all header components.
article_header(Title, Subtitle, Date) -->
	article_title(Title),
	newline, tab, tab,
	article_subtitle(Subtitle),
	newline, tab, tab,
	article_meta(Date).

footer -->
	footer_open,
	newline, tab, tab,
	p_center_open,
	newline, tab, tab, tab,
	license_link,
	newline, tab, tab, tab,
	br,
	newline, tab, tab, tab,
	license_text,
	newline, tab, tab,
	p_close,
	newline, tab,
	footer_close.

doctype --> "<!DOCTYPE html>".

html_open --> "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">".

head_open --> "<head>".

meta --> "<meta charset=\"utf-8\" />".

title(null) -->
	"<title>",
	site_title,
	" | ",
	site_subtitle,
	"</title>".

title(Title) -->
	"<title>",
	anything(Title),
	"</title>".

styles -->
	"<link rel=\"stylesheet\" href=\"",
	site_url,
	"/theme/css/styles.css\" />".

rss -->
	"<link rel=\"alternate\" type=\"application/rss+xml\" href=\"",
	site_url,
	"/feeds/rss.xml\" title=\"",
	site_title,
	" Latest Posts\" />".

head_close --> "</head>".

body_open --> "<body>".

header_open --> "<header>".

header_title(Title) -->
	"<",
	header_node(Title),
	" id=\"blog-title\"><a href=\"",
	site_url,
	"\" title=\"",
	site_title,
	"\" rel=\"home\">",
	site_title,
	"</a></",
	header_node(Title),
	">".

header_node(null) --> "h1".

header_node(_) --> "p".

header_subtitle -->
	"<p id=\"blog-description\">",
	site_subtitle,
	"</p>".

header_close --> "</header>".

article_open --> "<article>".

article_title(ArticleTitle) -->
	"<h1 class=\"entry-title\">",
	anything(ArticleTitle),
	"</h1>".

article_subtitle(ArticleSubtitle) -->
	"<p class=\"entry-subtitle\">",
	anything(ArticleSubtitle),
	"</p>".

article_meta(ArticleDate) -->
	"<div class=\"entry-meta\">",
	newline, tab, tab, tab,
	"<time datetime=\"",
	anything(ArticleDate),
	"\">",
	anything(ArticleDate),
	"</time>",
	newline, tab, tab,
	"</div><!-- .entry-meta -->".

div_entry_open --> "<div class=\"entry-content\">".

div_entry_close --> "</div><!-- .entry-content -->".

article_close --> "</article>".

footer_open --> "<footer>".

p_center_open --> "<p class=\"center\">".

license_link -->
	"<a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/\"><img alt=\"Creative Commons License\" style=\"border-width:0\" src=\"",
	site_url,
	"/theme/images/by-nc-sa_80x15.png\" /></a>".

br --> "<br />".

license_text -->
	"Unless otherwise noted content on this website by <a href=\"mailto:",
	user_email,
	"\">",
	user_name,
	"</a> is licensed under a<br /><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/\">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.".

p_close --> "</p>".

footer_close --> "</footer>".

body_close --> "</body>".

html_close --> "</html>".
