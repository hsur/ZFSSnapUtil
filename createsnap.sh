#!/usr/bin/bash
# vi: tabstop=2 shiftwidth=2 softtabstop=2 autoindent
# Copyright (c) 2017, hsur. All rights reserved.
# License: BSD-2-clause

SCRIPT_DIR=`dirname $0`
export SCRIPT_NAME=`basename $0 .sh`
cd $SCRIPT_DIR

LOCAL_TANK=tank

create_snap(){
	SNAPNAME=`date '+snap-%Y%m%d-%H%M%S'`
	zfs snapshot "$LOCAL_TANK/$1@$SNAPNAME"
}

main(){
	echo "===== START: $SCRIPT_NAME ====="

	create_snap hoge

	echo "===== END: $SCRIPT_NAME ====="
}

main 2>&1 | awk '{print strftime("%Y-%m-%d %T ") "[" PROCINFO["pid"] "] " $0; system("");}'
