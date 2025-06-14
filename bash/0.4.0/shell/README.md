# **927 Technology - Bash Libraries**

### shell

|Name|Input|Output|Description|
|:---|:-|:-|:-------------|
|[shell.get_version](./get_version.f)|none|json|determines the running shell based on the ${SHELL} variable|
|[shell.is_bash](./is_bash.f)|none|boolean|tests the current shell is bash|
|shell.lcase|none|none|depricated to standard/lcase|
|shell.ucase|none|none|deprcated to standard/ucase|

&nbsp;
#### Source Command
> . ${_lib_root}/shell.l

or

> source ${_lib_root}/shell.l