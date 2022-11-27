#!/bin/bash

#--------------------------------------------------------------------------------------------------------------------------------
#                                             Trabalho 1
#                             Monitorização de interfaces de rede em bash
#
# Guião
#    O objectivo do trabalho é o desenvolvimento de um script em bash que apresenta estatísticas
# sobre a quantidade de dados transmitidos e recebidos nas interfaces de rede selecionadas, e sobre as
# respectivas taxas de transferência
# 
# Manuel Diaz       103645
# Tiago Carvalho    104142
#--------------------------------------------------------------------------------------------------------------------------------

# Inicialização de Arrays
declare -A COMM #FAZ ALGUMA MERDA
declare -A USER # Array Associativo para guardar os valores de USER de cada interface de rede, na unidade de visualização desejada.
declare -A PID # Array Associativo para guardar os valores de PID de cada interface de rede, na unidade de visualização desejada.
declare -A rxb2 # Array Associativo para guardar os valores de RX2 de cada interface de rede, em bytes.
declare -A tx # Array Associativo para guardar os valores de TX de cada interface de rede, na unidade de visualização desejada.
declare -A txb1 # Array Associativo para guardar os valores de TX1 de cada interface de rede, em bytes.
declare -A txb2 # Array Associativo para guardar os valores de TX2 de cada interface de rede, em bytes.
declare -A trate # Array Associativo para guardar os valores de TRATE de cada interface de rede, na unidade de visualização desejada.
declare -A rrate # Array Associativo para guardar os valores de RRATE de cada interface de rede, na unidade de visualização desejada.
declare -A txtot # Array Associativo para guardar os valores de TXTOT de cada interface de rede, na unidade de visualização desejada.
declare -A rxtot # Array Associativo para guardar os valores de RXTOT de cada interface de rede, na unidade de visualização desejada.

# Inicilização de variáveis
nre="^[0-9]+(\.[0-9]*)?$" # Expressão regular usada para números.   
i=0 # Usada para verificar a condição de uso de apenas um dos -b, -k ou -m.
d=0 # Usada para verificar a condição do argumento passado entre -b, -k ou -m.
m=0 # Usada para verificar a condição de uso de apenas um dos -t, -r, -T ou -R.
l=0 # Usada para transportar valor do loop de -l.
p=-1 # Usada para transportar o número de interfaces a visualizar de -p.
ctr=1 # Usada para calcular o valor de controlo dos argumentos.
k=1 # Usada para determinar a coluna da tabela relevante à ordenação.
c="" # Usada para transportar a expressão regular passada em -c
reverse="" # Usada para alternar a ordenação entre decrescente e crescente.
t=${@: -1} # Usada para guardar o último argumento e usá-lo em todo o programa.
#--------------------------------------------------------------------------------------------------------------------------------

