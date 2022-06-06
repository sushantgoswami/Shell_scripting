# Create /var/sadm/sudotraces directory if it does not exist
#
if ( ! -d /var/sadm/sudotraces ) then
        mkdir -p /var/sadm/sudotraces
endif
#
# Set trace filename
#
set tracename="/var/sadm/sudotraces/`echo $SUDO_USER`.`date +'%Y%m%d%H%M%S'`".$$
#
# Run su to switch user to root by logging the session using the trace file
/bin/su - root  -c "script $tracename"
#EOF
