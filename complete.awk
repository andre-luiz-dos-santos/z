
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
	for ( i in patterns ) {
		if ( $1 !~ patterns[i] ) {
			next # one of the patterns does not match
		}
	}

	print $1 # show only directory in the completion menu
}
