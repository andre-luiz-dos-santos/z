
set --local cf ~/.config/fish/config.fish
set --local script '/### Z ###/,/### Z ###/d'

mkdir --parents (dirname $cf)
and touch $cf
and sed --in-place=.z_backup --expression=$script $cf
or exit

begin
  echo '### Z ###'
  echo '### https://github.com/andre-luiz-dos-santos/z'
  echo 'if status --is-interactive'
  echo '  source '(dirname (status --current-filename))'/z.fish'
  echo 'end'
  echo '### Z ###'
end >> $cf
