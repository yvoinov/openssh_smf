# Solaris OpenSSH SMF
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://github.com/yvoinov/openssh_smf/blob/master/LICENSE)

This  set  of  scripts is designed to install and remove the
SMF service for OpenSSH on Sun Solaris 10 and above.

All  the  necessary  prerequisites  required  to  start  the
OpenSSH   service,  according  to  the  configuration  guide
(excluding  the  configuration  of  the  OpenSSH itself) are
performed  during  the installation of the service, removing
the  SMF  service  removes  all  scripts and unregisters the
OpenSSH service and stops it.

Follow these steps to enable OSSH SMF:

1. Install OpenSSH and all required libraries if not already
installed.

2.  Configure Ossh by editing /usr/local/etc/sshd_config and
/usr/local/etc/ssh_config

3.  Run  the ossh_smf_inst.sh script, which will perform all
the  necessary prerequisites and post-installation steps and
install the OSSH SMF service.

3.  Run  svcadm  enable ossh command to enable and start the
OSSH service.

Note:  Host  keys  will  be  generated during the activation
process if they have not already been generated.

To  deactivate and remove the OSSH SMF service, follow these
steps:

1.  Run  the  ossh_smf_rmv.sh  script.  The script stops all
running   OSSH   processes,  unregisters  the  SMF  service,
completely   removes   the  OSSH  SMF  and  rolls  back  the
operations performed earlier when the service was activated.

Note:  Removing  the  OSSH  SMF  service does not remove the
installed OpenSSH software. Host keys will not be deleted.
