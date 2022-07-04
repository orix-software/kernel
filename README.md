[![build](https://github.com/orix-software/kernel/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/orix-software/kernel/actions/workflows/main.yml)

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
* WITH_DEBUG : In that case, somes primitives send their debug to printer with a help of kdebug ROM.
* WITH_TWILIGHTE_BOARD

## How does it starts

* Kernel tries to start binary set in his rom label 'str_binary_to_start'
* it allocates a process struct (first malloc)
* and register it in processlist
