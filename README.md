[![Build Status](https://travis-ci.org/orix-software/kernel.svg?branch=master)](https://travis-ci.org/orix-software/kernel)

# Orix

## Introduction

Orix is designed to work with ORICHD (telestrat) and Twilighte card (atmos). See : http://orix.oric.org

Some code is done by Fabrice Broche (70%) and Jede (30%). Anyway, all minitel and FDC routines had been removed

Assembler : ca65
CPU : 6502 & 65C02 (but 65c22 not tested)

## How to use it ?
This kernel is a set of primitives to displays string, open/close/write files ...

You need at least "shell" bank to use this kernel

## Build option

### Root file on sdcard 
Pass to ca65 command line : -DWITH_SDCARD_FOR_ROOT=1
or else it will reads en usb key

here is the list of available "compile option" 

* CPU_65C02
* WITH_MULTITASKING
* WITH_ACIA
* WITH_DEBUG
* WITH_TWILIGHTE_BOARD
