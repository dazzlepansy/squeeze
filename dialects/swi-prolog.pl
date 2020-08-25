%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicate implementations for SWI-Prolog dialects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Detect SWI-Prolog
swi_prolog:-
	catch(current_prolog_flag(dialect, swi), _, fail).


% SWI-Prolog-specific predicate to run an external Markdown tool.
% The command itself should be specified in your site.pl.
markdown_to_html(MarkdownEntryCodes, HTMLEntryCodes):-
	swi_prolog,
	markdown_command([Exe|Args]),
	process_create(Exe, Args, [stdin(pipe(StreamIn)), stdout(pipe(StreamOut))]),
	write_codes(StreamIn, MarkdownEntryCodes),
	close(StreamIn),
	read_file(StreamOut, HTMLEntryCodes),
	close(StreamOut).


% SWI-Prolog-specific predicates for date handling.
today(FormattedDateCodes):-
	swi_prolog,
	get_time(DateStamp),
	format_time(codes(FormattedDateCodes), '%a, %d %b %Y %T %z', DateStamp).

% Format a date as RFC 822 (with a four-digit year).
format_date(FormattedDateCodes, DateCodes):-
	swi_prolog,
	atom_codes(DateAtom, DateCodes),
	parse_time(DateAtom, DateStamp),
	format_time(codes(FormattedDateCodes), '%a, %d %b %Y %T %z', DateStamp).
