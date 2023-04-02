#!/sbin/sh

#
# OpenSSH run pre-requisites remove.
# Yuri Voinov (C) 2007,2017
#
# ident "@(#)pre_ossh_rmv.sh    2.0    30/07/17 YV"
#

#############
# Variables #
#############

PROGRAM_NAME="OpenSSH"
SSH_GROUP_USER="sshd"
LOCAL_DIR="/usr/local"
VAR_EMPTY="/var/empty"

CUT=`which cut`
ECHO=`which echo`
GETENT="`which getent`"
GROUPDEL=`which groupdel`
ID=`which id`
RM=`which rm`
UNAME=`which uname`
USERDEL=`which userdel`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`

###############
# Subroutines #
###############

os_check ()
{
 if [ "$OS_NAME" != "SunOS" ]; then
  $ECHO "ERROR: Unsupported OS $OS_NAME. Exiting..."
  exit 1
 elif [ "$OS_VER" -lt "10" ]; then
  $ECHO "ERROR: Unsupported $OS_NAME version $OS_VER. Exiting..."
  exit 1
 fi
}

root_check ()
{
 if [ ! `$ID | $CUT -f1 -d" "` = "uid=0(root)" ]; then
  $ECHO "ERROR: You must be super-user to run this script."
  exit 1
 fi
}

pre_ossh_check ()
{
 # Check if OpenSSH run pre-requisites is complete
 if [ -z "`$GETENT group $SSH_GROUP_USER`" -a -z "`$GETENT passwd $SSH_GROUP_USER`" -a ! -d "$VAR_EMPTY" ]; then
  $ECHO "0"
 else
  $ECHO "1"
 fi
}

remove_pre_ossh ()
{
 # Remove VAR_EMPTY dir
 $ECHO "Remove $VAR_EMPTY directory..."
 $RM -r $VAR_EMPTY>/dev/null 2>&1

 $ECHO "Remove sshd user and group..."
 $USERDEL $SSH_GROUP_USER>/dev/null 2>&1
 $GROUPDEL $SSH_GROUP_USER>/dev/null 2>&1

 # Remove host-keys if they exist...
 if [ -f $LOCAL_DIR/etc/ssh_host_dsa_key -o -f $LOCAL_DIR/etc/ssh_host_rsa_key ]; then
  $ECHO "Remove host keys..."
  $RM -f $LOCAL_DIR/etc/ssh_host_*_key*>/dev/null 2>&1
 fi
}

##############
# Main block #
##############

# Pre-removal checks
# OS version check
os_check

# Superuser check
root_check

$ECHO "------------------------------------------"
$ECHO "- $PROGRAM_NAME SMF service run pre-requisites -"
$ECHO "- will be remove now.                    -"
$ECHO "-                                        -"
$ECHO "-                                        -"
$ECHO "- Press <Enter> to continue,             -"
$ECHO "- or <Ctrl+C> to cancel                  -"
$ECHO "------------------------------------------"
read p

if [ "`pre_ossh_check`" = "1" ]; then
 $ECHO "-------------------------------------------------------"
 $ECHO "Note: $PROGRAM_NAME pre-requisites was done and will be remove..."
 remove_pre_ossh
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** Successful";;
  *) $ECHO "*** Errors occurs during $PROGRAM_NAME pre-requisites removal";;
 esac
 $ECHO "-------------------------------------------------------"
else
 $ECHO "$PROGRAM_NAME pre-requisires was not done. Nothing to do."
fi

exit 0
