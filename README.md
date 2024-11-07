# **Bash Libraries**

### Functions for Bash to make coding easier

Source the files into your scripts to reduce time coding and troubleshooting by utilizing tested functions.

To sourcea file into your script use the source command or .
>. ./lib/date.f

or 

>source ./lib/date.f

&nbsp;

All functions in this library require sourcing bools.v and cmd.v.  These are not expressly defined as dependancies when source individually.

&nbsp;

---

### Files Extensions
|Ext|Description|
|:---|:-------------|
|.v|Variables defination.  These files define system variables.  bools.v contains values for true/false for example.  cmd.v values for shell pathed executables.  cmd_echo=/usr/bin/echo would be called ${cmd_echo} from your script or function to reduce shell alias compromise|
|.f|Function defination.  Functions are code blocks to do repetative tasks.  Descriptions for each function are outlined in each function respectivly.
|.l|Library defination.  Library definations are groupings of related functions or variable declarations.  Library calls are dependant on a variable _lib_root set to the root of the library path e.g. _lib_root=/usr/local/lib/bash/0.4.0

&nbsp;

---

### Add Libraries to your project

```
cd <library parent path>
git submodule add https://github.com/927technology/lib.git
```


### Update Libraries in your project
```
cd <git repo>
git submodule update --remote
