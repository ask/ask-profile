#!/bin/bash

null=$(cat /dev/null)

true=true
false=$null

escape-quotes () {
   return-value $(echo $* | perl -ple"s{\'}{\\\'}g")
}

print-screen () {
    escape-quotes $* | perl -ne 's{\\*n}{\n}xmsg; print if length';
}

write-stderr () {
    print-screen $* > /dev/stderr
}

println () {
    echo "$*\n"
}

return-value () {
    println $*
}

skip-first () {
    f=$null
    result=$null

    for v in $*; do
        [ $f ] && result+=$v$IFS
        f=true
    done

    return-value $result
}

array-length () {
    length=0

    for v in $*; do
        length=$(( $length + 1))
    done

    return-value $length
}

array-first () {
    return $1
}

skip-last () {
    f=$null;
    result=$null
    length=$(array-length $*)
    cur_element=0
     
    for v in $*; do
        [ $cur_element -lt $length ] && result+="$IFS$v"
        cur_element=$(($cur_element + 1))
    done

    return-value $result
}

new-array-from-pos () {
    pos=$1
    result=$null
    array=$(skip-first $*)
    length=$(array-length $array)
    cur_element=0
    
    for v in $array; do
        [ $cur_element -ge $pos ] && result+="$IFS$v"
        cur_element=$(($cur_element + 1))
    done

    return-value $result
}
    
for-each () {
    array="$1"
    codetext=$(new-array-from-pos $(array-length $array) $*)
    codetext=$(
        return-value $codetext | perl -pe '
            s{ %s }{\$CURRENT_FOREACH_ELEMENT}xmsg
        '
    )
    codetext=$(
        return-value $codetext | perl -pe'
            s/(?:
                    ^\s*\{     # block start at start of string.
                    |   \}\s*$ # or, block end at end of string.
                )
            //xms
        '
    );

    for CURRENT_FOREACH_ELEMENT in $array; do
        eval $codetext
    done
}

join-array () {
    return-value $(for-each "$*" 'return-value "$IFS%s"')
}
    

opt-on  () {
    for-each "$*" set -o %s
}

opt-off () {
    for-each "$*" set +o %s
}


trace-on  () { opt-on  xtrace; }
trace-off () { opt-off xtrace; }
debug-on  () { opt-on  xtrace verbose; }
debug-off () { opt-off xtrace verbose; }

preaction-then-postaction-if-extra-args () {
    #pre="$1" && post="$2" && extra="$3"
#    eval $pre
#    echo ${3:+$(`$*` && eval $post)}

    (eval $1;echo ${3:+$(echo $($3;$2))})

}


_ () {
    preaction-then-postaction-if-extra-args trace-on "$*"
}

__ () {
    preaction-then-postaction-if-extra-args debug-on debug-off "$*"
}

    


#echo "$1" | perl -ne'exit m{^\d+$} ? 0 : 1'
is-integer () {
    perl -e'exit 1 if $ARGV[-1] !~ m{^\d+$}' -- "$1"
    return-value ${?:+$([ $? -eq 0 ] && return-value 1)}
}

bullet () {
    #crest="\*"
    #level=$null
    #[ $(is-integer $1) ] && level=$1  && skip_first=true
    #[ "$1" == "+error" ] && crest='!' && skip_first=true
    #[ ${level:-0} != 0 ] && crest='-'
    #vals=$((test $skip_first && return-value `skip-first $*`) || return-value $*)
    #return-value $(join-array $crest $vals);
    return-value "[x]" $*
}
   
log-error () {
    bullet +error "ERROR: $*" > /dev/stderr
}

log-result () {
    write-stderr -n ${*:+$(bullet 0 $*...)} 
}

result-ok () {
    res=${*:-" OK"}
    write-stderr $res
}

result-failed () {
    res=${*:-" FAILED"}
    write-stderr $res > /dev/stderr
}
