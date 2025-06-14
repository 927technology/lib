# **927 Technology - Bash Libraries**

### standard

|Name|Input|Output|Description|
|:---|:-|:-|:-------------|
|[is_directory](./is_directory.f)|pipe|boolean|tests if piped string is a directory|
|[is_file](./is_file.f)|pipe|booean|tests if a piped string is a file|
|[is_integer](./is_integer.f)|pipe|boolean|tests if a piped string is a integer|
|[is_json](./is_json.f)|pipe|boolean|tests if a piped string is properly formatted json|
|[is_simlink](./is_simlink.f)|pipe|boolean|tests if a piped string is a simlink|
|[is_string](./is_string.f)|pipe|boolean|tests if a piped string is a string|
|[lcase](./lcase.f)|pipe|string|returns the upper case of the input string|
|[lcase](./lcase.f)|pipe|string|returns the lower case of the input string|

&nbsp;
#### Source Command
> . ${_lib_root}/standard.l

or

> source ${_lib_root}/standard.l