# Framework X website

Source code for the Framework X website.

## Build

You can build the website like this:

```bash
$ make
```

> Note that this command will clone Framework X which is currently in early access.
  See https://github.com/clue/framework-x for more details.

Once built, you can manually browse the `build/` directory or run the development
web server like this:

```bash
$ make serve
```

Once built, you can clean up like this:

```bash
$ make clean
```

## Deploy

Once built (see previous "Build" section), you can simply deploy the `build/`
directory behind a web server of choice.

The live website is deployed by pushing the contents of the `build/` directory to
the `live` branch like this:

```bash
$ make deploy
```
