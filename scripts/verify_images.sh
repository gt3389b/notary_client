#! /bin/bash
while read p; do
	#echo "$p"
        url=`echo $p | cut -d " " -f 2`
        rest=`echo $p | cut -d " " -f 3- | sed 's/ /\//g'`  
	base=`[[ "$url" =~ ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))? ]] && echo "${BASH_REMATCH[4]}${BASH_REMATCH[5]}"`
	gun=$base/$rest
	echo $gun
done </etc/apt/sources.list

base=`[[ "security.debian.org/debian-security/stretch/updates/main" =~ ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))? ]] && echo "${BASH_REMATCH[4]}${BASH_REMATCH[5]}"`
gun=$base
echo $gun

#stage $gun

packages=`cat data/packages.txt | sed -e :a -e '$!N;s/\n / /;ta' -e 'P;D' | jq -sR '[ split("\n\n";"n")[] 
    | [ capture("(?<key>[^:\n]+): *(?<value>[^\n]+)";"g") | .key |= (. | ascii_downcase) ] 
        | from_entries | select(length > 0)]'`

mkdir -p tmp

notary reset $gun --all

for row in $(echo "${packages}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   #echo deb.debian.org/debian/$(_jq '.filename') 
   #echo http://deb.debian.org/debian/$(_jq '.filename') 
   filepath=$(_jq '.filename')
   filename=`echo $filepath | rev | cut -d "/" -f 1 | rev`
   url=http://deb.debian.org/debian/$filepath
   wget -q -P tmp/ $url | notary add $gun $filepath ${PWD}/tmp/$filename
   rm tmp/$filename
done

echo $gun

#notary publish $gun
