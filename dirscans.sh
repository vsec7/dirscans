#!/usr/bin/env bash
# Tool		: DirsCans ( File/Directory Scanner )
# By		: Versailles / Viloid
# Date		: 10-09-2019
# Greets	: Cans21 ~ Sec7or Team ~ Surabaya Hacker Link
# *Note 	: Im not support for this project/script. so if any mistake, fix it by your self (LO GAUSA BACOT JANCOK!)

R=$(tput setaf 1)
G=$(tput setaf 2)
M=$(tput setaf 5)
Y=$(tput setaf 3)
N=$(tput sgr0)

scan(){
	ua="Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Mobile Safari/537.36"
	res=$(curl -sI -H $ua "$1/$2")
	http=$(echo $res | grep -oP 'HTTP/(1.1|2) \K[^ ]*')
	loc=$(echo $res | grep -oP 'location: \K[^ ]+')
	if [ ! -z $loc ]; then
		printf "\r%s[%s] %s -> %s\n" "$(tput el)" "$Y$http$N" "$Y$2$N" "$loc"
		if [ ! -z "${o}" ]; then
			echo "$http|$1/$2 -> $1/$loc" >> $o
		fi
	elif [ $http -eq 200 ]; then
		printf "\r%s[%s] %s\n" "$(tput el)" "$G$http$N" "$G$2$N"
		if [ ! -z "${o}" ]; then
			echo "$http|$1/$2" >> $o
		fi
	else
		persen=$(awk "BEGIN { pc=100*${n}/$(cat $d | wc -l); i=int(pc); print (pc-i<0.5)?i:i+1 }")
		printf '\r%s(%s) Checking : %s' "$(tput el)" "$M$persen%$N" "$M$2$N"
	fi
}

header(){
cat <<EOF

+------------------------------------------------------------------+
|	DirsCans ( File/Directory Scanner )
|	By : Versailles / Viloid
|	Sec7or Team ~ Surabaya Hacker Link
+------------------------------------------------------------------+

EOF
}

usage(){
cat <<EOF

+------------------------------------------------------------------+
|	DirsCans ( File/Directory Scanner )
|	By : Versailles / Viloid
|	Sec7or Team ~ Surabaya Hacker Link
|
| 	USAGE : $0 -u [url]
| 	E.g : $0 -u http://domain.com
| 	OPTIONS :
|		-u (url) **required**
|		-d (Custom Wordlist: default [dict/dict.txt]) **optional**
|		-t (Thread: default [50]) **optional**
|		-o (Output) **optional**
+------------------------------------------------------------------+

EOF
exit
}

while getopts ":u:d:t:o:" opt; do
	case "${opt}" in
		u)
			u=${OPTARG}
			;;
		d)
			d=${OPTARG}
			;;
		t)
			t=${OPTARG}
			;;
		o)
			o=${OPTARG}
			;;
	esac
done

if [ -z "${u}" ]; then
	usage;exit
fi

if [[ $(echo $u | grep -ic "http") -eq 0 ]]; then
	echo -e "[$M INFO $N]$R Url should contains http:// or https:// $N";exit
fi

if [[ -z ${t} ]]; then
	t=50;
fi

if [[ -z ${d} ]]; then
	d="dict/dict.txt";
fi

if [ ! -f "${d}" ]; then
	echo -e "[$M INFO $N] ${R}Dictionary File ${G}$d${N} ${R}Not Exist${N}";exit
fi

header

echo "[$M INFO $N] URL  : $G$u$N"
echo "[$M INFO $N] DICT : $G$(wc -l $d)$N"
echo
n=1
IFS=$'\r\n' GLOBIGNORE='*'
for i in $(cat $d); do
	f=$(expr $n % $t)
	if [[ $f == 0 && $n > 0 ]]; then
		sleep 1
	fi
	scan $u $i $n &	
	n=$[$n+1]
done
wait
printf '\r%s=========[ Checking Done ]=========\n' "$(tput el)"
