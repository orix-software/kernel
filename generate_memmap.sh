

 
cat memmap.md | grep MEMMAP > docs/memmap_ram.md
sed -i 's/FREE/<span style="color:green">FREE<\/span>/g' docs/memmap_ram.md
sed -i 's/|#/#/g' docs/memmap_ram.md
sed -i 's/MEMMAP://g' docs/memmap_ram.md

LIST="RESB RES RESC RESD RESE RESF RESG TR0 TR1 TR2 TR3 TR4 TR5 TR6 TR7"

for I in $LIST; do 

echo "# $I" > docs/$I.md
cat memmap.md | grep MODIFY | egrep "$I:" >> docs/$I.md
sed -i "s/|MODIFY:$I:/* /g"  docs/$I.md
done 

#echo '# TR7' > docs/TR7.md
#cat memmap.md | grep MODIFY | grep TR7 >> docs/TR7.md
#sed -i 's/|MODIFY:TR7:/* /g'  docs/TR7.md