%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: markdown.pl
% Description: DCG definition of a Markdown file.
%	Markdown files may have no metadata at the start,
%	or they may have a Title, Subtitle, and Date (all optional, but in that order).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

markdown(Entry, Title, Subtitle, Date, Breadcrumb) -->
	metadata_block(Title, Subtitle, Date, Breadcrumb),
	newline, newline,
	anything(Entry).

markdown(Entry, null, null, null, null) -->
	anything(Entry).


metadata_block(Title, Subtitle, Date, Breadcrumb) -->
	metadata(Title, Subtitle, Date, Breadcrumb),
	newline,
	metadata_block(Title, Subtitle, Date, Breadcrumb).

metadata_block(Title, Subtitle, Date, Breadcrumb) -->
	metadata(Title, Subtitle, Date, Breadcrumb).


metadata(Title, _, _, _) -->
	"Title: ",
	anything(Title).

metadata(_, Subtitle, _, _) -->
	"Subtitle: ",
	anything(Subtitle).

metadata(_, _, Date, _) -->
	"Date: ",
	anything(Date).

metadata(_, _, _, Breadcrumb) -->
	"Breadcrumb: ",
	anything(Breadcrumb).
