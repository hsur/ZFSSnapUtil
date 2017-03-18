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

full_recv_snap(){
	# get latest snapshot from remote
	#LATEST_SNAP=`get_remote_snap $1 | sort | tail -n 2 | head -n 1`
	LATEST_SNAP=`get_remote_snap $1 | sort | head -n 1`
	
	# transer snapshot
	echo "[INFO] Starting FULL snapshot transfer: $LATEST_SNAP"
	$SSH zfs send "$REMOTE_TANK/$1@$LATEST_SNAP" | zfs recv -vF "$LOCAL_TANK/$1"
}

main(){
	  echo "===== START: $SCRIPT_NAME ====="

	  full_snap_recv hoge

	  echo "===== END: $SCRIPT_NAME ====="
}

main 2>&1 | awk '{print strftime("%Y-%m-%d %T ") "[" PROCINFO["pid"] "] " $0; system("");}'
