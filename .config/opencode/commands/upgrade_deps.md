---
description: Upgrade dependencies in this project to their latest version
---

I want you to upgrade all dependencies of this project to their latest versions.
This includes the runtime/language version of the project if the language version
is actually defined locally via some version manager config i.e. mise, asdf etc...

Start by identifying what tools are used to manage the dependencies.
Then see if there is a way via native package tooling to search for
the most recent version of any dependencies we may have. Then bump
those dependencies to the latest version.

Only do this for actual direct dependencies. Do not worry about
sub dependencies that we haven't explicitly defined as a project
dependency.

When you are done upgrading run any testing/verfication sutie
you can find for the project.

