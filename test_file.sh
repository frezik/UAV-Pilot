#!/bin/bash
FILES=$1
perl ./Build.PL
./Build && ./Build test --verbose=1 --test_files ${FILES}
./Build distclean
