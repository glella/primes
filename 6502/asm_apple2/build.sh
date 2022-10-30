#!/usr/bin/env fish
# compile
cl65 -t apple2enh -o prog.bin -C apple2bin.cfg -l primes.list primes.s
# copy blank disk
cp ~/Documents/workspace/blankdisk/MASTER.DSK ./progs.dsk
# add program to disk with applecommander 1.6 renamed to ac (and in the same folder as classpath does not work)
java -XstartOnFirstThread -jar ~/Documents/workspace/ac/ac.jar -p progs.dsk prog B 24576 < prog.bin
# copy finished disk to emulator fixed location
cp progs.dsk ~/Documents/workspace/apple_build 
# open emulator
open ~/Applications/Wineskin/AppleWin.app
# automated "BRUN PROG" by adding to the HELLO prog in master disk:
# 10 PRINT CHR$(4);"BRUN PROG"
