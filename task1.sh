#! /bin/bash

declare -a arr

while IFS="," read -r id location name jobtitle email state
do
	#Update column name: first letter of name/surname uppercase and all other letters lowercase
	read Name Surname < <(echo $name)
	Name=${Name,,}
	Name=${Name^}
	Surname=${Surname,,}
	Surname=${Surname^}

	#create an email: a first letter of the name + surname lowercase + domain
	firstletter=${Name:0:1}
#	email=${firstletter,}${Surname,,}$location'@abc.com'
	email=${firstletter,}${Surname,,}'@abc.com'

	#make a new string with the new email
	newstring="$id,$location,$Name $Surname,$jobtitle,$email,$state"

	arr+=("$newstring")

done < <(tail -n +2 $1)

n=$((${#arr[@]}-1))

for i in $(seq 0 $(($n-1)))
do
	for j in $(seq $(($i+1)) $n)
	do
		IFS="," read id_i location_i name_i jobtitle_i email_i state_i < <(echo "${arr[$i]}")
		IFS="," read id_j location_j name_j jobtitle_j email_j state_j < <(echo "${arr[$j]}")

		if [[ "$email_i" == "$email_j" ]]; then
			newstring_i=${arr[$i]/@/$location_i@}
			newstring_j=${arr[$j]/@/$location_j@}

			arr[$i]="$newstring_i"
			arr[$j]="$newstring_j"

		fi
	done
done

for i in "${arr[@]}"
do
	echo $i >> accounts_new.csv
done
