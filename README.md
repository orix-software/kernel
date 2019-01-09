[![Build Status](https://travis-ci.org/oric-software/orix.svg?branch=master)](https://travis-ci.org/oric-software/orix)

# Orix

## Introduction

Orix is designed to work with ORICHD (telestrat) and Twilighte card (atmos). See : http://orix.oric.org

Some code is done by Fabrice Broche (70%) and Jede (30%). Anyway, all minitel and FDC routines had been removed

Assembler : XA
CPU : 6502 & 65C02 (not tested)

## How to code in the kernel.

* There is 3 banks
  src/bank7.asm is the primitive bank, each time a BRK is called, it switch to this bank
  src/bank6.asm contains a modifyied atmos rom (some bytes are changed, and there is not test rom)
  src/bank5.asm contains functions and interpreter
  src/monitor_bank.asm contains monitor code

* 6502 & 65C02
 for specific 65C02 code, please use #ifdef CPU_65C02

## Build option

here is the list of available "compile option" 

Cpu target
* CPU_65C02

* WITH_MULTITASKING
* WITH_ACIA
* WITH_BANKS
* WITH_CPUINFO
* WITH_DEBUG
* WITH_DF    
* WITH_HISTORY
* WITH_KILL
* WITH_LESS
* WITH_LSOF
* WITH_MONITOR
* WITH_MORE
* WITH_MOUNT
* WITH_SEDSD
* WITH_SH
* WITH_TREE
* WITH_TWILIGHTE_BOARD
* WITH_VI
* WITH_XA
* WITH_XORIX
