# Set window root path. Default is `$session_root`.
# Must be called before `new_window`.
#window_root "~/Projects/django"

# Create new window. If no argument is given, window name will be based on
# layout file name.
new_window "django"
run_cmd "psh"
run_cmd "nvim ."

split_v 20

run_cmd "psh"
run_cmd "./manage.py runserver"

split_h 50
run_cmd "psh"

select_pane 0

# Split window into panes.
#split_v 20
#split_h 50

# Run commands.
#run_cmd "top"     # runs in active pane
#run_cmd "date" 1  # runs in pane 1

# Paste text
#send_keys "top"    # paste into active pane
#send_keys "date" 1 # paste into pane 1

# Set active pane.
#select_pane 0
