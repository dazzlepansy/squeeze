%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: rss.pl
% Description: DCG definition of an RSS file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rss(BuildDate, Articles) -->
	rss_open,
	newline, tab, tab,
	channel_meta(BuildDate),
	items(Articles),
	newline, tab,
	rss_close.

rss_open -->
	"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
	newline,
	"<rss version=\"2.0\">",
	newline, tab,
	"<channel>".

channel_meta(BuildDate) -->
	"<title>",
	site_title,
	"</title>",
	newline, tab, tab,
	"<description>",
	site_subtitle,
	"</description>",
	newline, tab, tab,
	"<link>",
	site_url,
	"</link>",
	newline, tab, tab,
	language,
	newline, tab, tab,
	copyright,
	newline, tab, tab,
	webmaster,
	newline, tab, tab,
	last_build_date(BuildDate).

item_title(Title) -->
	"<title>",
	Title,
	"</title>".

item_description(Description) -->
	"<description>",
	Description,
	"</description>".

item_link(Link) -->
	"<link>",
	Link,
	"</link>".

language -->
	"<language>",
	"en-US",
	"</language>".

copyright -->
	"<copyright>",
	"Licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.",
	"</copyright>".

webmaster -->
	"<webMaster>",
	user_email,
	"</webMaster>".

last_build_date(BuildDate) -->
	"<lastBuildDate>",
	anything(BuildDate),
	"</lastBuildDate>".

items([]) --> [].

items([First|Rest]) --> item(First), items(Rest).

item(article(Date, Title, Link, Description)) -->
	newline, tab, tab,
	item_open,
	newline, tab, tab, tab,
	item_title(Title),
	newline, tab, tab, tab,
	item_link(Link),
	newline, tab, tab, tab,
	item_description(Description),
	newline, tab, tab, tab,
	author,
	newline, tab, tab, tab,
	item_pubdate(Date),
	newline, tab, tab,
	item_close.

item_open --> "<item>".

author -->
	"<author>",
	user_name,
	"</author>".

item_pubdate(Date) -->
	"<pubDate>",
	anything(Date),
	"</pubDate>".

item_close --> "</item>".

rss_close -->
	"</channel>",
	newline,
	"</rss>".
