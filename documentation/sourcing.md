# **927 Technology - Bash Libraries**

&nbsp;
### Using the Libraries
---
There is an environmental variable that all the libraries follow to find the library root, ${_lib_root}.  Set this variable at the top of your script.  Include the library name, bash, and the intended version.  Setting a full path is best, but relative paths are also honored.

> _lib_root=/usr/local/lib/bash/0.4.0

or

> _lib_root=../lib/bash/0.4.0

&nbsp;
### Source the libraries into your script
---

Sourcing libraries into your scripts will reduce time coding and troubleshooting by utilizing tested functions.

To source file into your script use the source command or .
> . ${_lib_root}/date/year.f

or 

> source ${_lib_root}/date/year.f

You may source in individual functions or complete libraries of function with a single source.
> . ${_lib_root}/date.l

or 

> source ${_lib_root}/date.l


All functions in this library require sourcing variables/bools.v, variables/exits.v and a command library in variables/cmd/\<distro\>.v.  

Sourcing variables.l will suffice this requirement.
> . ${_lib_root}/variables.l

or

> source ${_lib_root}/variables.l



&nbsp;
### Example: Add the libraries to your script
---

Assume your library is in /var/local/lib and you are using version bash/0.4.0

```
#!/bin/bash

# set you version for easy editing
_lib_version=0.4.0

# set your _lib_root path
_lib_root=/usr/local/lib/bash/${_lib_vesion}

# source in required library of variables.l which contains
# variables/bools.v and variables/exits.v.  it will also 
# attempt to determine your OS release and source 
# the proper cmd library.
. ${_lib_root}/variables.l


# source in a specific funciton
. ${_lib_root}/date/year.f  # function that outputs they 4 digit year 

# source in a library of functions
. ${_lib_root}/date.l       # library that includes the year function plus more


# main
# call your function
date.year

```
Output
> 2025