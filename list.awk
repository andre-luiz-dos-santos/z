
BEGIN {
	for ( i = 2; i < ARGC; i ++ ) {
		patterns[i] = ARGV[i]
		delete ARGV[i]
	}
}

BEGIN {
	IGNORECASE =! has_uppercase_value(patterns)
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
