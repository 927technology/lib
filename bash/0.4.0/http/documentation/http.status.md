# **927 Technology - Bash Libraries**


### http.status

&nbsp;
#### Arguments
|Short|Long|Required|Data Type|Description
|:-|:-|:-|:-|:-
|-u|--url|yes|string|full url to a http(s) resource to query

&nbsp;
#### Source Command
> . ${_lib_root}/http/status.f

or

> source ${_lib_root}/http/status.f

&nbsp;
#### Example

> http.status --url https://www.google.com

Returns 
> {"url":"https://www.google.com","code":200,"name":"ok","description":"The request succeeded."}