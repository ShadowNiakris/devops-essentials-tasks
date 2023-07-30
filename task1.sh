#!/bin/bash

#create temporary file for processing
tmpfile="./accounts.tmp"

#write input file to tmp file
while IFS="" read line
do
#	echo $line | sed 's/'\"\"'/'\"'/g' >> $tmpfile
	echo $line >> $tmpfile

done < <( cat $1 )

#processing tmp file with csv python module
python3 - <<DOC
import csv

#the array with new processed strings
updatedstrings=[]

#updating strings
with open('accounts.tmp','r') as csv_file:
	reader = csv.reader(csv_file)

	#the first row with titles is written without processing
	row1 = next(reader)

	for row in reader:
		#print("For row: ",row)
		name = (row[2].split(" "))[0].title()
		surname = (row[2].split(" "))[1].title()
		row[2]=name + ' ' + surname
		row[4]=name.casefold()[0]+surname.casefold()
		#print ("new row: ", row)
		updatedstrings.append(row)

	csv_file.close()
#	print("updatedstrings:",updatedstrings)

n = len(updatedstrings)
print('n=', n)
#in this section we check if the email has clone and modify both of them

for i in range(0,n-1):
	#it is a flag to change an updatedstrings[i]
	flag = False

	for j in range(i+1,n):
		print('i=',i,'j=',j)
		if updatedstrings[i][4] == updatedstrings[j][4]:
			flag=True
			print(updatedstrings[i][4], '==', updatedstrings[j][4])
			print('updatedstrings[',i,',4',']=',updatedstrings[i][4])
			updatedstrings[j][4] = updatedstrings[j][4]+updatedstrings[j][1]
			print('updatedstrings[',j,',4',']=',updatedstrings[j][4])
	if flag == True:		
		updatedstrings[i][4] = updatedstrings[i][4]+updatedstrings[i][1]
	

#write updated string down into new file 
with open('accounts_new.csv','w',newline='') as file:
	writer = csv.writer(file)
	writer.writerow(row1)
	for row in updatedstrings:
		row[4]=row[4]+'@abc.com'
		writer.writerow(row)
	file.close()

DOC

echo $(dirname $(readlink -f "$1"))
echo $(dirname $(readlink -f $tmpfile))

#move the new file to directory of old file
if  [[ $(dirname $(readlink -f "$1")) != $(dirname $(readlink -f $tmpfile)) ]]; then
#	echo "paths are not equal"
	mv ./accounts_new.csv $(dirname $(readlink -f "$1"))
fi

rm $tmpfile
