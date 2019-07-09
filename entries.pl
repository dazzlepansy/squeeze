:- include('helpers.pl').
:- include('html.pl').
:- include('markdown.pl').

parse_entry:-
	read_file(user_input, HTML),
	parse_html(HTML).

parse_entry(Filename):-
	open(Filename, read, Stream),
	read_file(Stream, HTML),
	close(Stream),
	parse_html(HTML).

parse_html(HTML):-
	page(EntryCodes, Title, Subtitle, Date, HTML, []),
	markdown(EntryCodes, Title, Subtitle, Date, MarkdownCodes, []),
	atom_codes(Markdown, MarkdownCodes),
	write(Markdown),
	halt.

generate_entry:-
	read_file(user_input, Entry),
	generate_html(Entry).

generate_entry(Filename):-
	open(Filename, read, Stream),
	read_file(Stream, Entry),
	close(Stream),
	generate_html(Entry).

generate_html(Markdown):-
	markdown(EntryCodes, Title, Subtitle, Date, Markdown, []),
	page(EntryCodes, Title, Subtitle, Date, HTMLCodes, []),
	atom_codes(HTML, HTMLCodes),
	write(HTML),
	halt.