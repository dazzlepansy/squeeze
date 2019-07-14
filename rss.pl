%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: rss.pl
% Description: DCG definition of an RSS file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rss(BuildDate, Articles) -->
	rss_open,
	"\n",
	channel_meta(BuildDate),
	"\n",
	items(Articles),
	"\n",
	rss_close.

rss_open -->
	"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
	"\n",
	"<rss version=\"2.0\">",
	"\n",
	"<channel>".

channel_meta(BuildDate) -->
	"<title>",
	site_title,
	"</title>",
	"\n",
	"<description>",
	site_subtitle,
	"</description>",
	"\n",
	"<link>",
	site_url,
	"</link>",
	"\n",
	language,
	"\n",
	copyright,
	"\n",
	webmaster,
	"\n",
	last_build_date(BuildDate).

title(Title) -->
	"<title>",
	Title,
	"</title>".

description(Description) -->
	"<description>",
	Description,
	"</description>".

link(Link) -->
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
	email,
	"</webMaster>".

last_build_date(BuildDate) -->
	"<lastBuildDate>",
	anything(BuildDate),
	"</lastBuildDate>".

items([]) --> [].

items([First|Rest]) --> item(First), items(Rest).

item(article(Date, Title, Link, Description)) -->
	item_open,
	"\n",
	title(Title),
	"\n",
	link(Link),
	"\n",
	description(Description),
	"\n",
	author,
	"\n",
	pubdate(Date),
	"\n",
	item_close.

item_open --> "<item>".

author -->
	"<author>",
	name,
	"</author>".

pubdate(Date) -->
	"<pubDate>",
	anything(Date),
	"</pubDate>".

item_close --> "</item>".

rss_close -->
	"</channel>",
	"\n",
	"</rss>".