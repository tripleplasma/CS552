cut -c 53-80 ../verification/trace.txt > ../verification/inter.txt
sed -i 's/Wr/1 0/g' ../verification/inter.txt
sed -i 's/Rd/0 1/g' ../verification/inter.txt
sed -i 's/Addr //g' ../verification/inter.txt
sed -i 's/Value //g' ../verification/inter.txt
sed -i '/^$/d' ../verification/inter.txt
awk '{ printf "%s %s %d %d\n", $1, $2, strtonum($3), strtonum($4) }' ../verification/inter.txt > ../verification/test.addr