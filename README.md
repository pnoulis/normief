# About normief

**normief** is a file normalization bash script.

The name expands to *normalize filename*.


## File naming conventions

Unix and Windows do not enforce filename syntax.

Meaning that a filename, in theory, may be composed of any symbol

available in the unicode symbol table.

However, there are conventions which are pretty much widely accepted

and followed.


### In unix

In Unix, it is adviced that filenames only stick to the following

symbols.


```shell

    [a-z] [A-Z] [0-9] . _

```


#### Strictly no spaces

Spaces in bash, and I believe, in most command languages are a token

separator. Meaning they denote the start of a new semantic unit. So

what was one filename, it is now 2. (time machine reference).


#### The underscore

The **underscore** is used as a semantic separator which is

a convention called **snake_case**.


#### The point

The **point** denotes the start of the filename **extension** or

**suffix**. An extension or suffix carries with it semantic

information about the contents of the file. In Unix it's usage is

completely optional, since programs ignore it when they determine the

content format. It is there mostly for people to quickly get an idea

of what is contained within.


#### ASCII

All the symbols listed above fall into the ASCII range of the unicode

symbol chart.


#### Prefer lowercase

It is much more preferable to stick to only lowercase. The user, does

not have to combine SHIFT + [a-z] to get the uppercase form, which

makes typing more enjoyable by reducing unnecessary finger movement.


### The hyphen

The hyphen, although not part of unix conventions, is widely used as a

semantic separator.

```shell

    -

```


### Semantic versioning

Semantic versioning appends the plus symbol to denote build metadata

of a package distribution.

```shell

    +

```


## Installation

```bash

    curl https://raw.githubusercontent.com/pnoulis/normief/master/normief.sh > ~/bin/normief
    chmod +x ~/bin/normief

```

## License

Distributed under the GPLv3 License. See `LICENSE` for more information.


## Contact

pavlos.noulis@gmail.com

project link - [normief](https://github.com/pnoulis/normief)
