# Z

Maintains a jump-list of the directories you actually use.

The original version of this program can be found at [github.com/rupa/z](https://github.com/rupa/z).
The first version supporting Fish seems to be [github.com/sjl/z-fish](https://github.com/sjl/z-fish).
I learned about `--on-variable PWD` from the version at [github.com/roryokane/z-fish](https://github.com/roryokane/z-fish/blob/master/z.fish).
[Fish repository ticket](https://github.com/fish-shell/fish-shell/issues/981) asking about a _z_ equivalent for fish.

# Install

Clone this repository somewhere permanent, and then run the `make install` command.
For example, to install in your home folder, run the following commands:
```
git clone git@github.com:andre-luiz-dos-santos/z.git ~/.z.repo
cd ~/.z.repo
make install
```
To learn about how the installer works, read the file _install.fish_.

If the directory where this repository was cloned into is moved, the installer will have to be run again.
It will then automatically overwrite the previous configuration.

# Use

It's the same as all the other _z_'s you already know, except that the _awk_ code in this version is much easier to tune to your wishes (although I might be somewhat biased on that assessment :smile:).
The shell doesn't have to be reloaded when editing the _awk_ files.

[The original _z_ website](https://github.com/rupa/z) has information about _frecency_, _rank_, _time_, and how it's all calculated.
Basically, _rank_ indicates how frequently a directory is used, _time_ is when the directory was last used, and _frecent_ takes both values into account.
Wikipedia also has an article describing [frecency](https://en.wikipedia.org/wiki/Frecency).

## Examples

* `z foo` goes to the most _frecent_ directory matching `foo`.
* `z foo bar` goes to the most _frecent_ directory matching `foo` and `bar`.
* `z -r foo` goes to the highest ranked directory matching `foo`.
* `z -t foo` goes to the most recently accessed directory matching `foo`.

## Options

* `-r/--rank` order directories based on their rank only.
* `-t/--recent` order directories based on when they were last accessed.

If `--rank` and `--recent` are not set, then directories are ordered based on their [frecency](https://en.wikipedia.org/wiki/Frecency).

* `-l/--list` shows all directories matching the selected criteria. The last directory shown is the one that would be entered had `--list` not been set.
* `-c/--subdir` forces _z_ to only look for subdirectories of the current directory, by adding the pattern `^PWD`.
* `-e/--regexp` enables _awk_ to use all patterns as regular expressions.
* `-x/--exclude` removes the current directory from the history.
* `--clean` removes all directories that no longer exist in the filesystem from the history.
