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
	append_lists(FindCodes, HaystackMinusMatch, Haystack),
	replace(FindCodes, ReplaceCodes, HaystackMinusMatch, ReplacedHaystackMinusMatch),
	append_lists(ReplaceCodes, ReplacedHaystackMinusMatch, Result).

replace(FindCodes, ReplaceCodes, [Code|Haystack], [Code|Result]):-
	replace(FindCodes, ReplaceCodes, Haystack, Result).


% append_lists(?List1, ?List2, ?Result).
%   Append two lists.
%   This is not an ISO predicate, so I've definded it here for portability.
append_lists([], List2, List2).

append_lists([First|List1], List2, [First|Result]):-
	append_lists(List1, List2, Result).


anything([]) --> [].

anything([X|Rest]) --> [X], anything(Rest).


whitespace --> [].

whitespace --> "\n", whitespace.

whitespace --> "\t", whitespace.

whitespace --> " ", whitespace.