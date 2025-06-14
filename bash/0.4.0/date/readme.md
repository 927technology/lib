# **927 Technology - Bash Libraries**

### date

|Name|Input|Output|Description|
|:---|:-|:-|:-------------|
|[date.day_of_week](./day_of_week.f)|none|integer|digit of the current day of the week 0 = Sunday, 7 = Saturday|
|[date.day](./day.f)|none|integer|2 digit day of the month|
|[date.epoch](./epoch.f)|none|integer|unix time, number of seconds since 1 January 1970|
|[date.month](./month.f)|none|integer|2 digit month of the year|
|[date.pretty](./pretty.f)|none|string|formatted datetime string without spaces|
|[date.week](./week.f)|none|integer|2 digit week of the year|
|[date.year](./year.f)|none|integer|4 digit year|

&nbsp;
#### Source Command
> . ${_lib_root}/date.l

or

> source ${_lib_root}/date.l