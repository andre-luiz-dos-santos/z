
BEGIN {
	for ( i = 2; i < ARGC; i ++ ) {
		directories[ARGV[i]] = 1
		delete ARGV[i]
	}
}

$2 >= 1 {
	count += $2
	rank[$1] = $2
	time[$1] = $3
}

END {
	for ( directory in directories ) {
		rank[directory] ++
		time[directory] = now
	}

	# On fish, it's quicker to enter these directories by typing …
	delete rank["/"]  # … /
	if ( "HOME" in ENVIRON ) {
		delete rank[ENVIRON["HOME"]]  # … ~
	}

	if ( count > 9000 ) {
		for ( i in rank ) {
			print i "|" 0.99*rank[i] "|" time[i]  # aging
		}
	}
	else {
		for ( i in rank ) {
			print i "|" rank[i] "|" time[i]
		}
	}
}
