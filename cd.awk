
BEGIN {
	pwd = ARGV[2]
	delete ARGV[2]

	for ( i = 3; i < ARGC; i ++ ) {
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
