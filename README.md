# msp430-tcl
Minor edits to MSP430 Tcl scripts

### Keep binary file
Instead of
```bash
program.tcl <<< parameters >>> <filename.elf>;
```
do
```bash
generate-bin.tcl <filename.elf>;
program.tcl <<< parameters >>> filename.bin;
```
