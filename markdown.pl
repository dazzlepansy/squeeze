%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: markdown.pl
% Description: DCG definition of a Markdown file.
%	Markdown files may have no metadata at the start,
%	or they may have a Title, Subtitle, and Date (all optional, but in that order).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

markdown(Entry, Title, Subtitle, Date) -->
	metadata("Title", Title),
	"\n",
	metadata("Subtitle", Subtitle),
	"\n",
	metadata("Date", Date),
	"\n\n",
	anything(Entry).

markdown(Entry, Title, null, Date) -->
	metadata("Title", Title),
	"\n",
	metadata("Date", Date),
	"\n\n",
	anything(Entry).

markdown(Entry, Title, Subtitle, null) -->
	metadata("Title", Title),
	"\n",
	metadata("Subtitle", Subtitle),
	"\n\n",
	anything(Entry).

markdown(Entry, Title, null, null) -->
	metadata("Title", Title),
	"\n\n",
	anything(Entry).

markdown(Entry, null, null, null) -->
	anything(Entry).

metadata(Key, Value) -->
	Key,
	": ",
	anything(Value).