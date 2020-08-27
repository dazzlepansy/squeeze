%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicate implementations for GNU-Prolog dialects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Detect GNU-Prolog
gnu_prolog:-
	catch(current_prolog_flag(dialect, gprolog), _, fail).

gnu_prolog:-
	catch(current_prolog_flag(prolog_name, 'GNU Prolog'), _, fail).


% GNU-Prolog-specific predicate to run an external Markdown tool.
% The command itself should be specified in your site.pl.
markdown_to_html(MarkdownEntryCodes, HTMLEntryCodes):-
	gnu_prolog,
	markdown_command(CommandList),
	join(CommandList, ' ', Command),
	exec(Command, StreamIn, StreamOut, _),
	write_codes(StreamIn, MarkdownEntryCodes),
	close(StreamIn),
	read_file(StreamOut, HTMLEntryCodes),
	close(StreamOut).


% GNU-Prolog-specific handling of dates.
today(FormattedDateCodes):-
	gnu_prolog,
	date_time(dt(Year, Month, Day, Hour, Minute, Second)),
	join([Year, '-', Month, '-', Day, ' ', Hour, ':', Minute, ':', Second], '', DateAtom),
	atom_codes(DateAtom, DateCodes),
	format_date(FormattedDateCodes, DateCodes).

% Format a date as RFC 822 (with a four-digit year).
format_date(FormattedDateCodes, DateCodes):-
	gnu_prolog,
	atom_codes(DateAtom, DateCodes),
	join(['--date="', DateAtom, '"'], '', Arg),
	join(['date', Arg, '--rfc-email'], ' ', Command),
	exec(Command, _, StreamOut, _),
	read_file(StreamOut, FormattedDateCodes),
	close(StreamOut).
