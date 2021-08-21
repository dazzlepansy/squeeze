#!/usr/bin/env sh

SITE_PATH="$1"
shift

ARGS="$(echo "$@" | sed "s|$SITE_PATH/output/||g")"

for arg in $ARGS; do
	echo "$arg"
	
	swipl --traditional --quiet -l parse_entry.pl -g "consult('$SITE_PATH/site.pl'), parse_entry('$SITE_PATH/output/$arg')." \
		> "$SITE_PATH/source/${arg%%.html}.md" &
done

wait
