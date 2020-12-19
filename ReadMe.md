# MacOS CrossOver FOSS built from the Cloud

I found some gists explaining how to build CrossOver on MacOS in some gists. I asked myself why don't we use the cloud and open source to build this? Here it is.

## Where to download builds

There is probably something tricky in providing the builds. I'm not sure if it can be distributed freely. If you know the answer, let me know. One might use these build scripts, connect through ssh using CircleCI using [Debugging with SSH
- CircleCI](https://circleci.com/docs/2.0/ssh-access-jobs/)

## How this works?

1. See [Hello World On MacOS - CircleCI](https://circleci.com/docs/2.0/hello-world-macos/)
2. See [`.circleci/config.yml`](./.circleci/config.yml)
3. See [`build.sh`](./build.sh)

## Inspiration

I leanred about [Free and Open Source Software Code for CrossOver](https://www.codeweavers.com/crossover/source) and found [this gist](https://gist.github.com/sarimarton/471e9ff8046cc746f6ecb8340f942647)

## License

[MIT](LICENSE.md) © [Gabriel Le Breton](https://gableroux.com)
