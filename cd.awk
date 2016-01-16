
BEGIN {
	pwd = ARGV[1]
	delete ARGV[1]

	for ( i = 2; i < ARGC; i ++ ) {
		patterns[i] = ARGV[i]
		delete ARGV[i]
	}
}

BEGIN {
	IGNORECASE =! has_uppercase_value(patterns)
}

{
	if ( $1 == pwd ) {
		next # don't try to cd to the current directory
	}

	score = directory_score(type, patterns) # may call "next"
	if ( score > best_score ) {
		best_score = score
		best_match = $1
	}
}

END {
	print best_match
}
