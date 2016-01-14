
complete --arguments '(z --complete (commandline --current-token))' --no-files --command z
complete --short-option a --long-option add    --description 'add directories to the z history file' --require-parameter --command z
complete --short-option l --long-option list   --description 'list directories in the z history file' --command z
complete --short-option r --long-option rank   --description 'use the highest ranked directory' --command z
complete --short-option t --long-option recent --description 'use the most recently accessed directory' --command z
complete --short-option c --long-option subdir --description 'only match within the current directory' --command z
complete --short-option e --long-option regexp --description 'use regular expression matching' --command z
complete                  --long-option clean  --description 'forget removed directories' --command z

function add_directory_to_z_history_on_pwd_change --on-variable PWD
	z --add $PWD
end

function z --description "Jump to a recent directory"
	set --local datafile "$HOME/.z"
	set --local z_dir (dirname (status --current-filename))
	set --local type 'frecent'
	set --local tempfile
	set --local target
	set --local error
	set --local subdir false
	set --local regexp false
	set --local command cd

	# Parse all the command line arguments before starting the program.
	# Note: The "break" calls inside the switch will exit the while loop,
	#       not the switch! "break" works for loops only, as documented.
	while test (count $argv) -ge 1
		switch $argv[1]
			case --add -a
				set command 'add'
			case --list -l
				set command 'list'
			case --rank -r
				set type "rank"
			case --recent -t
				set type "recent"
			case --subdir -c
				set subdir true
			case --regexp -e
				set regexp true
			case --complete
				set command 'complete'
			case --clean
				set command 'clean'
			case --
				set -e argv[1]
				break
			case '-*'
				echo "Invalid option $argv[1]" >&2
				return 2
			case '*'
				break
		end
		set -e argv[1]
	end

	test $command = cd
	and test (count $argv) -eq 0
	and set command list

	set argv (
		awk \
			--file $z_dir/escape.awk \
			--assign command=$command \
			--assign regexp=$regexp \
			$argv
	)

	test $subdir = true
	and set argv $argv '^'(pwd)

	switch $command
		case add
			test -e $datafile
			or touch $datafile

			for directory in $argv
				test $directory != $HOME
				or continue # no need, ~ is shorter

				set tempfile (mktemp $datafile.XXXXXX)
				and test -f $tempfile # is regular file
				or return 1

				awk --file $z_dir/add.awk \
					--assign directory=$directory \
					--assign now=(date +%s) \
					--field-separator "|" \
					$datafile > $tempfile
				and mv --force $tempfile $datafile
				or rm --force $tempfile # also runs if the mv above fails
			end

		case complete
			test -f $datafile
			or return 0

			awk --file $z_dir/complete.awk \
				--assign q="$argv" \
				--field-separator "|" \
				$datafile

		case list
			test -f $datafile
			or return 0

			awk \
				--file $z_dir/lib.awk \
				--file $z_dir/list.awk \
				--assign now=(date +%s) \
				--assign type=$type \
				--assign q="$argv" \
				--field-separator "|" \
				$datafile

		case cd
			test (count $argv) -eq 1 # When the single argument
			and test -d $argv[1]     # provided is a directory,
			and return (cd $argv[1]) # then "cd" directly into it.

			test -f $datafile
			or return 0

			set target (awk \
				--file $z_dir/lib.awk \
				--file $z_dir/cd.awk \
				--assign now=(date +%s) \
				--assign type=$type \
				--assign q="$argv" \
				--field-separator "|" \
				$datafile)
			and begin
				if test -z $target # is empty
					echo "No match was found!"
					return 3
				else
					echo cd $target
					cd $target
				end
			end

		case clean
			set tempfile (mktemp $datafile.XXXXXX)
			and test -f $tempfile # is regular file
			or return 1

			set error (begin
				set --local IFS '|'
				while read --local directory rank timestamp
					test -d $directory
					and echo "$directory|$rank|$timestamp"
				end < $datafile >> $tempfile
				# fish reports pipe errors on stderr
			end ^&1)

			test -z $error # is empty
			and mv --force $tempfile $datafile
			or rm --force $tempfile # also runs if the mv above fails

	end
end
