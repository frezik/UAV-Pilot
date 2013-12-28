#!/bin/sh
# 
# HOW TO USE THIS
# 
# On your Raspberry Pi, do:
# 
# 0) Make sure "screen" is installed ("apt-get install screen")
# 1) Raspberry Pi at /etc/wumpusrover/start_wumpusrover_server.sh
# 2) Run "chmod +x /etc/wumpusrover/start_wumpusrover_server.sh"
# 3) As root, open /etc/rc.local in an editor, and add this to the end:
#
#     /etc/wumpusrover/start_wumpusrover_server.sh
#
# 4) Run '/etc/wumpusrover/start_wumpusrover_server.sh' manually (as root) to 
#    make sure everything is OK
#
# You can see the process running by attaching to screen as root with:
#
#     sudo screen -r wumpus
#
# I would love suggestions on how to run this without being root.  The I2C 
# interface on the Raspberry Pi accesses /dev/mem, which requires your user 
# to have write access there.  I tried playing around in udev, but still got 
# errors.
#

echo "Starting WumpusRover server"
screen -S wumpus -d -m /usr/local/bin/wumpusrover_server
echo "Done starting WumpusRover server"

exit 0
