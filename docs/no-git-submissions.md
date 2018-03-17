#### Contributing without knowing git

Contributing to the official Qubes OS [documentation](https://www.qubes-os.org/doc/) requires contributors to understand git concepts like forking a repository, submitting pull requests and keeping a forked repository synchronized with upstream. Some of those concepts are easy to master, others are more involved.

Qubes users who don't want to learn git for a reason or another - or who don't feel confident submitting a pull request (PR) - can simply create an issue in this github community page in the "Issues" tab above with any content they see fit: addition or improvements to documentation, suggestions, tips, typo fixes, one-liners, etc.
Please add the `doc-contrib` label/tag to your issue if you would like to submit this document.

After (optional) discussion in the issue's thread and if the content is deemed fit for submission (whether to this project's unoffical documentation repository or to Qubes' official qubes-doc repository) a community member will create a git pull request on your behalf and take care of anything "git", or alternatively he will guide you in creating your own PR - if you'd like to of course. Note however that in the former case you'll loose attribution/credit because github doesn't allow transferring a pull request's ownership.

#### Learning git for further contributions

It would of course ease the burden on community members if returning contributors learn the few basic git concepts required to submit pull requests themselves, but this is of course not a requirement.

The official Qubes OS documentation [contribution guidelines](https://www.qubes-os.org/doc/doc-guidelines/) is a good start. It is based on contributing to the official qubes-doc repository but is applicable to any other project.

However the guide doesn't approach the problem of keeping a forked repository synchronized with "upstream" (eg. the official repository). This isn't a trivial problem ([github help page]](https://help.github.com/articles/syncing-a-fork/)), especially when you have made changes in your forked repository ([stackoverflow post](https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository)). So until you are proficient enough to understand the steps involved, a simple alternative that does not require command line usage is to delete the forked repository and re-fork it from upstream. This is a bit of a "nuclear" option though and you'll obviously loose any changes you've made in your forked repository.
