#!/bin/bash
# #################################
# reconnect_node.sh
# v0.1.a - KC7LHV - James Hatmaker
# This script can be used to check and reconnect
# a node to an Allstarlink system
#
# The script uses NODE1 and REMOTE_NODE from allstar.env
#  
# CRON: 
# 00 0-23 * * * /usr/local/etc/reconnect_node.sh <NODEID> > /var/log/reconnect_node.log 
# #################################
#
# THIS_NODE   # this is set from NODE1 in  allstar.env
# REMOTE_NODE # can either be set in the allstar.env
#             # or passed in one the CMD line
#             # EG.  reconnect_node.sh 12344
#             # or set in this file
#             # by uncommenting the line below and setting 
#             # the value appropriately
# REMOTE_NODE=12341234
#
# DEBUG 1|0   # can be used when testing the script 
# ################################
DEBUG=0
# ################################
# source AllStar ENV file
# ################################
if [ -e  "/usr/local/etc/allstar.env" ] ; then
	. /usr/local/etc/allstar.env
else
	echo "No allstar.evn file found (see /usr/local/etc/allstar.env). Exiting"
	exit 1
fi
# ################################
# Set localnode
# ################################

THIS_NODE=${NODE1}
if [ -z "${THIS_NODE}" ] ; then
        echo "Local Node could not be set (see /usr/local/etc/allstar.env). Exiting"
        exit 2
fi

# ################################
# Determine what the REMOTE_NODE
# to check is 
# you can set REMOTE_NODE in env file
# or pass it in on the CMD line
# ################################
if [ ! -z "$1" ] ; then
	REMOTE_NODE=$1
fi
if [ -z "${REMOTE_NODE}" ] ; then
	echo "Remote Node not set. "
	exit 3
fi


echo "[$(date)] [${THIS_NODE}] Check node ${REMOTE_NODE} connection state"

NODES=$(asterisk -rx "rpt nodes ${THIS_NODE}")
IS_CONNECTED=$(echo ${NODES} | grep -c ${REMOTE_NODE})
if [ ${IS_CONNECTED} -eq 0 ] ; then
        echo "[$(date)] [${THIS_NODE}] Node ${REMOTE_NODE} is NOT Connected.  Trying to re-establish connection now."
        `asterisk -rx "rpt fun ${THIS_NODE} *73${REMOTE_NODE}"`
        RETVAL=$?
        sleep 15
        NODES=$(asterisk -rx "rpt nodes ${THIS_NODE}")
        IS_CONNECTED=$(echo ${NODES} | grep -c ${REMOTE_NODE})
        if [ ${IS_CONNECTED} -eq 0 ] ; then
                echo "[$(date)] [${THIS_NODE}] Failed to reconnect node ${REMOTE_NODE} to ${THIS_NODE}."
                exit 1
        else
                echo "[$(date)] [${THIS_NODE}] Reconnection successful."
        fi
else
        echo "[$(date)] [${THIS_NODE}] Node ${REMOTE_NODE} is already connected to ${THIS_NODE}."
fi
exit 0

