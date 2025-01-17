%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: generate_rss.pl
% Description: Predicates to generate an RSS file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('helpers.pl').
:- include('rss.pl').

% generate_rss(+Filenames).
%	Filenames is a list of atoms containing paths to all Markdown files with a date.
%	These files will be read and used to generate an RSS of the most
%	recent posts.
generate_rss(Filenames, BuildDate):-
	% Read in all the files so we have their dates and contents.
	files_to_articles(Filenames, Articles),
	% Convert to RSS and write to stdout.
	rss(BuildDate, Articles, RSSCodes, []),
	write_codes(user_output, RSSCodes),
	halt.

% generate_rss.
%       Alternative interface to generate_rss(+Filenames) that reads
%       the list of files from stdin. This allows the filenames to be piped
%       from the output of another command like grep.
generate_rss(BuildDate):-
	read_file(user_input, FileListCodes),
	file_list(FileList, FileListCodes, []),
	generate_rss(FileList, BuildDate).


file_list([]) --> [].

file_list([File|FileList]) -->
	anything(FileCodes),
	newline,
	file_list(FileList),
	{ atom_codes(File, FileCodes) }.


% files_to_articles(+Filenames, -Articles).
%	Read in each file as an article predicate.
files_to_articles([], []).

files_to_articles([Filename|Filenames], [article(FormattedDate, FormattedTitle, Link, Description)|Articles]):-
	open(Filename, read, Stream),
	read_file(Stream, HTML),
	close(Stream),
	% Grab the link.
	get_link(Filename, Link),
	% Extract the title, entry, etc. from the HTML.
	page(Entry, _, _, Date, _, Title, HTML, []),
	% Format the date according to RFC 822.
	format_date(FormattedDate, Date),
	% XML escape the description.
	replace("&", "&amp;", Entry, EntryAmp),
	replace("<", "&lt;", EntryAmp, EntryLT),
	replace(">", "&gt;", EntryLT, Description),
	% Convert named HTML entities to numeric entities in the title.
	% Named entities don't work because they're not defined,
	% but numeric ones are fine.
	replace("&amp;", "&#38;", Title, TitleAmp),
	replace("&lsquo;", "&#8216;", TitleAmp, TitleLSQuo),
	replace("&rsquo;", "&#8217;", TitleLSQuo, TitleRSQuo),
	replace("&ldquo;", "&#8220;", TitleRSQuo, TitleLDQuo),
	replace("&rdquo;", "&#8221;", TitleLDQuo, TitleRDQuo),
	replace("&hellip;", "&#8230;", TitleRDQuo, FormattedTitle),
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
