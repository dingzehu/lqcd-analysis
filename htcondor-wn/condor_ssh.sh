#!/bin/sh

##**************************************************************
##
## Copyright (C) 1990-2017, Condor Team, Computer Sciences Department,
## University of Wisconsin-Madison, WI.
## 
## Licensed under the Apache License, Version 2.0 (the "License"); you
## may not use this file except in compliance with the License.  You may
## obtain a copy of the License at
## 
##    http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
##**************************************************************

# condor_ssh wrapper
# format of contact file is
# node hostname port cwd username

# This script assumes the existance of a contact file
# and uses it to map a hostname into 
# the correct hostname/port of a listening sshd

# Uncomment the following line to have the shell print out
# each command to stderr before running it, useful for
# debugging
#set -x

if [ $# -lt 2 ]
then
    echo "Usage: condor_ssh hostname command arg1 arg2"
fi


doneParsing=false

while [ $doneParsing = "false" ]
do

doneParsing=true

if [ "$1" = "-x" ]
then
    shift
    hasx="-x"
    doneParsing="false"
fi

if [ "$1" = "-l" ]
then
    shift
    shift
    doneParsing="false"
fi

if [ "$1" = "-n" ]
then
    shift
    hasn="-n"
    doneParsing="false"
fi
done

proc=$1
shift 

# The option can also appear _after_ the host
doneParsing=false

while [ $doneParsing = "false" ]
do

doneParsing=true

if [ "$1" = "-x" ]
then
    shift
    hasx="-x"
    doneParsing="false"
fi

if [ "$1" = "-l" ]
then
    shift
    shift
    doneParsing="false"
fi

if [ "$1" = "-n" ]
then
    shift
    hasn="-n"
    doneParsing="false"
fi
done

# The HTCondor environment variables aren't always passed,
# but this script should always execute from the scratch dir
if [ -z ${_CONDOR_SCRATCH_DIR+x} ]
then
    _CONDOR_SCRATCH_DIR=`/bin/pwd`
fi

contact=$_CONDOR_SCRATCH_DIR/contact

if [ ! -f $contact ]
then
    echo "error: contact file $contact can't be found"
    exit 1
fi


# Note that the spaces in the grep are significant
line=`grep "^$proc " $contact`

if [ $? -ne 0 ]
then
    echo Proc $proc is not in contact file $contact
    exit 1
fi

#proc=`echo $line | awk '{print $1}'`
host=`echo $line | awk '{print $2}'`
port=`echo $line | awk '{print $3}'`
username=`echo $line | awk '{print $4}'`
dir=`echo $line | awk '{print $5}'`

key=$_CONDOR_SCRATCH_DIR/tmp/$proc.key

# Open MPI/MPICH assumes that you always have a shared filesystem, and
# sticks the pwd in front of all relative executable pathnames
# This is no good.

# So, if any argument contains the pwd, replace it with the scratch dir

ssh_args=$@
p=`/bin/pwd`
ssh_args=`echo $ssh_args | sed s@${p}@${dir}@g`

# Now call ssh with the remaining arguments at the end.
# Set the working directory and $HOME to the scratch dir
# so that the worker processes look there for the user's executable.
#--- original command line:
#--- /usr/bin/ssh -q $hasn -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i $key -l $username -p $port $host cd "$dir" \; export HOME="$dir" \; "$ssh_args"
/usr/bin/ssh -t -q $hasn -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i $key -l $username -p $port $host cd "$dir" \; export HOME="$dir" \; "$ssh_args"
