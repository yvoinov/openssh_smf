#!/sbin/sh

#
# OpenSSH SMF installation.
# Yuri Voinov (C) 2007,2017
#
# ident "@(#)ossh_smf_inst.sh    2.0    30/07/17 YV"
#

#############
# Variables #
#############

PROGRAM_NAME="OpenSSH"
SERVICE_NAME="ossh"
SCRIPT_NAME="init.""$SERVICE_NAME"
SMF_XML="$SERVICE_NAME"".xml"
SMF_DIR="/var/svc/manifest/network"
SVC_MTD="/lib/svc/method"
SSHD_DSA_SERVER_KEY_BITS="1024"
SSHD_RSA_SERVER_KEY_BITS="4096"
SSHD_ECDSA_SERVER_KEY_BITS="521"
SSHD_ED2551_SERVER_KEY_BITS="256"

SSH_GROUP_USER="sshd"
LOCAL_DIR="/usr/local"
VAR_EMPTY="/var/empty"

# OS utilities
AWK=`which awk`
CHOWN=`which chown`
CHMOD=`which chmod`
COPY=`which cp`
CUT=`which cut`
ECHO=`which echo`
GETENT=`which getent`
GROUPADD=`which groupadd`
ID=`which id`
MKDIR=`which mkdir`
PASSWD=`which passwd`
SVCCFG=`which svccfg`
SVCS=`which svcs`
UNAME=`which uname`
USERADD=`which useradd`
ZONENAME=`which zonename`

OS_VER=`$UNAME -r|$CUT -f2 -d"."`
OS_NAME=`$UNAME -s|$CUT -f1 -d" "`
OS_FULL=`$UNAME -sr`
ZONE=`$ZONENAME`

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

check_np ()
{
 if [ ! -z "`$GETENT passwd $SSH_GROUP_USER`" ]; then
  if [ "`$PASSWD -s $SSH_GROUP_USER|$AWK {'print $2'}`" = "NP" ]; then
   $ECHO "1"
  else
   $ECHO "0"
  fi
 fi
}

pre_ossh_check ()
{
 # Check if OpenSSH run pre-requisites is complete
 if [ -z "`$GETENT group $SSH_GROUP_USER`" -o -z "`$GETENT passwd $SSH_GROUP_USER`" -o ! -d "$VAR_EMPTY" ]; then
  $ECHO "0"
 else
  $ECHO "1"
 fi
}

exec_pre_ossh ()
{
 # Exec run pre-requisites OSSH steps
 $ECHO "$PROGRAM_NAME run pre-requisites steps..."
 $MKDIR -p $VAR_EMPTY>/dev/null 2>&1
 $CHOWN root:sys $VAR_EMPTY>/dev/null 2>&1
 $CHMOD 755 $VAR_EMPTY>/dev/null 2>&1
 if [ ! -d $LOCAL_DIR/etc ]; then
  $MKDIR -p $LOCAL_DIR/etc>/dev/null 2>&1
  $CHOWN root:sys $LOCAL_DIR/etc>/dev/null 2>&1
  $CHMOD 755 $LOCAL_DIR/etc>/dev/null 2>&1
 fi
 $GROUPADD $SSH_GROUP_USER>/dev/null 2>&1
 $USERADD -g sshd -c 'sshd privsep' -d $VAR_EMPTY -s /bin/false $SSH_GROUP_USER>/dev/null 2>&1
 $PASSWD -N $SSH_GROUP_USER

 # Making host-keys if they not exist
 if [ ! -f $LOCAL_DIR/etc/ssh_host_dsa_key -o ! -f $LOCAL_DIR/etc/ssh_host_rsa_key ]; then
  $ECHO "$PROGRAM_NAME host keys generation. Please wait..."
  $LOCAL_DIR/bin/ssh-keygen -b $SSHD_DSA_SERVER_KEY_BITS -t dsa -f $LOCAL_DIR/etc/ssh_host_dsa_key -N "">/dev/null 2>&1
  $LOCAL_DIR/bin/ssh-keygen -b $SSHD_RSA_SERVER_KEY_BITS -t rsa -f $LOCAL_DIR/etc/ssh_host_rsa_key -N "">/dev/null 2>&1
 fi

 # Making advanced host-keys if they not exist
 if [ ! -f $LOCAL_DIR/etc/ssh_host_ecdsa_key -o ! -f $LOCAL_DIR/etc/ssh_host_ed25519_key ]; then
  $ECHO "$PROGRAM_NAME advanced host keys generation. Please wait..."
  $LOCAL_DIR/bin/ssh-keygen -b $SSHD_ECDSA_SERVER_KEY_BITS -t ecdsa -f $LOCAL_DIR/etc/ssh_host_ecdsa_key -N "">/dev/null 2>&1
  $LOCAL_DIR/bin/ssh-keygen -b $SSHD_ED2551_SERVER_KEY_BITS -t ed25519 -f $LOCAL_DIR/etc/ssh_host_ed25519_key -N "">/dev/null 2>&1
 fi
}

