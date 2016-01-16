
# -c command -a arguments
complete -c z  -a '(z --complete          -- (commandline --current-token) ^ /dev/null)' --no-files
complete -c zc -a '(z --complete --subdir -- (commandline --current-token) ^ /dev/null)' --no-files

# -d description -s short-option -l long-option
complete -c z -s a -l add     -d 'add directories to the z history file'    --require-parameter
complete -c z -s l -l list    -d 'list directories in the z history file'
complete -c z -s r -l rank    -d 'use the highest ranked directory'
complete -c z -s t -l recent  -d 'use the most recently accessed directory'
complete -c z -s c -l subdir  -d 'only match within the current directory'
complete -c z -s e -l regexp  -d 'use regular expression matching'
complete -c z -s x -l exclude -d 'remove the current directory from history'
complete -c z      -l clean   -d 'forget removed directories'

complete -c zc -s l -l list   -d 'list directories in the z history file'
complete -c zc -s r -l rank   -d 'use the highest ranked directory'
complete -c zc -s t -l recent -d 'use the most recently accessed directory'
complete -c zc -s e -l regexp -d 'use regular expression matching'

functions --query z.history_file
or begin
	function z.history_file --description "Print the name of the Z history file"
		set --query HOME
		and echo $HOME/.z
		or echo /tmp/.z
	end
end

function z.add_directory_to_history_on_pwd_change --on-variable PWD
	z --add $PWD
end

function zc --description "Alias to z --subdir"
	z --subdir $argv
end

function z --description "Jump to a recent directory"
	set --local datafile (z.history_file)
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
			case --exclude -x
				set command 'exclude'
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

	test $command != 'add'
	and test $regexp = 'false'
	and set argv (command awk --file $z_dir/escape.awk $argv)

	test $subdir = true
	and set argv $argv '^'(pwd)'/'

	switch $command
		case add
			test -e $datafile
			or command touch $datafile

			set tempfile (command mktemp $datafile.XXXXXX)
			and test -f $tempfile # is regular file
			or return 1

			command awk --file $z_dir/add.awk \
				--assign now=(date +%s) \
				--field-separator "|" \
				$datafile $argv > $tempfile
			and command mv --force $tempfile $datafile
			or command rm --force $tempfile # also runs if the mv above fails

		case complete
			test -f $datafile
			or return 0

			command awk \
				--file $z_dir/lib.awk \
				--file $z_dir/complete.awk \
				--field-separator "|" \
				$datafile $argv

		case list
			test -f $datafile
			or return 0

			command awk \
				--file $z_dir/lib.awk \
				--file $z_dir/list.awk \
				--assign now=(date +%s) \
				--assign type=$type \
				--field-separator "|" \
				$datafile $argv

		case cd
			test (count $argv) -eq 1 # When the single argument
			and test -d $argv[1]     # provided is a directory,
			and return (cd $argv[1]) # then "cd" directly into it.

			test -f $datafile
			or return 0

			set target (
				command awk \
					--file $z_dir/lib.awk \
					--file $z_dir/cd.awk \
					--assign now=(date +%s) \
					--assign type=$type \
					--field-separator "|" \
					$datafile (pwd) $argv)
			and begin
				if test -z $target # is empty
					echo "No match was found!"
					return 3
				else
					echo cd $target
					cd $target
				end
			end

		case clean exclude
			set tempfile (command mktemp $datafile.XXXXXX)
			and test -f $tempfile # is regular file
			or return 1

			set error (begin
				set --local IFS '|'
				while read --local directory rank timestamp
					test -d $directory
					or continue # because it's not a directory
					test $command = exclude
					and test $directory = (pwd)
					and continue # because it's PWD and -x is set
					echo "$directory|$rank|$timestamp"
				end < $datafile >> $tempfile
				# fish reports pipe errors on stderr
			end ^&1)

			test -z $error # is empty
			and command mv --force $tempfile $datafile
			or command rm --force $tempfile # also runs if the mv above fails

	end
end
