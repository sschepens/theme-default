# You can override some default options with config.fish:
#
#  set -g theme_short_path yes

function fish_prompt
  set -l last_command_status $status
  set -l cwd

  if test "$theme_short_path" = 'yes'
    set cwd (basename (prompt_pwd))
  else
    set cwd (prompt_pwd)
  end

  set -l fish     "⋊>"
  set -l ahead    "↑"
  set -l behind   "↓"
  set -l diverged "⇅"
  set -l dirty    "±"
  set -l none     "="
  set -l prompt_end "─╼"
  set -l no_upstream "⤉"

  set -l normal_color     (set_color normal)
  set -l success_color    (set_color $fish_pager_color_progress ^/dev/null; or set_color cyan)
  set -l error_color      (set_color $fish_color_error ^/dev/null; or set_color red --bold)
  set -l warning_color    (set_color $fish_color_quote ^/dev/null; or set_color brown)
  set -l directory_color  (set_color $fish_color_quote ^/dev/null; or set_color brown)
  set -l repository_color (set_color $fish_color_cwd ^/dev/null; or set_color green)

  if git_is_repo
    if test "$theme_short_path" = 'yes'
      set root_folder (command git rev-parse --show-toplevel ^/dev/null)
      set parent_root_folder (dirname $root_folder)
      set cwd (echo $PWD | sed -e "s|$parent_root_folder/||")
    end

    echo -n -s " " $directory_color $cwd $normal_color
    echo -n -s " on " $repository_color (git_branch_name) $normal_color " "

    if git_is_touched
      echo -n -s $error_color $dirty $normal_color
    else
      set -l git_status (git_ahead $ahead $behind $diverged $none)
      if test "$git_status" = ""
        echo -n -s $warning_color $no_upstream $normal_color
      else if test "$git_status" = "$none"
        echo -n -s $git_status
      else
        echo -n -s $warning_color $git_status $normal_color
      end
    end
  else
    echo -n -s " " $directory_color $cwd $normal_color
  end

  if test $last_command_status -eq 0
    echo -n -s " " $success_color $prompt_end $normal_color
  else
    echo -n -s " " $error_color $prompt_end $normal_color
  end

  echo -n -s " "
end
