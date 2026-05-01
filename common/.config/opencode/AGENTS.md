# Agent Instructions
## Running servers
NEVER run long running blocking servers like `bundle exec rails s` or `python manage.py runserver` or `cargo run` when the binary is a web server.
Always ask the user to run those servers for you instead if you need to use them to verify things.
