function print()
{    
    printf "%-30s %-20s %5s %15s %15s %15s %15s %15s %15s %16s\n" "COMM" "USER" "PID" "READB" "WRITEB" "RATER" "RATEW" "DATE" 
    
    if [[ -v opts[r] ]]; then # ----> inversa
        order="-rn"
    else
        order="-n"
    fi

    if ! [[ -v opts[p] ]]; then # ----> nº de processos
        p=${#info[@]}
    else
        p=${opts['p']}
    fi

    if [[ -v opts[w] ]]; then
        if  [[ "$order" == "-rn" ]]; then
            order="-n"
        else
            order="-rn"
        fi
        
        printf '%s \n' "${info[@]}" | sort  -k5 $order | head -n $p
    fi 
    
    if [[ "$order" == "-rn" ]]; then
        printf '%s \n' "${info[@]}" | sort  -k6 | head -n $p
    else
        printf '%s \n' "${info[@]}" | sort  -k6 -rn | head -n $p
    fi

}

print 

regexDate='^((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)) +(0?[1-9]|[12][0-9]|3[01]) +([01]?[0-9]|2[0-3]):[0-5][0-9]'