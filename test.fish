begin
	set -l IFS '|'
	while read directory rank timestamp
		echo "Creating directory $directory"
		mkdir -p $directory
	end < test.z.history
end

function test_z -d "Test which directory will be chosen"
	set -l description $argv[1]
	set -l patterns $argv[2..-1]
	echo
	echo ">>> $description - z [$patterns] >>>"
	cd /
	and z $patterns
	echo exit $status
	echo pwd (pwd)
	echo "--- cat ---"
	cat /tmp/.z | sort
	echo "<<< <<<"
end

function test_z_2 -d "Call 'test_z' with slashes around the pattern"
	set -l pattern $argv[1]
	set -l description $argv[2]
	test_z "$description - No slashes added" $pattern
	test_z "$description - Slash added before pattern" '/'$pattern
	test_z "$description - Slash added after pattern" $pattern'/'
	test_z "$description - Slashes added around pattern" '/'$pattern'/'
end

function test_z_add -d "Test directory history addition"
	set -l directory $argv[1]
	set -l description $argv[2]
	echo
	echo ">>> $description - z add [$directory] >>>"
	z --add $directory
	echo exit $status
	echo "--- cat ---"
	cat /tmp/.z | sort
	echo "<<< <<<"
end

function test_z_add_rm -d "Remove history and call test_z_add"
	rm -f /tmp/.z
	test_z_add $argv
end

function test_z_list -d "Test the list command"
	set -l description $argv[1]
	set -e argv[1]
	echo
	echo ">>> $description - z --list [$argv] >>>"
	echo "/tmp/z.test/will/be/removed|1|1234567890" >> /tmp/.z
	z --list $argv
	echo "--- cat ---"
	cat /tmp/.z | sort
	echo "<<< <<<"
end

function test_z_complete -d "Test the complete command"
	set -l description $argv[1]
	set -e argv[1]
	echo
	echo ">>> $description - z --complete [$argv] >>>"
	echo "/tmp/z.test/will/be/removed|1|1234567890" >> /tmp/.z
	z --complete $argv | sort
	echo "--- cat ---"
	cat /tmp/.z | sort
	echo "<<< <<<"
end

set --global --export HOME /tmp
set --global --export TESTDIR $PWD
rm -f /tmp/.z
rm -rf /tmp/.z.test

function date -d "Freeze time during testing"
	echo "1234567890"
end

functions -e awk

sed -Ee 's/\\scommand (awk|date)/\\1/g' z.fish > test.z.fish
source $TESTDIR/test.z.fish
functions --erase z.add_directory_to_history_on_pwd_change
function z.history_file; echo /tmp/.z; end

test_z_add_rm /try/not/to/crash "Add with no history file"
test_z_add_rm $HOME             "Should not add \$HOME"

cp test.z.history /tmp/.z

test_z_add $HOME                      "Should not add \$HOME"
test_z_add /tmp/z.test/does/not/exist "Add non-existing directory"
test_z_add /tmp/z.test                "Add existing directory"
test_z_add '"'                        "Add a double quote"
test_z_add '\\'                       "Add a backslash"

test_z_list "List all directories by frecent"
test_z_list "List all directories by rank"       -r
test_z_list "List all directories by timestamp"  -t

test_z_2 ef    "Matches middle of directory name"
test_z_2 fish  "Matches entire directory name"
test_z_2 tmp   "Matches existing directory"

test_z_complete "Complete with all directories on empty input"
test_z_complete "Complete with directories that match every pattern"   c f ns

begin # broken awk
	function awk; echo "stdout is ignored"; echo "awk error message" ^&2; return 1; end
	test_z "awk fails with exit code 1" fish
	functions -e awk
end

echo
echo ">>> z --clean >>>"
z --clean
cat /tmp/.z | sort
echo "<<< <<<"

rm $TESTDIR/test.z.fish
