
function frecent(rank, time) {
	dx = now-time
	if ( dx < 3600 )   return rank*4
	if ( dx < 86400 )  return rank*2
	if ( dx < 604800 ) return rank/2
	                   return rank/4
}

function directory_score(type, patterns) {
	for ( i in patterns ) {
		if ( $1 !~ patterns[i] ) {
			next # one of the patterns does not match
		}
	}

	     if ( type == "rank" )   score = $2
	else if ( type == "recent" ) score = $3
	else                         score = frecent($2, $3)

	n = split($1, names, "/")
	for ( i in patterns ) {
		if ( names[n] ~ patterns[i] ) {
			score *= 100 # pattern matches last component of directory
			break
		}
	}

	return score
}
