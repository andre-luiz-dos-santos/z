
BEGIN {
	if ( q == tolower(q) ) {
		IGNORECASE = 1
	}

	split(q, patterns, " ")
}

{
	if ( system("test -d \"" $1 "\"") ) {
		next # directory does not exist
	}

	print >> tempfile

	matches[$1] = directory_score(type, patterns) # may call "next"
}

END {
	sort_cmd = "sort -n" # runs only once, even though it's piped into many times
	for( i in matches ) {
		printf("%-15s %s\n", matches[i], i) | sort_cmd # start "sort"
	}
	close(sort_cmd) # stop "sort"
}