function usage() { # Menu de execução do programa.
    echo "Menu de Uso e Execução do Programa."
    echo "    -c         : Seleção  dos  processos  a  visualizar  pode  ser  realizada através de uma expressão regular."
    echo "    -s          : Seleção de processos a visualizar num periodo temporal - data mínima"
    echo "    -e          : Seleção de processos a visualizar num periodo temporal - data máxima"
    echo "    -u          : Seleção de processos a visualizar através do nome do utilizador"
    echo "    -m          : Seleção de processos a visualizar através de uma gama de pids"
    echo "    -M          : Seleção de processos a visualizar através de uma gama de pids"
    echo "    -p          : Número de processos a visualizar"
    echo "    -r          : Ordenação reversa"
    echo "    -w          : Ordenação da tabela por valores de escrita"

}
function getTable() { # Função principal do programa. Obtém os valores desejados, ordena-os e imprimi-os.
    for net in /sys/class/net/[[:alnum:]]*; do # Procurar por todas as interfaces de rede disponiveis.
        if [[ -r $net/statistics ]]; then 
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            # Condição para apenas trabalhar com interfaces de rede que coincidam com a expressão regular passada pela opção -c.
            if [[ -v optsOrd[c] && ! $f =~ ${optsOrd[c]} ]]; then
                continue
            fi
            if [[ -z ${rxb1[$f]} ]]; then # Caso em que o valor de RX1 ainda não está definido.
                rxb1[$f]=$(cat $net/statistics/rx_bytes | grep -o -E '[0-9]+') # Obter do valor de RX1 em bytes, na primeira execução.
            else
                rxb1[$f]=${rxb2[$f]} # Obter do valor de RX1 em bytes, a partir do RX2 da execução anterior.
            fi
            if [[ -z ${txb1[$f]} ]]; then # Caso em que o valor de TX1 ainda não está definido.
                txb1[$f]=$(cat $net/statistics/tx_bytes | grep -o -E '[0-9]+') # Obter do valor de TX1 em bytes, na primeira execução.
            else
                txb1[$f]=${txb2[$f]} # Obter do valor de TX1 em bytes, a partir do TX2 da execução anterior.
            fi
        fi
    done
    sleep $t # Tempo de espera entre pedidos da quantidade de dados transmitidos e recebidos. Passado como último argumento.
    for net in /sys/class/net/[[:alnum:]]*; do # Procurar por todas as interfaces de rede disponiveis.
        if [[ -r $net/statistics ]]; then
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            # Condição para apenas trabalhar com interfaces de rede que coincidam com a expressão regular passada pela opção -c.
            if [[ -v optsOrd[c] && ! $f =~ ${optsOrd[c]} ]]; then
                continue
            fi
            rxb2[$f]=$(cat $net/statistics/rx_bytes | grep -o -E '[0-9]+') # Obter do valor de RX2 em bytes.
            txb2[$f]=$(cat $net/statistics/tx_bytes | grep -o -E '[0-9]+') # Obter do valor de TX2 em bytes.
            rxb=$((rxb2[$f] - rxb1[$f])) # Obter do valor de RX em bytes, subtraindo RX2 por RX1.
            txb=$((txb2[$f] - txb1[$f])) # Obter do valor de TX em bytes, subtraindo TX2 por TX1.
            rrateb=$(bc <<< "scale=3;$rxb/$t") # Obter do valor de RRATE em bytes.
            trateb=$(bc <<< "scale=3;$txb/$t") # Obter do valor de TRATE em bytes.
            mult=$((1024 ** d)) # Calculo usado para alterar a unidade desejada (Bytes, Kilobytes, Megabytes).
            rx[$f]=$(bc <<< "scale=3;$rxb/$mult") # Alterar RX para unidade desejada e salva-la no array.
            tx[$f]=$(bc <<< "scale=3;$txb/$mult") # Alterar TX para unidade desejada e salva-la no array.
            rrate[$f]=$(bc <<< "scale=3;$rrateb/$mult") # Alterar RRATE para unidade desejada e salva-la no array.
            trate[$f]=$(bc <<< "scale=3;$trateb/$mult") # Alterar TRATE para unidade desejada e salva-la no array.
            if [[ -z ${txtot[$f]} ]]; then # Inicialização do TXTOT se ele ainda não existir.
                txtot[$f]=0
            fi
            if [[ -z ${rxtot[$f]} ]]; then # Inicialização do RXTOT se ele ainda não existir.
                rxtot[$f]=0
            fi
            txtot[$f]=$(bc <<< "scale=3;${txtot[$f]}+${tx[$f]}") # Soma do valor de TX anterior ao TX total.
            rxtot[$f]=$(bc <<< "scale=3;${rxtot[$f]}+${rx[$f]}") # Soma do valor de RX anterior ao RX total.
            fi
    done
    if [[ $l == 0 ]]; then # Caso em que não se passou a opção -l e não é preciso calcular o RX e TX total.
        printf "%-15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" # Imprimir o cabeçalho da tabela.
    else
        printf "%-15s %15s %15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT" # Imprimir o cabeçalho da tabela.
    fi
    n=0 # Usada para controlar o número de interfaces de rede impressas.
    for net in /sys/class/net/[[:alnum:]]*; do # Procurar por todas as interfaces de rede disponiveis.
        if [[ -r $net/statistics ]]; then
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            if [[ $n -lt $p || $p = -1 ]]; then # Condição para apenas serem vistos o número de interfaces passados pela opção -p.
                # Condição para apenas trabalhar com interfaces de rede que coincidam com a expressão regular passada pela opção -c.
                if [[ -v optsOrd[c] && ! $f =~ ${optsOrd[c]} ]]; then
                    continue
                fi
                if [[ $l == 0 ]]; then # Caso em que não se passou a opção -l e não é preciso calcular o RX e TX total.
                    printf "%-15s %15s %15s %15s %15s\n" "$f" "${tx[$f]}" "${rx[$f]}" "${trate[$f]}" "${rrate[$f]}" # Imprimir os valores da tabela.
                else 
                    printf "%-15s %15s %15s %15s %15s %15s %15s\n" "$f" "${tx[$f]}" "${rx[$f]}" "${trate[$f]}" "${rrate[$f]}" "${txtot[$f]}" "${rxtot[$f]}" # Imprimir os valores da tabela.
                fi
            fi
            let "n+=1" # Incrementar o valor de n.
        fi
    done | sort -k$k$reverse # Ordernar o output da tabela a partir da coluna ( $k ), decrescente ou crescente ( $reverse ).
} 

