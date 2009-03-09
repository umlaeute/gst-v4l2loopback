#
# Regular cron jobs for the v4lsink package
#
0 4	* * *	root	[ -x /usr/bin/v4lsink_maintenance ] && /usr/bin/v4lsink_maintenance
