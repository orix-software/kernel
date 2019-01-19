#! /bin/sh
HOMEDIR=/home/travis/bin/
HOMEDIR_ORIX=/home/travis/build/oric-software/orix
LIST_COMMAND='bank basic11 cat cd clear cp date echo env help ioports lscpu ls meminfo monitor lsmem mkdir mount mv orix ps pwd reboot pwd rm touch uname viewhrs'

echo Generate hlp


#cd $HOMEDIR
#mkdir mkdocs && cd mkdocs
#echo Generate mkdocs
#mkdocs new orix
#cp $HOMEDIR_ORIX/docs/mkdocs.yml orix/


cd $HOMEDIR
for I in $LIST_COMMAND; do
echo Generate $I
cat $HOMEDIR_ORIX/docs/$I.md | md2hlp.py > $HOMEDIR_ORIX/build/usr/share/man/$I.hlp
#cp $HOMEDIR_ORIX/src/man/$I.md $HOMEDIR/mkdocs/orix/docs/
done 

#cd $HOMEDIR

#cd mkdocs/orix
#mkdocs build
#cp /home/travis/bin/mkdocs/orix/site/* $HOMEDIR_ORIX/docs

#cd $(HOMEDIR) && cat $(HOMEDIR_ORIX)/src/man/basic11.md | md2hlp.py > $(HOMEDIR_ORIX)/build/usr/share/man/basic11.hlp
