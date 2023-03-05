# Framework X website

[![CI status](https://github.com/clue/framework-x-website/actions/workflows/ci.yml/badge.svg)](https://github.com/clue/framework-x-website/actions)
[![Last deployed on `live`](https://img.shields.io/github/last-commit/clue/framework-x-website/live?label=last%20deployed&logo=github)](https://github.com/clue/framework-x-website/tree/live)

Source code for the https://framework-x.org/ website.

## Contribute

You want to contribute to our Framework X website? You've come to the right place!
This repository contains everything you need to help out with the texts and
code examples found on the [landing page of the website](https://framework-x.org/).
Just locate the `public/index.html` and there you will find all contents.

> ℹ️ This repository contains all files and build scripts required to generate the
> entire website. If you want to contribute to the [Framework X documentation](https://framework-x.org/docs/),
> take a look at [clue/framework-x](https://github.com/clue/framework-x).

## Build

You can build the website like this:

```bash
make
```

If you've pulled Framework X before and want to update its source code, you can
rebuild the website after pulling an up-to-date version like this:

```bash
make pull
```

Once built, you can manually browse the `build/` directory or run the web server
container (Apache) in the foreground like this:

```bash
make serve
```

Alternatively, you may also run the web server container (Apache) as a
background daemon like this:

```bash
make served
```

Once running, you can run some integration tests that check correct paths etc.
like this:

```bash
make test
```

Once done, you can clean up like this:

```bash
$ make clean
```

## Deploy

Once built (see previous "Build" section), you can simply deploy the `build/`
directory behind Apache.

The live website is deployed by pushing the contents of the `build/` directory to
the `live` branch like this:

```bash
make deploy
```

As a prerequisite, this should be deployed behind a CDN (Bunny CDN) that is
responsible for HTTPS certificate handling and forcing HTTPS redirects. This CDN
needs to be configured to pass the `X-Forwarded-Scheme` and `X-Forwarded-Host` HTTP
request headers to avoid exposing the origin URL in any HTTP redirects.

## Continuous Deployment

We use continuous deployment to keep this website up to date. Any time a commit
is pushed (such as when a PR is merged), GitHub actions will automatically build
and deploy the website. This is done by running the above deployment script (see
previous chapter).

Additionally, the same deployment is triggered whenever a commit is pushed in
[clue/framework-x](https://github.com/clue/framework-x). This ensures the
website is automatically rebuilt whenever documentation changes have been merged.
