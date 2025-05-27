function fish_prompt
  set -l last_status $status

  # Calculate status indicator
  set -l status_indicator ""
  if test $last_status -ne 0
    set status_indicator (set_color red)" ["$last_status"]"
  end

  set -l final_symbol "> "
  echo -n (set_color green)(prompt_pwd)$status_indicator" > "
end

