
BEGIN {
	if ( q == tolower(q) ) {
		IGNORECASE = 1
	}

	split(q, patterns, " ")
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
