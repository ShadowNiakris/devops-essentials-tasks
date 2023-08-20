
#!/bin/bash

#Path to output.txt file should be as argument to the script
path=$(dirname $1)

echo "working on the file $1"

#using compound command [[ ]] we get a test's name from a first string
#[[ $(head $1 -n 1) =~ \[\ (.*)\ \] ]]

#AssertionName=${BASH_REMATCH[1]}
AssertionName=$( head -n 1 output.txt | grep -oe "\[ .* \]" | sed 's/^\[ //' | sed 's/ \]$//')
echo 'test name:' $AssertionName

#creates a workpiece of our future beautiful json
json="{ \"testName\": \"$AssertionName\",\
\"tests\": [],\
\"summary\":{\"success\":0,\"failed\":0,\"rating\":0,\"duration\":0} }"

#echo $json

#variables
#number_of_tests=0
number_of_succ_tests=0
number_of_fail_tests=0
common_duration=0
rating=0

#get and processing test lines
while read line; do
#	number_of_tests+=1

	#finds test's result with regex
#	[[ $line =~ ^([a-z]*) ]]
#	if [[ ${BASH_REMATCH[1]} == 'not' ]]; then
#		TestStatus='false'
#		(( number_of_fail_tests++ ))
#	else TestStatus='true'
#		(( number_of_succ_tests++ ))
#	fi

	if [ "$(echo "$line" | grep -oe "^ok")" == 'ok' ]; then
		TestStatus='true'
		number_of_succ_tests=$(( $number_of_succ_tests+1 ));
	else
		TestStatus='false'
		number_of_fail_tests=$(( $number_of_fail_tests+1 ));
	fi

#	echo $TestStatus $number_of_succ_tests $number_of_fail_tests

	#finds test's name with regex
#	[[ $line =~ [0-9]+\ (.*), ]]
#	TestName=${BASH_REMATCH[1]}
#echo "$line"

	TestName=$(echo "$line" | grep -oe '[0-9]  .*, [0-9]' | sed 's/^[0-9]\ \ //' | sed 's/,\ [0-9]$//')
#echo "TestName:"$TestName

	#finds test's duration woth regex
#	[[ $line =~ ,\ ([0-9]+ms) ]]
#	TestDuration=${BASH_REMATCH[1]}


	TestDuration=$(echo "$line" | grep -oe '[0-9]*ms' | sed 's/ms$//')

#echo "TestDuration:"$TestDuration
#echo "$line" | grep -oe '[0-9]*ms$' | sed 's/ms$//'

#	[[ $TestDuration =~ ([0-9]+)ms ]]
#	common_duration=$(( $common_duration + ${BASH_REMATCH[1]} ))

	common_duration=$(( $common_duration + $TestDuration ))
#	echo $common_duration

#	echo "success:" $number_of_succ_tests "failed:" $number_of_fail_tests "duration: " $common_duration

#adds the object of the test into array in the json
	json=$(echo "$json" | ./jq '. + {tests:(.tests + [{"testname":$ARGS.positional[0],"Duration":$ARGS.positional[1],"result":$ARGS.positional[2] }])}' --args "$TestName" "$TestDuration" "$TestStatus")

done < <( head -n -2 ${1} | tail -n +3)

#adds final values into json
tests_count=$(( ($number_of_succ_tests+$number_of_fail_tests) ))

medi_result=$(($number_of_succ_tests*100))

#bc command caused error
#rating=$(echo "scale=2 ; $medi_result / $tests_count" | bc)
rating=$(echo | awk '{ printf "%.2f\n", v1/v2 }' v1=$medi_result v2=$tests_count)

#awk -v var1=$number_of_succ_tests -v var2=$tests_count 'BEGIN { print ( var1 / var2 ) }'

#echo 'rating:' $rating
common_duration=$common_duration'ms'

json=$(echo $json | ./jq --arg v $number_of_succ_tests '.summary.success = $v')
json=$(echo $json | ./jq --arg v $number_of_fail_tests '.summary.failed = $v')
json=$(echo $json | ./jq --arg v $common_duration '.summary.duration = $v')
json=$(echo $json | ./jq --arg v $rating '.summary.rating = $v')


#echo "$path"/output.json
echo $json | ./jq "." > "$path"/output.json
if [ -f "$path"/output.json ]; then
	echo "file "$path"/output.json" created
fi 
