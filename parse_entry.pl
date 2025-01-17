%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: parse_entry.pl
% Description: Predicates to generate and parse a static site's Markdown/HTML.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('helpers.pl').
:- include('markdown.pl').

% parse_entry.
%	Read in an HTML file from stdin.
parse_entry:-
	read_file(user_input, HTML),
	parse_html(HTML).

% parse_entry(+Filename).
%	Read in an HTML file from Filename.
parse_entry(Filename):-
	open(Filename, read, Stream),
	read_file(Stream, HTML),
	close(Stream),
	parse_html(HTML).


% parse_html(+HTML).
%	Parse HTML into a Markdown file and write to stdout.
parse_html(HTML):-
	page(EntryCodes, Title, Subtitle, Date, Breadcrumb, _, HTML, []),
	markdown(EntryCodes, Title, Subtitle, Date, Breadcrumb, MarkdownCodes, []),
	write_codes(user_output, MarkdownCodes),
	halt.


% generate_entry.
%	Read in a Markdown file from stdin.
generate_entry:-
	read_file(user_input, Entry),
	generate_html(Entry).

% generate_entry(Filename).
%	Read in a Markdown file from Filename.
generate_entry(Filename):-
	open(Filename, read, Stream),
	read_file(Stream, Entry),
	close(Stream),
	generate_html(Entry).


% generate_html(Markdown).
%	Parse Markdown into an HTML file and write to stdout.
generate_html(Markdown):-
	markdown(EntryCodes, Title, Subtitle, Date, Breadcrumb, Markdown, []),
	clean_title(Title, CleanTitle),
	page(EntryCodes, Title, Subtitle, Date, Breadcrumb, CleanTitle, HTMLCodes, []),
	write_codes(user_output, HTMLCodes),
	halt.


% clean_title(+Title, -CleanTitle).
% 	Replace select HTML tags in an entry title to make it suitable
% 	for an HTML title.
clean_title(null, null).

clean_title(Title, CleanTitle):-
	replace("<cite>", "\"", Title, Title1),
	replace("</cite>", "\"", Title1, CleanTitle).
