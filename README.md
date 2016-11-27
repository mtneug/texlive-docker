# mtneug/texlive

[![Build Status](https://travis-ci.org/mtneug/texlive-docker.svg?branch=master)](https://travis-ci.org/mtneug/texlive-docker) [![](https://images.microbadger.com/badges/version/mtneug/texlive.svg)](https://hub.docker.com/r/mtneug/texlive/) [![](https://images.microbadger.com/badges/image/mtneug/texlive.svg)](https://microbadger.com/images/mtneug/texlive)

Build LaTeX documents in Docker containers. This

## Usage

This image assumes that you mount your files at `/doc`. By default it will
compile the file called `main.tex`. You can change that by passing some flags:

```
Usage: build.sh [OPTIONS]

Options:

  -f, --file [FILE]     Name of the tex file without file ending (default: 'main')
  -b, --bibtex          Run bibtex
  -g, --glossaries      Run makeglossaries
  -w, --watch           Watch for changes
      --ignore-errors   Continue watching even if an error occurred
  -h, --help            Print usage
```

This image also has a watch mode, where it will run a build on every file
change. Assuming you are in your project directory, you might run the following
command:

```sh
$ docker run --rm -v $PWD:/doc mtneug/texlive -b -g -w --ignore-errors
```

## License

```
Copyright 2016 Matthias Neugebauer All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
