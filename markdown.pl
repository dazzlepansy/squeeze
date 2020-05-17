%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: markdown.pl
% Description: DCG definition of a Markdown file.
%	Markdown files may have no metadata at the start,
%	or they may have a Title, Subtitle, and Date (all optional, but in that order).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

markdown(Entry, Title, Subtitle, Date) -->
	"Title: ",
	anything(Title),
	newline,
	"Subtitle: ",
	anything(Subtitle),
	newline,
	"Date: ",
	anything(Date),
	newline, newline,
	anything(Entry).

markdown(Entry, Title, null, Date) -->
	"Title: ",
	anything(Title),
	newline,
	"Date: ",
	anything(Date),
	newline, newline,
	anything(Entry).

markdown(Entry, Title, Subtitle, null) -->
	"Title: ",
	anything(Title),
	newline,
	"Subtitle: ",
	anything(Subtitle),
	newline, newline,
	anything(Entry).

markdown(Entry, Title, null, null) -->
	"Title: ",
	anything(Title),
	newline, newline,
	anything(Entry).

markdown(Entry, null, null, null) -->
	anything(Entry).