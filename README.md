# rcProcDump
#######################################################################

Red Crow Labs

#######################################################################

DESCRIPTION:

rcProdDump is PoC Code to use various methods for dumping process memory on a Linux based computer. When analyzing a product or device it is sometimes advantageous to dump related processes memory in order to look for clear text secrets or conduct general reverse engineering. Not all systems or devices being test have every tool, and there might be restrictions on installing new tools so this capability is implemented as an easy to deploy shell script. The memory dumps can also be exfiltrated with rcHTTPexfil.

This script currently implements the following dumping methodologies:

- gcore: This utility, which is part of the gdb package, generates a core dump of a running process. A core dump includes the process's memory as well as register state, the state of open file descriptors, and other process state information. The output is typically in ELF format, which is a common binary format that can be read by many debugging and disassembly tools.

- gdb: When used to manually dump memory, gdb outputs raw memory contents to a series of files. This will not include register state, file descriptor information, or other process state. It's just the contents of memory as they were at the moment the dump was taken. 

- Proc Mem: Directly reading from /proc/$PID/mem. This approach is similar to using gdb to manually dump memory. It outputs raw memory contents to a series of files, without any additional process state information. Reading from /proc/$PID/mem requires the ability to suspend the process.


=========================================================================
INSTALL: 

git clone https://github.com/redcrowlab/rcProcDump.git



=========================================================================
USAGE: 

Usage: ./rcProcDump.sh PID {gcore|gdb|proc|auto}

Auto will attempt to determin if gcore or gdb exists and use them in that order. If not it will fall back to reading raw Proc Mem.

=========================================================================
NOTE:

There are some cases where memory dumping might be incomplete or fail altogether.