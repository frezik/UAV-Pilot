#!/bin/bash
sudo ls > /dev/null # Get the sudo password prompt right away
perl ./Build.PL
./Build && ./Build test && sudo ./Build install
./Build distclean
