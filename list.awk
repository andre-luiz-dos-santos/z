
BEGIN {
	if ( q == tolower(q) ) {
		IGNORECASE = 1
	}

	split(q, patterns, " ")
}

{
	matches[$1] = directory_score(type, patterns) # may call "next"
}

END {
	sort_cmd = "sort -n" # runs only once, even though it's piped into many times
	for( i in matches ) {
		printf("%-15s %s\n", matches[i], i) | sort_cmd # start "sort"
	}
	close(sort_cmd) # stop "sort"
}
