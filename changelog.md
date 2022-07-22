# 2022.4

* Bugfix : multiples files impossible to manage it when files were greater than 256 bytes
* bugfix : write file was not working on real computer

# 2022.3

* [XMKDIR] Fix registers
* [XATN] Arc Tan routine removed
* [XCOS] Cosinus routine removed
* [XSIN] Cosinus routine removed
* [XLN] Ln routine removed
* [XLOG] Ln routine removed
* [XEXP] Ln routine removed
* [XOPEN] WR_ONLY Flag now, does not create the file. O_CREAT is managed and create the file
* [XFSEEK] now works (return EOK if OK, EINVAL if whence is not recognize)
* [XOPEN] [XREAD] [XCLOSE] Allows to open 2 files
* [XFREE] Fix many bugs
* [Load from device] Add magic token to start any binary without checks
* [cc65] Fix mkdir bug
* [cc65] now send correct fd for fwrite/fopen/fread to the kernel
* [cc65] kbhit has the right behavior

# 2020.2

* [XOPEN] Now we can open files from with a string bigger than 17 bytes ...
* [XEXEC] Fix a bug : when we launched many rom commands, sometimes orix restarts
* [XEXEC] Fix a bug : binary from cc65 was not able to get args from command line
