%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: helpers.pl
% Description: Misc. utility predicates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read_file(+Stream, -Codes).
%	Read a file to a list of character codes.
read_file(Stream, Codes):-
	get_code(Stream, Code),
	read_file_next(Code, Stream, Codes).

read_file_next(-1, _, []).

read_file_next(Code, Stream, [Code|Rest]):-
	read_file(Stream, Rest).


% replace(+FindCodes, +ReplaceCodes, +Haystack, -Result).
%	Find instances of FindCodes in Haystack and replace with ReplaceCodes.
%	All four arguments are lists of character codes.
replace(FindCodes, ReplaceCodes, Haystack, Result):-
	substrings(FindCodes, Substrings, Haystack, []),
	substrings(ReplaceCodes, Substrings, Result, []).

substrings(Delimiter, [Substring|Substrings]) -->
	anything(Substring),
	Delimiter,
	substrings(Delimiter, Substrings).

substrings(_, [Substring]) --> anything(Substring).


% write_codes(+CodesList).
%   Loop through a list of character codes, convert each one to a
%   character, and write them to the current output stream one at
%   a time. This is better than converting the whole list to an atom
%   with atom_codes/2, which can trigger a segfault if the atom is too long.
write_codes(_, []).

write_codes(Stream, [X|Rest]):-
	char_code(Char, X),
	write(Stream, Char),
	write_codes(Stream, Rest).


% join(?List, +Separator, ?Atom).
%   Join elements of a list into an atom separated by a separator.
%   Written specifically as a join predicate, but should work as a split.
join([], _, '').

join([A], _, A).

join([First|Rest], Separator, Result):-
	join(Rest, Separator, End),
	atom_concat(First, Separator, FirstPlusSeparator),
	atom_concat(FirstPlusSeparator, End, Result).


% format_date(-RFCDate, +Date).
%   Parse and format a date according to RFC 822.
format_date(RFCDate, Date):-
	date_stamp(YearCodes, MonthCodes, DayCodes, Date, []),
	number_codes(Year, YearCodes),
	number_codes(Month, MonthCodes),
	number_codes(Day, DayCodes),
	day_of_week(date(Year, Month, Day), DayOfWeek),
	day(DayOfWeek, DayOfWeekNameCodes),
	month(Month, MonthNameCodes, _),
	rfc_822(YearCodes, MonthNameCodes, DayCodes, DayOfWeekNameCodes, RFCDate, []).

% TODO: Implement support for other date formats.
% Currently we support YYYY-MM-DD.
date_stamp(YearCodes, MonthCodes, DayCodes) -->
	anything(YearCodes),
	"-",
	anything(MonthCodes),
	"-",
	anything(DayCodes).

rfc_822(YearCodes, MonthNameCodes, DayCodes, DayOfWeekNameCodes) -->
	anything(DayOfWeekNameCodes),
	", ",
	anything(DayCodes),
	" ",
	anything(MonthNameCodes),
	" ",
	anything(YearCodes),
	" 00:00:00 GMT".

day_of_week(date(Year, Month, Day), DayOfWeek):-
	magic_year(Year, Month, MagicYear),
	month(Month, _, MagicMonth),
	DayOfWeek is (MagicYear + MagicYear // 4 - MagicYear // 100 + MagicYear // 400 + MagicMonth + Day) mod 7.

magic_year(Year, Month, MagicYear):-
	Month < 3,
	MagicYear is Year - 1.

magic_year(Year, _, Year).

% month(?MonthNumber, ?ShortName, -MagicNumber).
%   Magic numbers, used for calculating the day of the week,
%   are as defined in Sakamoto's methods:
%   https://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week#Sakamoto's_methods
month(1, "Jan", 0).
month(2, "Feb", 3).
month(3, "Mar", 2).
month(4, "Apr", 5).
month(5, "May", 0).
month(6, "Jun", 3).
month(7, "Jul", 5).
month(8, "Aug", 1).
month(9, "Sep", 4).
month(10, "Oct", 6).
month(11, "Nov", 2).
month(12, "Dec", 4).

day(0, "Sun").
day(1, "Mon").
day(2, "Tue").
day(3, "Wed").
day(4, "Thu").
day(5, "Fri").
day(6, "Sat").


anything([]) --> [].

anything([X|Rest]) --> [X], anything(Rest).


whitespace --> [].

whitespace --> newline, whitespace.

whitespace --> tab, whitespace.

whitespace --> " ", whitespace.

newline --> "\n".

tab --> "\t".
