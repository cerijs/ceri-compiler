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

## Features of template Strings
### Version 1

```js
// syntax
// template(version:Number or String, template: String)
template = template(1,"<div></div>")

// output
template = function(){return [this.el("div",{},[])]}

// using consolidate.js
template = template("pug.1","div")
```

```html
<div class=someClass></div> <!-- simple attribute -->
<!-- directives -->
<div :class=nameOfVar></div> <!-- bind local scope variable to attribute -->
<div @click=nameOfFunction></div> <!-- bind local scope function to event -->
<div :click.toggle=nameOfVar></div> <!-- set modifier to binding -->
<div> <!-- use elemental directives to pass further options -->
  <@click=nameOfVar toggle>
</div> 

<div :class.expr=@nameOfVar></div> <!-- create a inline expression '@' is short for 'this.' -->

<div><slot></slot></div> <!-- define a slot -->
<div>Hello {{@greeted}}</div> <!-- create a inline expression -->
```

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
