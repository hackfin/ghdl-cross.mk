#!/bin/bash
#
# Guess right config from host files and identity

HOST_ISSUE=`cat /etc/issue`
MACHINE=`uname -m`


case "$HOST_ISSUE" in
	Debian\ GNU/Linux\ 9*)
		OS=debian9
	;;
	Linux\ Mint\ 17.1*)
		OS=mint17_rebecca
	;;
	Linux\ Mint\ 18.3*)
		OS=mint18_sylvia
	;;
	*) >&2 echo "$0: Unknown setup '$HOST_ISSUE'"
	echo unknown
	exit 1
	;;
esac

echo ${OS}:${MACHINE}

