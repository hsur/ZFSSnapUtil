#!/usr/bin/bash
# vi: tabstop=2 shiftwidth=2 softtabstop=2 autoindent
# Copyright (c) 2017, hsur. All rights reserved.
# License: BSD-2-clause

SCRIPT_DIR=`dirname $0`
export SCRIPT_NAME=`basename $0 .sh`
cd $SCRIPT_DIR

SNAPCOUNT=10
LOCAL_TANK=tank

snap_delete(){
	zfs list -t snapshot -r $LOCAL_TANK/$1 | grep '@' | awk '{print $1}' | sort -r | tail +$SNAPCOUNT | while read sn ; do
		echo "[INFO] deleting snapshot. : $sn"
		zfs destroy "$sn"
	done
}

main(){
	echo "===== START: $SCRIPT_NAME ====="

	snap_delete hoge

	echo "===== END: $SCRIPT_NAME ====="
}

main 2>&1 | awk '{print strftime("%Y-%m-%d %T ") "[" PROCINFO["pid"] "] " $0; system("");}'
