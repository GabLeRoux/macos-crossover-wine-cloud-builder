# MacOS CrossOver FOSS built from the Cloud

[![.github/workflows/build.yml](https://github.com/dasmy/macos-crossover-cloud-build/workflows/.github/workflows/build.yml/badge.svg)](https://github.com/dasmy/macos-crossover-cloud-build/actions)
[![.github/workflows/build_monolithic.yml](https://github.com/dasmy/macos-crossover-cloud-build/workflows/.github/workflows/build_monolithic.yml/badge.svg)](https://github.com/dasmy/macos-crossover-cloud-build/actions)

Let's build [FOSS CrossOver][foss-crossover] for macOS in the cloud! I found [some gists][crossover-gist] and I asked myself why don't we use the cloud and the free open source builders to build this? Here it is.

## How this works?

1. See [Github Actions](https://github.com/features/actions)
2. See [`.github/workflows/build.yml`](./.github/workflows/build.yml)
3. See [`build_local.sh`](./build_local.sh)

## Is it working?

Not for me, see [#6](https://github.com/GabLeRoux/macos-crossover-cloud-build/issues/6)

## Inspiration

I learned about [Free and Open Source Software Code for CrossOver][foss-crossover] and found [this gist][crossover-gist].

## Where to download builds?

See [#2](https://github.com/GabLeRoux/macos-crossover-cloud-build/issues/2)

## Can I run the build locally?

It will only work if you're on macOS, but yes.
Clone the project, read the scripts first, then feel free to run [`build_local.sh`](./build_local.sh) 👍.
The script is a copy of the steps done in the github action in [`.github/workflows/build.yml`](./.github/workflows/build.yml).
It contains some variables to allow for customizations.

This is an [MIT](LICENSE.md) repo. If you break something on your system doing so, it's your fault 😉

## Can I contribute?

Definitely. Feel free to send PRs 🚀

## License

[MIT](LICENSE.md) © [Gabriel Le Breton](https://gableroux.com)

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