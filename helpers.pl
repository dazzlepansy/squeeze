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


% take_last(+Max, +List, -Results).
%	Return the last Max elements of List.
take_last(_, [], []).

take_last(Max, [First|Rest], Result):-
	take_last(Max, Rest, ResultSoFar),
	take_append(Max, First, ResultSoFar, Result).

take_append(Max, _, ResultSoFar, ResultSoFar):-
	length(ResultSoFar, Max).

take_append(_, Item, ResultSoFar, [Item|ResultSoFar]).


% replace(+FindCodes, +ReplaceCodes, +Haystack, -Result).
%	Find instances of FindCodes in Haystack and replace with ReplaceCodes.
%	All four arguments are lists of character codes.
replace(_, _, [], []).

replace(FindCodes, ReplaceCodes, Haystack, Result):-
	append(FindCodes, HaystackMinusMatch, Haystack),
	replace(FindCodes, ReplaceCodes, HaystackMinusMatch, ReplacedHaystackMinusMatch),
	append(ReplaceCodes, ReplacedHaystackMinusMatch, Result).

replace(FindCodes, ReplaceCodes, [Code|Haystack], [Code|Result]):-
	replace(FindCodes, ReplaceCodes, Haystack, Result).


anything([]) --> [].

anything([X|Rest]) --> [X], anything(Rest).


whitespace --> [].

whitespace --> "\n", whitespace.

whitespace --> "\t", whitespace.

whitespace --> " ", whitespace.