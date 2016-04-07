#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2002-2016, OpenNebula Project, OpenNebula Systems                #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

#-------------------------------------------------------------------------------
# Install program for the Xen hypervisor for OpenNebula.
# $ONE_LOCATION if defined with the -d option, otherwise it'll be installed
# under /. In this case you may specified the oneadmin user/group, so you do
# not need run the OpenNebula daemon with root privileges
#-------------------------------------------------------------------------------

ARGS=$*

usage() {
 echo
 echo "Usage: install.sh [-u install_user] [-g install_group]"
 echo "                  [-d ONE_LOCATION] [-l] [-h]"
 echo
 echo "-d: target installation directory, if not defined it'd be root. Must be"
 echo "    an absolute path. Installation will be selfcontained"
 echo "-l: creates symlinks instead of copying files, useful for development"
 echo "-h: prints this help"
}

PARAMETERS="hlu:g:d:"

if [ $(getopt --version | tr -d " ") = "--" ]; then
    TEMP_OPT=`getopt $PARAMETERS "$@"`
else
    TEMP_OPT=`getopt -o $PARAMETERS -n 'install.sh' -- "$@"`
fi

if [ $? != 0 ] ; then
    usage
    exit 1
fi

eval set -- "$TEMP_OPT"

LINK="no"
ONEADMIN_USER=`id -u`
ONEADMIN_GROUP=`id -g`
SRC_DIR=$PWD

while true ; do
    case "$1" in
        -h) usage; exit 0;;
        -d) ROOT="$2" ; shift 2 ;;
        -l) LINK="yes" ; shift ;;
        -u) ONEADMIN_USER="$2" ; shift 2;;
        -g) ONEADMIN_GROUP="$2"; shift 2;;
        --) shift ; break ;;
        *)  usage; exit 1 ;;
    esac
done

export ROOT

if [ -z "$ROOT" ]; then
    VAR_LOCATION="/var/lib/one"
    REMOTES_LOCATION="$VAR_LOCATION/remotes"
    ETC_LOCATION="/etc/one"
else
    VAR_LOCATION="$ROOT/var"
    REMOTES_LOCATION="$VAR_LOCATION/remotes"
    ETC_LOCATION="$ROOT/etc"
fi

do_file() {
    if [ "$UNINSTALL" = "yes" ]; then
        rm $2/`basename $1`
    else
        if [ "$LINK" = "yes" ]; then
            ln -fs $SRC_DIR/$1 $2
        else
            cp -R $SRC_DIR/$1 $2
        fi
    fi
}

copy_files() {
    FILES=$1
    DST=$DESTDIR$2

    mkdir -p $DST

    for f in $FILES; do
        do_file src/$f $DST
    done
}

create_dirs() {
    DIRS=$*

    for d in $DIRS; do
        dir=$DESTDIR$d
        mkdir -p $dir
    done
}

change_ownership() {
    DIRS=$*
    for d in $DIRS; do
        chown -R $ONEADMIN_USER:$ONEADMIN_GROUP $DESTDIR$d
    done
}

cd `dirname $0`/src

copy_files "im/xen.d/*" "$REMOTES_LOCATION/im/xen.d"
copy_files "im/xen-probes.d/*" "$REMOTES_LOCATION/im/xen-probes.d"
copy_files "vmm/*" "$REMOTES_LOCATION/xen"
copy_files "vnm/*" "$REMOTES_LOCATION/vnm/vnmmad-load.d"

LINK="no"
copy_files "etc/*" "$ETC_LOCATION/vmm_exec"
