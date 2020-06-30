%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: helpers.pl
% Description: Misc. utility predicates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read_file(+Stream, -Codes).
%	Read a file to a list of character codes.
read_file(Stream, []):-
	at_end_of_stream(Stream).

read_file(Stream, [Code|Rest]):-
	\+ at_end_of_stream(Stream),
	get_code(Stream, Code),
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
	join(Rest, End),
	atom_concat(First, Separator, FirstPlusSeparator),
	atom_concat(FirstPlusSeparator, End, Result).


anything([]) --> [].

anything([X|Rest]) --> [X], anything(Rest).


whitespace --> [].

whitespace --> newline, whitespace.

whitespace --> tab, whitespace.

whitespace --> " ", whitespace.

newline --> "\n".

tab --> "\t".
