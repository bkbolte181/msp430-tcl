#!/usr/bin/tclsh
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
# 
# File Name: generate_bin.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#             - Benjamin Bolte,    bkbolte18@gmail.com

###############################################################################
#                            SOURCE LIBRARIES                                 #
###############################################################################

# Get library path
set current_file [info script]
if {[file type $current_file]=="link"} {
    set current_file [file readlink $current_file]
}
set lib_path [file dirname $current_file]/

# Source library
source $lib_path/dbg_functions.tcl
source $lib_path/dbg_utils.tcl

###############################################################################
#                            PARAMETER CHECK                                  #
###############################################################################
#proc GetAllowedSpeeds

proc help {} {
    puts ""
    puts "USAGE   : generate_bin.tcl <elf/ihex-file>"
    puts ""
    puts ""
    puts "EXAMPLES: openmsp430-loader.tcl leds.elf"
    puts "          openmsp430-loader.tcl ta_uart.ihex"
    puts ""
}

# Default values
set elf_file              -1
set bin_file              -1

# Parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
        default   {set elf_file             [lindex $argv $i]}
    }
}

# Make sure arugments were specified
if {[string eq $elf_file -1]} {
    puts "\nERROR: ELF/IHEX file isn't specified"
    help
    exit 1   
}

# Make sure the elf file exists
if {![file exists $elf_file]} {
    puts "\nERROR: Specified ELF/IHEX file doesn't exist"
    help
    exit 1   
}

###############################################################################
#                  CREATE AND READ BINARY EXECUTABLE FILE                     #
###############################################################################

# Detect the file format depending on the file extention
set fileType [file extension $elf_file]
set fileType [string tolower $fileType]
regsub {\.} $fileType {} fileType
if {![string eq $fileType "ihex"] & ![string eq $fileType "hex"] & ![string eq $fileType "elf"]} {
    puts "\nERROR: [string toupper $fileType] file format not supported"
    return 0
}
if {[string eq $fileType "hex"]} {
    set fileType "ihex"
}
if {[string eq $fileType "elf"]} {
    set fileType "elf32-msp430"
}

# Generate binary file name
regsub {\.ihex|\.hex|\.elf} $elf_file {.bin} bin_file

# Generate binary file
if {[catch {exec msp430-objcopy -I $fileType -O binary $elf_file $bin_file} errMsg]} {
    puts $errMsg
    exit 1
}
