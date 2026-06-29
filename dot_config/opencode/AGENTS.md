# Agent Instructions
## Running servers
Never run blocking servers directly via the shell tool. I almost always run opencode inside a tmux session so feel free to query the local
tmux environment and spawn new windows for running long running things like servers and managing their lifecycle that way.
Things like `bundle exec rails s`. `python manage.py runserver` `ghciwatch` etc... should all be run this way. Never run them
via the direct shell tool as that would block your chat session.

# Making posts to services
Anytime I ask you to make a post or comment to a platform such as github, linear, etc... Always put at the top of the post or comment that the comment was generated via opencode so that it is clear that it was
AI generated even though it will be using my identity profile.