# Verificação da existência do último argumento.
if [[ $# == 0 ]]; then
    echo "Necessário, pelo menos, o período de tempo desejado (segundos). Ex -> ./netifstat.sh 10"
    usage # Menu de execução do programa.
    exit 1 # Terminar o programa
fi
# Verificação do último argumento.
if ! [[ $t =~ $nre ]]; then
    echo "O último argumento deve ser um número. Ex -> ./netifstat.sh 10"
    usage # Menu de execução do programa.
    exit 1 # Terminar o programa
fi

# While para tratamento das opções selecionadas.
while getopts "c:bkmp:trTRvl" option; do

    #Adicionar ao array optsOrd as opcoes passadas ao correr o programa.
    if [[ -z "$OPTARG" ]]; then
        optsOrd[$option]="blank" # Caso a opção não precise de argumento, passa blank para o array. Ex: -b -> blank
    else
        optsOrd[$option]=${OPTARG}  # Caso precisem de argumento, guarda o argumento no array.
    fi

    case $option in
    c) #Seleção das interfaces a visualizar através de uma expressão regular.
        c=${optsOrd[c]}
        let "ctr+=2" # Acrescentar 2 ao valor de controlo dos argumentos.
        ;;
    p) #Seleção do número de interfaces de redes a visualizar.
        p=${optsOrd[p]}
        if ! [[ $p =~ $nre ]]; then
            echo "Error : A opção -p requer que se indique o número de redes a visualizar. Ex -> netifstat -p 2 10" >&2
            usage # Menu de execução do programa.
            exit 1 # Terminar o programa
        fi
        let "ctr+=2" # Acrescentar 2 ao valor de controlo dos argumentos.
        ;;
    l) #Seleção do intrevalo de tempo entre execuções do loop.
        l=1
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    b | k | m ) # Mudar a unidade de visulização (Bytes, Kilobytes, Megabytes).
        if [[ $i = 1 ]]; then
            echo "Só é permitido o uso de uma das opções : -b, -k ou -m. Ex -> ./netifstat -b 10"
            usage # Menu de execução do programa.
            exit 1 # Terminar o programa
        fi
        i=1
        if [[ ${optsOrd[k]} == "blank" ]]; then # Mudar a unidade de visulização para kilobytes.
            d=1;
        fi
        if [[ ${optsOrd[m]} == "blank" ]]; then # Mudar a unidade de visulização para megabytes.
            d=2;
        fi
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    t | r | T | R) # Ordenação da tabela por coluna (decrescente).
        reverse="r" 
        if [[ $m = 1 ]]; then
            echo "Só é premitido o uso de uma das opções : -t, -r, -T ou -R. Ex -> ./netifstat -r 10"
            usage # Menu de execução do programa.
            exit 1
        fi
        let "m+=1"
        if [[ $option == "t" ]]; then # Uso da opção -t.
            k=2 # Alterar a coluna 2 da impressão. Coluna dos valores de TX.
        fi
        if [[ $option == "r" ]]; then # Uso da opção -r.
            k=3 # Alterar a coluna 3 da impressão. Coluna dos valores de RX.
        fi
        if [[ $option == "T" ]]; then # Uso da opção -T.
            k=4 # Alterar a coluna 4 da impressão. Coluna dos valores de TRATE.
        fi
        if [[ $option == "R" ]]; then # Uso da opção -R.
            k=5 # Alterar a coluna 5 da impressão. Coluna dos valores de RRATE.
        fi
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    v) # Ordenação reversa (crescente).
        if [[ $reverse == "r" ]]; then # Caso o $reverse já tenha sido mudado em "t | r | T | R)"
            reverse="" # Fazer a tabela imprimir de forma crescente
        else
            reverse="r"
        fi
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    *) # Uso de argumentos inválidos.
        echo "Uso de argumentos inválidos."
        usage # Menu de execução do programa.
        exit 1 # Terminar o programa
        ;;
    esac
done
# Verificar se o valor do controlo de argumentos é igual ao número de argumentos passados.
# Evitar casos em que o programa corre se forem usados argumentos do tipo -> ./netifstat -c 2
if ! [[ $# == $ctr ]]; then
    echo "Uso de argumentos inválidos. Poucos argumentos foram passados."
    usage # Menu de execução do programa.
    exit 1 # Terminar o programa
fi
# Execução da função getTable dependendo da opção -l (loop)
if [[ $l -gt 0 ]]; then
    while true; do # Loop sem quebras.
        getTable
        echo
    done
else
    getTable # Caso em que não se passa o argumento -l.
fi