### Contributing

Anyone is welcome to submit content they deem fit for inclusion in this community effort (or potentially in the [official Qubes documentation](https://www.qubes-os.org/doc/)): addition or improvements to documentation, suggestions, tips, typo fixes, one-liners, code/scripts, link to third-party resources, ...

Contributing content is done with [pull requests](https://help.github.com/articles/about-pull-requests).

While submitting pull requests is a relatively easy process (see ["learning git"](#learning-git) below), one goal of this project is to make it easy for *anyone* to submit content. So contributors who are not familiar with git can simply open an issue in the qubes-community repository (if you're viewing this page on github, click the "Issues" tab above and then "New issue"). After (optional) discussion in the issue's thread and if the content is deemed fit for submission a community member will create a pull request on your behalf and take care of everything "git"; alternatively - if you prefer - he/she will help you creating your own pull request. Note however that in the former case you'll loose attribution/credit because github doesn't allow transferring a pull request's ownership.

### Repositories

There are basically two main repositories in this project:

- qubes-community: contains unofficial (or staging) documentation + projects and links related to Qubes OS.
- qubes-doc-community-fork: a fork of the official Qubes OS documentation [repository](https://github.com/QubesOS/qubes-doc), to make it easy to submit pull request against official Qubes documents. This repository is synchronized with upstream automatically.

### Licensing

GPL is required for any documentation content. Otherwise you're free to use whatever license you see fit when submitting code/programs, provided it fits in the git/fork model. If you don't specify a license, it is assumed to be GPL.

<a name="learning-git"></a>
#### Learning git for further contributions

It would ease the burden on community members if returning contributors learn the few basic git concepts required to submit pull requests themselves.

The official Qubes OS documentation [contribution guidelines](https://www.qubes-os.org/doc/doc-guidelines/) is a good start. It is based on contributing to the official qubes-doc repository but is applicable to any other project.

However the guide doesn't approach the problem of keeping a forked repository synchronized with "upstream" (eg. the official repository). This isn't a trivial problem ([github help page](https://help.github.com/articles/syncing-a-fork/)), especially when you have made changes in your forked repository ([stackoverflow post](https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository)). So until you are proficient enough to understand the steps involved, a simple alternative that does not require command line usage is to delete the forked repository and re-fork it from upstream. This is a bit of a "nuclear" option though and you'll obviously loose any changes you've made in your forked repository.
