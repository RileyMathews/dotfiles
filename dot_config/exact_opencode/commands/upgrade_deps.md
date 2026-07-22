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

Only focus on updating direct dependencies to their latest version.
Do a pass that attempts to update transitive dependencies as well
if that isn't already automatic in whatever package manager we are
using. But don't focus on updating every sub dependency to its
most fresh version.

When you are done upgrading run any testing/verfication sutie
you can find for the project.