non_global_zones ()
{
 # Non-global zones notification
 if [ "$ZONE" != "global" ]; then
  $ECHO "=============================================================="
  $ECHO "This is NON GLOBAL zone $ZONE. To complete installation please copy"
  $ECHO "script $SCRIPT_NAME"
  $ECHO "to $SVC_MTD"
  $ECHO "in GLOBAL zone manually BEFORE starting service by SMF."
  $ECHO "Note: Permissions on $SCRIPT_NAME must be set to root:sys."
  $ECHO "============================================================="
 fi
}

##############
# Main block #
##############

# Pre-inst checks
# OS version check
os_check

# Superuser check
root_check

# OpenSSH installation check
if [ ! -f $LOCAL_DIR/bin/ssh-keygen ]; then
 $ECHO "ERROR: $PROGRAM_NAME not installed? Exiting..."
 exit 1
fi

$ECHO "-------------------------------------------"
$ECHO "- $PROGRAM_NAME SMF service will be install now -"
$ECHO "-                                         -"
$ECHO "- Press <Enter> to continue,              -"
$ECHO "- or <Ctrl+C> to cancel                   -"
$ECHO "-------------------------------------------"
read p

# Copy SMF files and install service
$ECHO "Copying $PROGRAM_NAME SMF files..."
if [ -f "$SCRIPT_NAME" -a -f "$SMF_XML" ]; then
 # Make needful permissions fo files
 $CHOWN root:sys $SCRIPT_NAME
 $CHOWN root:sys $SMF_XML

 # Copy SMF method
 $COPY $SCRIPT_NAME $SVC_MTD
 $CHMOD 555 $SVC_MTD/$SCRIPT_NAME

 # Copy service manifest
 $COPY $SMF_XML $SMF_DIR

 # Validate and import service manifest
 $SVCCFG validate $SMF_DIR/$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor validation successful";;
  *) $ECHO "*** XML service descriptor validation has errors";;
 esac
 # Solaris 11 compatibility: manifest does not import immediately from standard location
 $SVCCFG import ./$SMF_XML>/dev/null 2>&1
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** XML service descriptor import successful";;
  *) $ECHO "*** XML service descriptor import has errors";;
 esac
else
 $ECHO "ERROR: $PROGRAM_NAME SMF service files not found. Exiting..."
 exit 1
fi

# Execute OpenSSH run pre-requisites if they not complete yet
if [ "`pre_ossh_check`" = "0" -o "`check_np`" = "0" ]; then
 $ECHO "-------------------------------------------------------"
 $ECHO "Note: $PROGRAM_NAME pre-requisites is not complete. Do it now..."
 exec_pre_ossh
 retcode=`$ECHO $?`
 case "$retcode" in
  0) $ECHO "*** Successful";;
  *) $ECHO "*** Errors occurs during $PROGRAM_NAME run pre-requisites execution";;
 esac
 $ECHO "-------------------------------------------------------"
fi

$ECHO "Verify $PROGRAM_NAME SMF installation..."

# View installed service
$SVCS $SERVICE_NAME

# Check for non-global zones installation
non_global_zones

$ECHO "If $PROGRAM_NAME services installed correctly, enable and start it now"

exit 0
