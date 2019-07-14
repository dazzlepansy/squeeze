%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: generate_rss.pl
% Description: Predicates to generate an RSS file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('helpers.pl').
:- include('markdown.pl').
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
	% Grab the most recent 5.
	take_last(5, SortedArticles, TakenArticles),
	% Convert to RSS and write to stdout.
	rss(BuildDate, TakenArticles, RSSCodes, []),
	atom_codes(RSS, RSSCodes),
	write(RSS),
	halt.


% files_to_articles(+Filenames, -Articles).
%	Read in each file as an article predicate.
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


% get_link(?Filename, ?Link).
%	Calculate a file's URL, given its current path.
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