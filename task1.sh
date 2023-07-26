#!/bin/bash

tmpfile="./accounts.tmp"

while IFS="" read line
do
	echo $line | sed 's/'\"\"'/'\"'/g' >> $tmpfile

done < <( cat $1 )

python3 - <<DOC
import csv

updatedstrings=[]
with open('accounts.tmp','r') as csv_file:
	reader = csv.reader(csv_file)
	row1 = next(reader)
	for row in reader:
		#print("For row: ",row)
		name = (row[2].split(" "))[0].casefold().capitalize()
		surname = (row[2].split(" "))[1].casefold().capitalize()
		row[2]=name + ' ' + surname
		row[4]=name.casefold()[0]+surname.casefold()
		#print ("new row: ", row)
		updatedstrings.append(row)

	csv_file.close()

n = len(updatedstrings)

for i in range(0,n-1):
	for j in range(i+1,n):
		if updatedstrings[i][4] == updatedstrings[j][4]:
			updatedstrings[i][4] = updatedstrings[i][4]+updatedstrings[i][1]
			updatedstrings[j][4] = updatedstrings[j][4]+updatedstrings[j][1]

with open('accounts_new.csv','w',newline='') as file:
	writer = csv.writer(file)
	writer.writerow(row1)
	for row in updatedstrings:
		row[4]=row[4]+'@abc.com'
		writer.writerow(row)
	file.close()

DOC

#echo $(dirname $(readlink -f "$1"))
#echo $(dirname $(readlink -f $tmpfile))

if  [[ $(dirname $(readlink -f "$1")) != $(dirname $(readlink -f $tmpfile)) ]]; then
#	echo "paths are not equal"
	mv ./accounts_new.csv $(dirname $(readlink -f "$1"))
fi

rm $tmpfile
