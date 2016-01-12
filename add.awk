
BEGIN {
	rank[directory] = 1
	time[directory] = now
}

$2 >= 1 {
	if ( $1 == directory ) {
		rank[$1] = $2 + 1
		time[$1] = now
	}
	else {
		rank[$1] = $2
		time[$1] = $3
	}
	count += $2
}

END {
	if ( count > 1000 ) {
		for ( i in rank ) {
			print i "|" 0.9*rank[i] "|" time[i]  # aging
		}
	}
	else {
		for ( i in rank ) {
			print i "|" rank[i] "|" time[i]
		}
	}
}
