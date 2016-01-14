
BEGIN {
	for ( i = 1; i < ARGC; i ++ ) {
		# Source http://backreference.org/2010/03/13/safely-escape-variables-in-awk/
		gsub( /[][^$.*?+{}\\()|]/ , "\\\\&", ARGV[i] )
		print ARGV[i]
	}
}
