#! /bin/bash
while read p; do
	#echo "$p"
        url=`echo $p | cut -d " " -f 2`
        rest=`echo $p | cut -d " " -f 3- | sed 's/ /\//g'`  
	base=`[[ "$url" =~ ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))? ]] && echo "${BASH_REMATCH[4]}${BASH_REMATCH[5]}"`
	gun=$base/$rest
	echo $gun
done </etc/apt/sources.list


cat packages.txt | sed -e :a -e '$!N;s/\n / /;ta' -e 'P;D' | jq -sR '[ split("\n\n";"n")[] 
    | [ capture("(?<key>[^:\n]+): *(?<value>[^\n]+)";"g") | .key |= (. | ascii_downcase) ] 
        | from_entries | select(length > 0)]' | jq .[2]
