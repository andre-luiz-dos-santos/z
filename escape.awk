
BEGIN {
	if ( regexp == "false" && command != "add" ) {
		escape_re_characters = 1
	}

	for ( i = 1; i < ARGC; i ++ ) {
		if ( escape_re_characters ) {
			# Source http://backreference.org/2010/03/13/safely-escape-variables-in-awk/
			gsub( /[][^$.*?+{}\\()|]/ , "\\\\&", ARGV[i] )
		}

		# awk --assign will take one backslash.
		# https://www.gnu.org/software/gawk/manual/html_node/Assignment-Options.html
		gsub( /\\/ , "\\\\&", ARGV[i] )

		print ARGV[i]
	}
}
