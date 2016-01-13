
complete --command z --no-files --arguments '(z --complete (commandline --current-token))'
complete --command z --short-option a --long-option add --require-parameter --description 'add directories to the z history file'
complete --command z --short-option l --long-option list --description 'list directories in the z history file'
complete --command z --short-option r --long-option rank --description 'use the highest ranked directory'
complete --command z --short-option t --long-option recent --description 'use the most recently accessed directory'

function add_directory_to_z_history_on_pwd_change --on-variable PWD
	z --add $PWD
end

function z --description "Jump to a recent directory"
	set --local datafile "$HOME/.z"
	set --local type 'frecent'
	set --local tempfile
	set --local target
	set --local command cd

	# Parse all the command line arguments before starting the program.
	# Note: The "break" calls inside the switch will exit the while loop,
	#       not the switch! "break" works for loops only, as documented.
	while test (count $argv) -ge 1
		switch $argv[1]
			case --add -a
				set command 'add'
			case --complete -c
				set command 'complete'
			case --list -l
				set command 'list'
			case --rank -r
				set type "rank"
			case --recent -t
				set type "recent"
			case --
				set -e argv[1]
				break
			case '*'
				break
		end
		set -e argv[1]
	end

	test $command = cd
	and test (count $argv) -eq 0
	and set command list

	set z_dir (dirname (status --current-filename))

	switch $command
		case add
			test -e $datafile
			or touch $datafile

			for directory in $argv
				test $directory != $HOME
				or continue # no need, ~ is shorter

				set tempfile (mktemp $datafile.XXXXXX)
				test -f $tempfile         # regular file,
				and chmod u=rw $tempfile  # readable only by the user,
				and not test -s $tempfile # empty.
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

			set tempfile (mktemp $datafile.XXXXXX)
			test -f $tempfile         # regular file,
			and chmod u=rw $tempfile  # readable only by the user,
			and not test -s $tempfile # empty.
			or return 1

			awk \
				--file $z_dir/lib.awk \
				--file $z_dir/list.awk \
				--assign now=(date +%s) \
				--assign type=$type \
				--assign q="$argv" \
				--assign tempfile=$tempfile \
				--field-separator "|" \
				$datafile
			and mv --force $tempfile $datafile
			or rm --force $tempfile # also runs if the mv above fails

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
	end
end
