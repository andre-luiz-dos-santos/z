
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
	score = directory_score(type, patterns) # may call "next"
	if ( score > best_score ) {
		best_score = score
		best_match = $1
	}
}

END {
	print best_match
}
