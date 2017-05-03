#!/usr/bin/bash
# vi: tabstop=2 shiftwidth=2 softtabstop=2 autoindent
# Copyright (c) 2017, hsur. All rights reserved.
# License: BSD-2-clause

SCRIPT_DIR=`dirname $0`
export SCRIPT_NAME=`basename $0 .sh`
cd $SCRIPT_DIR

REMOTE_HOST="root@remotehost"
REMOTE_TANK=tank
LOCAL_TANK=tank

SSH="timeout -s 9 6h ssh -n $REMOTE_HOST "

get_remote_snap(){
	$SSH zfs list -t snapshot -r $REMOTE_TANK/$1 | grep '@' | awk '{print $1}' | cut -d@ -f2 | sort
}
get_local_snap(){
	zfs list -t snapshot -r $LOCAL_TANK/$1 | grep '@' | awk '{print $1}' | cut -d@ -f2 | sort
}

incl_snap_recv(){
	# seach common snapshot
	COMMON_SNAP=`join <( get_remote_snap $1 ) <( get_local_snap $1 ) | sort -r | head -n 1`
	if [ -z $COMMON_SNAP ] ; then
		echo "[WARN] No common snapshot found : $1"
		diff -u <( get_remote_snap $1 ) <( get_local_snap $1 )
		return 1
	else
		echo "[INFO] Common snapshot found : $COMMON_SNAP"
	fi

	# get latest snapshot from remote
	#LATEST_SNAP=`get_remote_snap $1 | tail -n 2 | head -n 1`
	LATEST_SNAP=`get_remote_snap $1 | sort -r | head -n 1`
	if [ "$COMMON_SNAP" = "$LATEST_SNAP" ] ; then
		echo "[INFO] Local volume is up-to-date"
		return 0
	fi

	# transer snapshot
	echo "[INFO] Starting INCREMENTAL snapshot transfer: $COMMON_SNAP -> $LATEST_SNAP"
	$SSH zfs send -i "$REMOTE_TANK/$1@$COMMON_SNAP" "$REMOTE_TANK/$1@$LATEST_SNAP" | zfs recv -vF "$LOCAL_TANK/$1"
}

main(){
	echo "===== START: $SCRIPT_NAME ====="

	incl_snap_recv hoge

	echo "===== END: $SCRIPT_NAME ====="
}

main 2>&1 | awk '{print strftime("%Y-%m-%d %T ") "[" PROCINFO["pid"] "] " $0; system("");}'
