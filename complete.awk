
BEGIN {
	if ( q == tolower(q) ) {
		IGNORECASE = 1
	}

	split(q, patterns, " ")
}

{
	for ( i in patterns ) {
		if ( $1 !~ patterns[i] ) {
			next # one of the patterns does not match
		}
	}

	print $1 # show only directory in the completion menu
}
