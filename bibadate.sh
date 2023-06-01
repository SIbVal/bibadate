#!/bin/bash

gross_salary=48000;
gross_premium=12000;
tax=0.13;
salary_day=10;
advance_day=25;

bibadate() {
#определяет, является день выходным или рабочим
if [[ $(date -d "$1" +%u) -eq '6' || $(date -d "$1" +%u) -eq '7' ]]; then  
	echo 'dont'
else
	echo 'do'
fi
}

lastday (){
#возвращает последний день месяца для переданной даты	
	start=$1;
	finish=$start;
	while [[ $(date -d "$start" +%m) -eq $(date -d "$finish" +%m) ]]; do
		finish=$(date +%Y%m%d -d "$finish + 1 day");
	done
	finish=$(date +%-d -d "$finish - 1 day");
	echo "$finish";
}

workdays() {
#возвращает количество рабочих дней с 1 числа месяца до указанной даты того же месяца
finish=$1
start=$(date +%Y%m01 -d "$finish");
count=0; 
while [[ $(date -d "$start" +%-d) -le $(date -d "$finish" +%-d) && $(date -d "$start" +%m) -eq $(date -d "$finish" +%m) ]]; do
	if [[ "$(bibadate "$start")" = "do" ]]; then
		count=$((count+1));
	fi
	start=$(date +%Y%m%d -d "$start + 1 day")
done
echo $((count));
}

#Вычитаем НДФЛ ;(
full_salary=$(echo "$gross_salary-$gross_salary*$tax" | bc);
premium=$(echo "$gross_premium-$gross_premium*$tax" | bc);

calculate_advance() {
#возвращает размер аванса
perday="$(echo "$full_salary" / "$(workdays "$(date -d "$1" +%Y%m"$(lastday "$1")" -d "$1")")" | bc)";
advance=$(echo "$perday * $(workdays "$(date -d "$1" +%Y%m15)")" | bc);
export advance="$advance";
}

calculate_salary() {
if [[ "$(date -d "$1" +%-d)" -le $salary_day ]]; then
	echo "ЗП за прошлый месяц";
else
	echo "$premium + $full_salary - $advance" | bc;
fi
}

if [[ -z ${1+x} ]]; then
	day=$(date +%Y%m%d);
else
	day=$1;
fi

if [[ "$(date -d "$day" +%-d)" -gt "$salary_day" ]] && [[ "$(date -d "$day" +%-d)" -le "$advance_day" ]]; then
	calculate_advance "$day";
else
	calculate_salary "$day";
fi