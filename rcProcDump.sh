#!/bin/sh

#############################################################
# rcProcDump - Provides multiple methods for dumping proceesses
# on Linux based computers. Best results if run as root.
#
# Usage: ./rcProcDump.sh PID {gcore|gdb|proc|auto}

# Check if PID is supplied
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: ./script.sh PID {gcore|gdb|proc|auto}"
    exit 1
fi

PID=$1
METHOD=$2

# Check if the process exists
if [ ! -d "/proc/$PID" ]; then
    echo "Process $PID does not exist."
    exit 1
fi

# Check if the process memory is readable
if [ ! -r "/proc/$PID/mem" ]; then
    echo "Memory for process $PID is not readable."
    exit 1
fi

# Decide which dumping method is available
if [ "$METHOD" = "auto" ]; then
    if command -v gcore >/dev/null 2>&1; then
        METHOD="gcore"
    elif command -v gdb >/dev/null 2>&1; then
        METHOD="gdb"
    else
        METHOD="proc"
    fi
fi

# Executes select dumping method
case $METHOD in
    "gcore")
        gcore -o $PID.core $PID
        ;;
    "gdb")
        sudo cat /proc/$PID/maps | while read line; do
            START=$(echo $line | awk '{print $1}' | awk -F '-' '{print "0x"$1}')
            END=$(echo $line | awk '{print $1}' | awk -F '-' '{print "0x"$2}')
            gdb --batch --pid $PID -ex "dump memory $PID-$START-$END.dump $START $END"
        done
        ;;
    "proc")
        sudo cat /proc/$PID/maps > $PID-maps.txt
        sudo kill -STOP $PID
        while IFS= read -r line; do
            START=$(echo $line | awk '{print $1}' | awk -F '-' '{print "0x"$1}')
            END=$(echo $line | awk '{print $1}' | awk -F '-' '{print "0x"$2}')
            START_DEC=$(printf "%d\n" $START)
            END_DEC=$(printf "%d\n" $END)
            sudo dd if=/proc/$PID/mem of=$PID-$START-$END.dump bs=1 skip=$START_DEC count=$(($END_DEC-$START_DEC)) status=none
        done < "$PID-maps.txt"
        sudo kill -CONT $PID
        ;;
    *)
        echo "Invalid method. Please use gcore, gdb, proc, or auto."
        exit 1
        ;;
esac

echo "Memory dump completed. Method: $METHOD"