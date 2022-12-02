
# !/bin/bash 

# Joana Gomes, 
# Lia Cardoso, 107548


#PROBLEMA A RESOLVER --------> leitura dos argumetos, não está a ler o primeiro argumento (segundos) -----> problema em validate_argumments
#arrays para guardar valores
declare -A rchar_ar 
declare -A wchar_ar
declare -A opts 
declare -A info

# var iniciais
sleep_time=${@: -1}
re='^[0-9]+(\.[0-9]*)?$' 

#funções

# menu de opções
function menu(){
    echo ""
    echo ""
    echo "=========================================================================="
	echo "                                OPÇÕES:"
    echo "=========================================================================="
    echo ""
	echo "  -c: Choose one regex expression  "
	echo "  -s: Choose a minimum date in the format 'Month Day Hour:Minute'"
	echo "  -e: Choose a maximum date in the format 'Month Day Hour:Minute' "
	echo "  -u: Choose an user   "
	echo "  -m: Choose a minimum PID   "
	echo "  -M: Choose a maximum PID   "
	echo "  -p: Choose the amount of processes you want to see   "
	echo "  -r: Reverse order  "
	echo "  -w: Ordered by writen values   "
	echo "  Warning: Last arg has to be a number (seconds)"
}

#print table no final
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


# Validação dos argumentos e tratamento de dados

    if [[ $# == 0 ]]; then
    echo "Needs at least one argument!."
    menu
    exit 1
    fi

    if ! [[ ${@: -1} =~ $re ]]; then
        echo "Último argumento tem de ser um número."
        menu
        exit 1
    fi

    # note for later: $OPTARG ---> argumento a seguir a uma opção
    while getopts "c:s:e:u:m:M:p:rw" option ; do 

        if [[ $OPTARG == "" ]]; then
            opts[$option]="empty"
        else
            opts[$option]=$OPTARG
        fi

        case $option in     

            c)
                str=${opts['c']}
                if [[ $str =~ $re || $str == "empty" ]]; then
                    echo "ERROR: Invalid regex expression"
                    menu
                    exit 1
                fi
                ;;

            s)
                str=${opts['s']}
                regData="[A-Za-z]{3} ([0-2][1-9]|[3][0-1]) ([0-1][0-9]|[2][0-4]):[0-5][0-9]"
                if [[ $str == 'empty' || $str =~ $re || ! "$str" =~ $regData ]]; then
                    echo "ERROR: Invalid date!"
                    menu
                    exit 1
                fi
                ;;

            e)
                str=${opts['e']}
                regData="[A-Za-z]{3} ([0-2][1-9]|[3][0-1]) ([0-1][0-9]|[2][0-4]):[0-5][0-9]"
                if [[ $str == 'empty' || $str =~ $re || ! "$str" =~ $regData ]]; then
                    echo "ERROR: Invalid date!"
                    menu
                    exit 1
                fi
                ;;
            
            u)
                
                str=${opts['u']}
                if [[ $str =~ $re || $str == "empty" ]]; then
                    echo "ERROR: Invalid user"
                    menu
                    exit 1
                fi
                ;; 

            m)
                if ! [[ ${opts['m']} =~ $re ]]; then
                    echo "Argumento de '-p' tem de ser um número ou chamou sem '-' atrás da opção passada." >&2
                    menu
                    exit 1
                fi
                ;;
            
            M)
                if ! [[ ${opts['M']} =~ $re ]]; then
                    echo "Argumento de '-p' tem de ser um número ou chamou sem '-' atrás da opção passada." >&2
                    menu
                    exit 1
                fi
                ;;

            p)
                if ! [[ ${opts['p']} =~ $re ]]; then
                    echo "Argumento de '-p' tem de ser um número ou chamou sem '-' atrás da opção passada." >&2
                    menu
                    exit 1
                fi
                ;;

            r)

                ;;
            w)

                ;;

            *) 
                echo "ERRO: Invalid option ($OPTARG)"
                menu
                exit 1
                ;;
        esac
    done


    cd /proc/

    pid=$(ps -ef  | grep 'p' | awk '{print $2}') # ---> -ef = todos os processos; grep [p]rocess (stackoverflow)

    for i in $pid ;do
        if [ -d  $i ];then
            cd ./$i
            if [ -r ./io ];then
                rchar=$(cat /proc/$i/io | grep rchar |   grep -o -E '[0-9]+'  )
                wchar=$(cat /proc/$i/io | grep wchar |  grep -o -E '[0-9]+'  )
                rchar_ar[$i]=$rchar 
                wchar_ar[$i]=$wchar 
            fi
            cd ../
        fi
    done

    sleep $sleep_time #tempo de espera de s segundos para a segunda leitura

    #2ª leitura
    for i in $pid; do
        if [[ ${rchar_ar[$i]} ]];then
            if [ -d  $i ];then
                cd ./$i
                    if [ -r ./io ];then
                        rchar_1=${rchar_ar[$i]} 
                        wchar_1=${wchar_ar[$i]}
                        comm=$(cat /proc/$i/comm | tr " " "_")
                        user=$(ls -ld /proc/$i | awk '{print $3}')
                        rchar_2=$(cat /proc/$i/io | grep rchar | grep -o -E '[0-9]+')
                        wchar_2=$(cat /proc/$i/io | grep wchar | grep -o -E '[0-9]+')
                        dif_r="$(($rchar_2-$rchar_1))"
                        rater=$(echo "scale=2; $dif_r/$sleep_time " | bc -l)
                        dif_w="$(($wchar_2-$wchar_1))"
                        ratew=$(echo "scale=2; $dif_w/$sleep_time " | bc -l)

                            if [[ -v opts[u] && ! ${opts['u']} == $user ]]; then
                                continue
                            fi

                            #Seleção de processos a utilizar atraves de uma expressão regular
                            if [[ -v opts[c] && ! $comm =~ ${opts['c']} ]]; then
                                continue
                            fi

                            LANG=en_us_8859_1
                            start_date=$(ps -o lstart= -p $i) # data de início do processo atraves do PID
                            start_date=$(date +"%b %d %H:%M" -d "$start_date")
                            date_sec=$(date -d "$start_date" +"%b %d %H:%M"+%s | awk -F '[+]' '{print $2}') # data do processo em segundos

                            if [[ -v opts[s] ]]; then                                                         #Para a opção -s
                                start=$(date -d "${opts['s']}" +"%b %d %H:%M"+%s | awk -F '[+]' '{print $2}') # data mínima

                                if [[ "$date_sec" -lt "$start" ]]; then
                                    continue
                                fi
                            fi

                            if [[ -v opts[e] ]]; then                                                       #Para a opção -e
                                end=$(date -d "${opts['e']}" +"%b %d %H:%M"+%s | awk -F '[+]' '{print $2}') # data máxima

                                if [[ "$date_sec" -gt "$end" ]]; then
                                    continue
                                fi
                            fi
                            
                            if [[ -v opts[m] || -v opts[M] ]]; then
                
                                if [[ -v opts[m] && -v opts[M] ]]; then
                                
                                    pidmin=${opts[m]}
                                    pidmax=${opts[M]}
                                    
                                    if [[ $i -ge $pidmin&& $i -le $pidmax ]]; then
                                        info[$i]=$(printf "%-27s %-16s %15d %12d %12d %15s %15s %16s\n" "$comm" "$user" "$i" "${rchar_ar[$i]}" "${wchar_ar[$i]}" "$rater" "$ratew" "$start_date")
                                    fi
                                
                                
                                elif [[ -v opts[m] ]]; then

                                    pidmin=${opts[m]}
                                    if [[ $i -ge $pidmin ]]; then
                                        info[$i]=$(printf "%-27s %-16s %15d %12d %12d %15s %15s %16s\n" "$comm" "$user" "$i" "${rchar_ar[$i]}" "${wchar_ar[$i]}" "$rater" "$ratew" "$start_date")
                                    fi
                                
                                
                                else
                                    pidmax=${opts[M]}
                                    if [[ $i -le $pidmax ]]; then
                                        info[$i]=$(printf "%-27s %-16s %15d %12d %12d %15s %15s %16s\n" "$comm" "$user" "$i" "${rchar_ar[$i]}" "${wchar_ar[$i]}" "$rater" "$ratew" "$start_date")
                                    fi
                                fi

                        else
                            info[$i]=$(printf "%-27s %-16s %15d %12d %12d %15s %15s %16s\n" "$comm" "$user" "$i" "${rchar_ar[$i]}" "${wchar_ar[$i]}" "$rater" "$ratew" "$start_date") 
                        fi
                    fi   
                cd ../
            fi
        fi

    done

print # -------> print data 