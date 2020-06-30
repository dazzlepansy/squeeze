%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: generate_rss.pl
% Description: Predicates to generate an RSS file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('helpers.pl').
:- include('rss.pl').

% generate_rss(+BuildDate, +Filenames).
%	BuildDate is a list of character codes representing today's date (e.g. "2109-07-14").
%	Filenames is a list of atoms containing paths to all Markdown files with a date.
%	These files will be read, sorted by date, and used to generate an RSS of the most
%	recent posts.
generate_rss(BuildDate, Filenames):-
	% Read in all the files so we have their dates and contents.
	files_to_articles(Filenames, Articles),
	% Sort articles by date.
	sort(Articles, SortedArticles),
	% Convert to RSS and write to stdout.
	rss(BuildDate, SortedArticles, RSSCodes, []),
	write_codes(user_output, RSSCodes),
	halt.


% files_to_articles(+Filenames, -Articles).
%	Read in each file as an article predicate.
files_to_articles([], []).

files_to_articles([Filename|Filenames], [article(Date, Title, Link, Description)|Articles]):-
	open(Filename, read, Stream),
	read_file(Stream, HTML),
	close(Stream),
	% Grab the link.
	get_link(Filename, Link),
	% Extract the title, entry, etc. from the HTML.
	page(Entry, Title, _, Date, HTML, []),
	% XML escape the description.
	replace("&", "&amp;", Entry, EntryAmp),
	replace("<", "&lt;", EntryAmp, EntryLT),
	replace(">", "&gt;", EntryLT, Description),
	files_to_articles(Filenames, Articles).


% get_link(?Filename, ?Path).
%	Calculate a file's URL, given its current path.
get_link(Filename, LinkPath):-
	atom_codes(Filename, FilenameCodes),
	file_path(RelativePath, FilenameCodes, []),
	link_path(RelativePath, LinkPath, []).

file_path(Path) -->
	anything(_),
	"/output",
	anything(Path),
	"/index.html".

file_path(Path) -->
	anything(_),
	"/output",
	anything(Path),
	".html".

link_path(RelativePath) -->
	anything(RelativePath),
	"/".
