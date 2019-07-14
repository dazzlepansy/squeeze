%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: html.pl
% Description: DCG definition of an HTML file.
%	This is basically your static website's template.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

page(Entry, Title, Subtitle, Date) -->
	doctype,
	whitespace,
	html(Entry, Title, Subtitle, Date).

html(Entry, Title, Subtitle, Date) -->
	html_open,
	whitespace,
	head(Title),
	whitespace,
	body(Entry, Title, Subtitle, Date),
	whitespace,
	html_close.

head(Title) -->
	head_open,
	whitespace,
	title(Title),
	whitespace,
	meta,
	whitespace,
	styles,
	whitespace,
	rss,
	whitespace,
	head_close.

body(Entry, Title, Subtitle, Date) -->
	body_open,
	whitespace,
	header(Title),
	whitespace,
	article(Entry, Title, Subtitle, Date),
	whitespace,
	entry_utility,
	whitespace,
	footer,
	whitespace,
	body_close.

header(Title) -->
	header_open,
	whitespace,
	header_title(Title),
	whitespace,
	header_subtitle,
	whitespace,
	header_close.

article(Entry, Title, Subtitle, Date) -->
	article_open,
	whitespace,
	article_header(Title, Subtitle, Date),
	whitespace,
	div_entry_open,
	whitespace,
	anything(Entry),
	whitespace,
	div_entry_close,
	whitespace,
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
	whitespace,
	article_meta(Date).

% An article without metadata.
article_header(Title, Subtitle, null) -->
	article_title(Title),
	whitespace,
	article_subtitle(Subtitle).

% An article with all header components.
article_header(Title, Subtitle, Date) -->
	article_title(Title),
	whitespace,
	article_subtitle(Subtitle),
	whitespace,
	article_meta(Date).

footer -->
	footer_open,
	whitespace,
	p_center_open,
	whitespace,
	license_link,
	whitespace,
	br,
	whitespace,
	license_text,
	whitespace,
	p_close,
	whitespace,
	footer_close.

doctype --> "<!DOCTYPE html>".

html_open --> "<html lang=\"en\">".

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

title(_) -->
	"<title>",
	anything(_),
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

article_open -->
	"<article id=\"",
	anything(_),
	"\">".

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
	whitespace,
	"<time datetime=\"",
	anything(ArticleDate),
	anything(_),
	"\">",
	anything(ArticleDate),
	"</time>",
	whitespace,
	"</div><!-- .entry-meta -->".

div_entry_open --> "<div class=\"entry-content\">".

div_entry_close --> "</div><!-- .entry-content -->".

article_close -->
	"</article><!-- ",
	anything(_),
	" -->".

entry_utility --> [].

entry_utility -->
	"<div class=\"entry-utility\">",
	anything(_),
	"</div><!-- #entry-utility -->".

footer_open --> "<footer>".

p_center_open --> "<p class=\"center\">".

license_link -->
	"<a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/\"><img alt=\"Creative Commons License\" style=\"border-width:0\" src=\"",
	site_url,
	"/theme/images/by-nc-sa_80x15.png\" /></a>".

br --> "<br />".

license_text -->
	"Unless otherwise noted content on this website by <a href=\"mailto:",
	email,
	"\">",
	name,
	"</a> is licensed under a<br /><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/3.0/\">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.".

p_close --> "</p>".

footer_close --> "</footer>".

body_close --> "</body>".

html_close --> "</html>".