============================================================
OpenSSH SMF Installation & Remove  (C) 2007,2017 Yuri Voinov
============================================================

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

Archive contains:

init.ossh             - OSSH SMF control method
ossh.xml              - OSSH SMF service manifest
readme_en.txt         - This file (English)
readme_ru.txt         - This file (Russian)
ossh_smf_inst.sh      - OSSH SMF installation script
ossh_smf_rmv.sh       - OSSH SMF removal script
pre_ossh_remove.sh    - Script for deleting the sshd user/group
                        (priv separation), /var/empty directory
                        and host keys after uninstalling the
                        SMF service.

============================================================
OpenSSH SMF Installation & Remove  (C) 2007,2017 Yuri Voinov
============================================================