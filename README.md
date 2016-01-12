# Z

Maintains a jump-list of the directories you actually use.

The original version of this program can be found at [github.com/rupa/z](https://github.com/rupa/z). The first version supporting Fish seems to be [github.com/sjl/z-fish](https://github.com/sjl/z-fish). I learned about `--on-variable PWD` from the version at [github.com/roryokane/z-fish](https://github.com/roryokane/z-fish/blob/master/z.fish). [Fish repository ticket](https://github.com/fish-shell/fish-shell/issues/981) asking about a Z equivalent for fish.

# Install

Clone this repository somewhere permanent, and then run the following command:
```
make install
```
To learn about what it will do, read the file _install.fish_.

If you move the directory where this repository was cloned, then you must run the installer again.

# Use

It's the same as all the other _Z_ s you already know, except that the _awk_ code in this version is much easier to read.

* `z foo` goes to the most _frecent_ directory matching `foo`.
* `z foo bar` goes to the most _frecent_ directory matching `foo` and `bar`.
* `z -r foo` goes to the highest ranked directory matching `foo`.
* `z -t foo` goes to the most recently accessed directory matching `foo`.
* `z -l foo` list all the directories matching `foo`, ordered by _frecency_.
