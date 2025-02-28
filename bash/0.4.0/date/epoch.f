# 20241116
#version=0.0.4

function date.epoch {
	# accepts no args.  returns date in number of seconds since January 1, 1970
	${cmd_date} +'%s'
}