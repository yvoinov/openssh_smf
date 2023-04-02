#!/bin/sh

#
# OpenSSH moduli generation script
# Yuri Voinov (C) 2008,2017
#
# ident "@(#)moduli_gen.sh    2.0    30/07/17 YV"
#

#############
# Variables #
#############

# DH-GEX size. Default is 2048
BIT="8192"

OPENSSH_KEYGEN="/usr/local/bin/ssh-keygen"
MODULI_DIR="/usr/local/etc"
LOG="/var/log/moduli.log"

#
# OS command locations
#
CUT=`which cut`
ECHO=`which echo`
ID=`which id`
LS=`which ls`
RM=`which rm`

###############
# Subroutines #
###############

root_check ()
{
 if [ ! `$ID | $CUT -f1 -d" "` = "uid=0(root)" ]; then
  $ECHO "ERROR: You must be super-user to run this script."
  exit 1
 fi
}

check_ossh ()
{
 if [ ! -f "$OPENSSH_KEYGEN" ]; then
  $ECHO "ERROR: OpenSSH not found! Exiting..."
  exit 1
 fi
}

##############
# Main block #
##############

$ECHO "DH-GEX moduli generation and testing."
$ECHO "Recommended to run it with NOHUP opt."

# Check root
root_check

# Check OpenSSH
check_ossh

$ECHO "`date` OpenSSH moduli generation start...">>$LOG

$OPENSSH_KEYGEN -G $MODULI_DIR/moduli$BIT.candidates -b $BIT>>$LOG

$OPENSSH_KEYGEN -T $MODULI_DIR/moduli -f $MODULI_DIR/moduli$BIT.candidates>>$LOG

$RM -f $MODULI_DIR/moduli$BIT.candidates

$LS -l $MODULI_DIR/moduli>>$LOG

$ECHO "`date` OpenSSH moduli generation complete.">>$LOG

exit 0
