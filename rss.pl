:- include('helpers.pl').
:- include('markdown.pl').

generate_rss(BuildDate, Filenames):-
	files_to_articles(Filenames, Articles),
	sort(Articles, SortedArticles),
	take_last(5, SortedArticles, TakenArticles),
	rss(BuildDate, TakenArticles, RSSCodes, []),
	atom_codes(RSS, RSSCodes),
	write(RSS),
	halt.

files_to_articles([], []).

files_to_articles([Filename|Filenames], [article(Date, Title, Link, Description)|Articles]):-
	open(Filename, read, Stream),
	read_file(Stream, Markdown),
	close(Stream),
	% Grab the link.
	get_link(Filename, Link),
	% Extract the title, entry, etc. from the Markdown.
	markdown(Entry, Title, _, Date, Markdown, []),
	% XML escape the description.
	replace("&", "&amp;", Entry, EntryAmp),
	replace("<", "&lt;", EntryAmp, EntryLT),
	replace(">", "&gt;", EntryLT, Description),
	files_to_articles(Filenames, Articles).

get_link(Filename, Link):-
	atom_codes(Filename, FilenameCodes),
	% Just assert that this is an index file before we go further.
	% Backtracking after this point will take us down a rabbit hole.
	append(_, "index.md", FilenameCodes),
	site_url(URL, []),
	append(_, "/source", StartPath),
	append(StartPath, Path, FilenameCodes),
	append(PathWithoutFile, "index.md", Path),
	append(URL, PathWithoutFile, Link).

get_link(Filename, Link):-
	atom_codes(Filename, FilenameCodes),
	site_url(URL, []),
	append(_, "/source", StartPath),
	append(StartPath, Path, FilenameCodes),
	append(PathWithoutExtension, ".md", Path),
	append(PathWithoutExtension, "/", PathWithSlash),
	append(URL, PathWithSlash, Link).

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
	BuildDate,
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
	Date,
	"</pubDate>".

item_close --> "</item>".

rss_close -->
	"</channel>",
	"\n",
	"</rss>".