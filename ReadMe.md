# MacOS CrossOver FOSS built from the Cloud

[![Build Status](https://travis-ci.com/GabLeRoux/macos-crossover-cloud-build.svg?branch=main)](https://travis-ci.com/GabLeRoux/macos-crossover-cloud-build)

I found some gists explaining how to build CrossOver on MacOS in some gists. I asked myself why don't we use the cloud and open source to build this? Here it is.

## How this works?

1. See [Travis - The macOS Build Environment](https://docs.travis-ci.com/user/reference/osx/)
2. See [`.travis.yml`](./travis.yml)
3. See [`build.sh`](./build.sh)

## Inspiration

I leanred about [Free and Open Source Software Code for CrossOver](https://www.codeweavers.com/crossover/source) and found [this gist](https://gist.github.com/sarimarton/471e9ff8046cc746f6ecb8340f942647)

## Why is the build failing on travis?

See https://github.com/GabLeRoux/macos-crossover-cloud-build/issues/1

## Where to download builds?

See https://github.com/GabLeRoux/macos-crossover-cloud-build/issues/2

## Can I run `./build.sh` locally?

It will only work if you're on MacOS, but yes. Clone the project, read the script first, then feel free to do it 👍. This is an [MIT](LICENSE.md) repo. If you break something on your system doing so, it's your fault 😉

## License

[MIT](LICENSE.md) © [Gabriel Le Breton](https://gableroux.com)
