# ceri-compiler

compiles template strings for ceriJS

## Install
```sh
npm install --save-dev ceri-compiler
```

## Usage

```
Usage: ceri-compiler [options] <file ...>

  Options:

    -h, --help          output usage information
    -V, --version       output the version number
    -o, --out [folder]  out
    -b, --bundle        make a bundle
    -w, --webpack       webpack config to use for bundle creation
    -v [version]        (required) compiler version to use

```

## Example

```sh
ceri-compiler -b someComp.js
```

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
