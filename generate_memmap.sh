

cat memmap.md | grep MEMMAP > docs/memmap_ram.md
sed -i 's/FREE/<span style="color:green">FREE<\/span>/g' docs/memmap_ram.md
sed -i 's/|#/#/g' docs/memmap_ram.md
sed -i 's/MEMMAP://g' docs/memmap_ram.md

LIST="RESB RES RESC RESD RESE RESF RESG RESH TR0 TR1 TR2 TR3 TR4 TR5 TR6 TR7 work_channel i_o_save i_o_counter ADIODB_VECTOR"

for I in $LIST; do

echo "# $I" > docs/$I.md
cat memmap.md | grep MODIFY | egrep "$I:" >> docs/$I.md
sed -i "s/|MODIFY:$I:/* /g"  docs/$I.md
done


LIST="XGETCWD_ROUTINE"

for I in $LIST; do

echo "# $I\n" > docs/primitives/$I.md
cat memmap.md | grep MODIFY | egrep "$I" >> docs/primitives/$I.md
sed -i "s/|MODIFY:/* /g"  docs/primitives/$I.md
sed -i "s/:$I//g"  docs/primitives/$I.md
done
