# **927 Technology - Bash Libraries**

&nbsp;
### Files Extensions

|Ext|Description|
|:---|:-------------|
|.v|Variables defination.  These files define system variables.  variables/bools.v contains values for booleans, true/false for example.  &nbsp; variables/cmd/debain.v values for full path shell executables for debian.  cmd_echo=/usr/bin/echo would be called ${cmd_echo} from your script or function to reduce shell alias and function compromise|
|.f|Function defination.  Functions are code blocks to do repetative tasks.  Descriptions for each function are outlined in each function respectivly.
|.l|Library defination.  Library definations are groupings of related functions or variable declarations.  Library calls are dependant on a variable _lib_root set to the root of the library path e.g. _lib_root=/usr/local/lib/bash/0.4.0
