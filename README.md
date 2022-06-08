# MacOS CrossOver FOSS built from the Cloud

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->


[![.github/workflows/build_monolithic.yml](https://github.com/GabLeRoux/macos-crossover-cloud-build/workflows/Wine-Crossover-MacOS/badge.svg)](https://github.com/GabLeRoux/macos-crossover-cloud-build/actions)
[![.github/workflows/build_monolithic.yml](https://github.com/GabLeRoux/macos-crossover-cloud-build/workflows/Wine-Crossover-MacOS-local/badge.svg)](https://github.com/GabLeRoux/macos-crossover-cloud-build/actions)

Let's build [FOSS CrossOver][foss-crossover] for macOS in the cloud! I found [some gists][crossover-gist] and I asked myself why don't we use the cloud and the free open source builders to build this? Here it is.

## How this works?

1. See [Github Actions](https://github.com/features/actions)
2. See [`.github/workflows/build_monolithic.yml`](./.github/workflows/build_monolithic.yml)
3. See [`build_local.sh`](./build_local.sh)

## Is it working?

In principle yes, see the following image which is `notepad.exe` running inside wine on a macOS 10.15 machine:
![Notepad running in wine](doc/wine64_notepad.png)

## Inspiration

I learned about [Free and Open Source Software Code for CrossOver][foss-crossover] and found [this gist][crossover-gist].

## Where to download builds? How can I run them?

Builds are currently available as artifacts from github actions.
Simply go to [the Actions tab](https://github.com/GabLeRoux/macos-crossover-wine-cloud-builder/actions), click the newest green run from the main branch, scroll down to the artifacts and select the version of your choice.
See however also [#25](https://github.com/GabLeRoux/macos-crossover-cloud-build/issues/25).

After downloading and unpacking the tarball, e. g. to the `./wine-cx` folder, you need to remove the quarantine attribute using `sudo xattr -r -d com.apple.quarantine wine-cx`.
Afterwards inside `./wine-cx/usr/local/bin` you will find the `wine32on64` and `wine64` binaries.

## Can I run the build locally?

It will only work if you're on macOS, but yes.
Clone the project, read the scripts first, then feel free to run [`build_local.command`](./build_local.command) 👍.
The script is a copy of the steps done in the github action in [`.github/workflows/build_monolithic.yml`](./.github/workflows/build_monolithic.yml).
It contains some variables to allow for customizations.

We try to keep [`build_local.sh`](./build_local.sh) synchronized with the action, but sometimes might miss a step.
In case of issues with the local build compare the script to the steps in [`.github/workflows/build_monolithic.yml`](./.github/workflows/build_monolithic.yml) and possibly open an issue.

Note, that this is an [MIT](LICENSE.md) repo. If you break something on your system doing so, it's your fault 😉

## Can I contribute?

Definitely. Feel free to send PRs 🚀

## References / Links / Possibly helpful resources
See  for some technical details.
* [Starting point for this][crossover-gist].
* [Free and Open Source Software Code for CrossOver][foss-crossover]
* [How to compile codeweavers crossover from source][alex4386]
* [Some technical details][mails-dec2019]
* [How to install/about wine on mac][wine-on-mac]
* [Winehq style macOS Builds][winehq-style]
* [Detailed build script form phoenics][phoenics-winebuild]

[crossover-gist]: https://gist.github.com/sarimarton/471e9ff8046cc746f6ecb8340f942647
[foss-crossover]: https://www.codeweavers.com/crossover/source
[alex4386]: https://gist.github.com/Alex4386/4cce275760367e9f5e90e2553d655309
[mails-dec2019]: https://www.winehq.org/pipermail/wine-devel/2019-December/156602.html
[wine-on-mac]: https://github.com/Gcenx/wine-on-mac
[winehq-style]: https://github.com/Gcenx/macOS_Wine_builds
[phoenics-winebuild]: https://github.com/PhoenicisOrg/phoenicis-winebuild/blob/cf86dd3c98ba0b8fdbd5f9fc02bc5a4c15587ee9/builders/scripts/builder_darwin_x86on64_wine#L42-L46

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://gableroux.com"><img src="https://avatars.githubusercontent.com/u/1264761?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gabriel Le Breton</b></sub></a><br /><a href="https://github.com/GabLeRoux/macos-crossover-cloud-build/commits?author=GabLeRoux" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/dasmy"><img src="https://avatars.githubusercontent.com/u/5322274?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mathias</b></sub></a><br /><a href="https://github.com/GabLeRoux/macos-crossover-cloud-build/commits?author=dasmy" title="Code">💻</a></td>
        <td align="center"><a href="https://github.com/Gcenx"><img src="https://avatars.githubusercontent.com/u/38226388?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gcenx</b></sub></a><br /><a href="https://github.com/GabLeRoux/macos-crossover-cloud-build/commits?author=Gcenx" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

[MIT](LICENSE.md) © [Gabriel Le Breton](https://gableroux.com)
