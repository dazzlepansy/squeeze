%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: markdown.pl
% Description: DCG definition of a Markdown file.
%	Markdown files may have no metadata at the start,
%	or they may have a Title, Subtitle, and Date (all optional, but in that order).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

markdown(Entry, Title, Subtitle, Date) -->
	metadata_block(Title, Subtitle, Date),
	newline, newline,
	anything(Entry).

markdown(Entry, null, null, null) -->
	anything(Entry).


metadata_block(Title, Subtitle, Date) -->
	metadata(Title, Subtitle, Date),
	newline,
	metadata_block(Title, Subtitle, Date).

metadata_block(Title, Subtitle, Date) -->
	metadata(Title, Subtitle, Date).


metadata(Title, _, _) -->
	"Title: ",
	anything(Title).

metadata(_, Subtitle, _) -->
	"Subtitle: ",
	anything(Subtitle).

metadata(_, _, Date) -->
	"Date: ",
	anything(Date).

metadata(null, null, null) --> [].
