[![build](https://github.com/orix-software/kernel/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/orix-software/kernel/actions/workflows/main.yml)

# Orix Kernel

## Introduction

It's the Orix kernel (in bank 7 and 8) in order to start on twilighte board

Assembler : ca65
CPU : 6502 & 65C02 (but 65C02 not tested)

# How to compile

Bank 8 (extended) is managed with bpm tool

make

Or for local development

sh run.sh

## How to use it ?

This kernel is a set of primitives to displays string, open/close/write files ...

You need at least "shell" bank to use this kernel

## Documentation

[Kernel Primitives Documentation](https://orix-software.github.io/developer_manual/kernel/primitives/)

### Root filesystem :sdcard

Pass to ca65 command line : -DWITH_SDCARD_FOR_ROOT=1
or else it will reads in* usb key

### Root filesystem : usbdrive

Remove -DWITH_SDCARD_FOR_ROOT=1 on ca65 command line
or else it will reads in sdcard

## How does it starts

* Kernel tries to start binary set in his rom label 'str_binary_to_start'
* it allocates a process struct (first malloc)
* and register it in processlist

## Launch unit test (local)

1) Set ORICUTRON_PATH in your shell eg : 

ORICUTRON_PATH=/bin/
export ORICUTRON_PATH

2) make launch-unit-test


## Test github action

An docker image in tests/Dockerfile is available to test some stuff into Dockerenvironnement (in order to simulate github action behavior)

docker build --no-cache  -t kernelorix .

