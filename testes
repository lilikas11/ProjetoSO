#!/bin/bash

#--------------------------------------------------------------------------------------------------------------------------------
#                                             Trabalho 1
#                             Taxas de Leitura/Escrita de processos em bash
#
# Guião
#    O objetivo do trabalho é o desenvolvimento de um script em bash para obter estatísticas sobre
#    as leituras e escritas que os processos estão a efetuar. Esta ferramenta permite visualizar o número total
#    de bytes de I/O que um processo leu/escreveu e também a taxa de leitura/escrita correspondente aos
#    últimos s segundos para uma seleção de processos (o valor de s é passado como parâmetro).
#
# Liliana Ribeiro 108713
# Gonçalo Sousa 108133
#--------------------------------------------------------------------------------------------------------------------------------

# Inicialização de Arrays

#Arrays
declare -A arrayPID=()   # Array Associativo: Guarda as informações de cada processo, sendo a 'key' o PID
declare -A arrayOpc=()   # Array Associativo: Guarda a informação das opções passadas como argumentos na chamada da função
declare -A arrayRChar=() # Guarda as linhas rchar
declare -A arrayWChar=() # Guarda as linhas wchar

#-----------Definir variaveis-------------

TodayDate=$(date +"%s") #data atual em segundos
regexNum='^[0-9]+([.][0-9]+)?$'
regexDate='^((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)) +[0-9]{1,2} +[0-9]{1,2}:[0-9]{1,2}'
reverse=0
WOrdem=0
regexProc=/proc/
gamPidMin=0
gamPidMax=32768
gamPIdMax=4194304

#----------menu---------------
function menu() { # Menu de execução do programa.
    echo "------------------------  Menu de Execução do Programa  ------------------------"
    echo
    echo "             ~~~~~~~~~~~~~~~~~~~~~ Filtros  ~~~~~~~~~~~~~~~~~~~~~~      "
    echo " -c  -----> Seleção  dos  processos  a  visualizar  pode  ser  realizada através de uma expressão regular."
    echo " -s  -----> Seleção de processos a visualizar num periodo temporal - data mínima"
    echo " -e  -----> Seleção de processos a visualizar num periodo temporal - data máxima"
    echo " -u  -----> Seleção de processos a visualizar através do nome do utilizador"
    echo " -m  -----> Seleção de processos a visualizar através de uma gama de pids - minimo"
    echo " -M  -----> Seleção de processos a visualizar através de uma gama de pids - máximo"
    echo " -p  -----> Número de processos a visualizar"
    echo
    echo "        ~~~~~~~~~~~~~~~~  Ordenação (Escolher apenas uma)  ~~~~~~~~~~~~~        "
    echo " -r  -----> Ordenação reversa"
    echo " -w  -----> Ordenação da tabela por valores de escrita"
    echo
    echo " NOTA: o último argumento terá de ser o número de segundos pertendido"
    echo "-----------------------------------------------------------------------------"

}

#----------guardar e validar opcoes--------------
while getopts "c:s:e:u:m:M:rw" option; do

    #confere se o argumento passado não é uma suposta opção
    if [[ ${OPTARG:0:1} == - ]]; then
        echo "ERRO --> A opcao -$option requer um argumento"
        echo
        menu
        exit 1
    fi

    #Adiciona os value passados ao array argOpc com key option, caso nada seja passado adiciona o value "empty"
    if [[ -z "$OPTARG" ]]; then
        arrayOpc[$option]=empty
    else
        arrayOpc[$option]=${OPTARG}
    fi

    #----Tratamento de opcoes---

    case $option in
    c)
        #verifica se é uma string
        if [[ $OPTARG =~ $regexNum ]]; then
            echo "ERRO --> Insira uma expressão válida" >&2
            echo
            menu
            exit 1
        fi

        #Guarda a expressão regular
        expReg=$OPTARG
        ;;

    s)
        #verifica se é uma data
        if ! [[ "$OPTARG" =~ $regexDate ]]; then
            echo "ERRO --> Insira uma data válida" >&2
            echo $OPTARG
            echo
            menu
            exit 1
        fi

        #Guarda a data minima
        dateMin=$OPTARG
        ;;

    e)
        #verifica se é uma data
        if ! [[ $OPTARG =~ $regexDate ]]; then
            echo "ERRO --> Insira uma data válida" >&2
            echo
            menu
            exit 1
        fi

        #Guarda a data maxima
        dateMax=$OPTARG
        ;;

    u)
        #verifica se é uma string
        if [[ $OPTARG =~ $regexNum ]]; then
            echo "ERRO --> Insira um nome de utilizador válido" >&2
            echo
            menu
            exit 1
        fi

        #Guarda o nome de utilizador
        utilizador=$OPTARG
        ;;

    m)
        #verifica se é um número
        if ! [[ $OPTARG =~ $regexNum ]]; then
            echo "ERRO --> Insira um PID válido" >&2
            echo
            menu
            exit 1
        fi

        #Guarda o PID
        gamPidMin=$OPTARG
        ;;

    M)
        #verifica se é um número
        if ! [[ $OPTARG =~ $regexNum ]]; then
            echo "ERRO --> Insira um PID válido" >&2
            echo
            menu
            exit 1
        fi

        #Guarda o PID
        gamPidMax=$OPTARG
        ;;

    p)
        #verifica se é um número
        if ! [[ $OPTARG =~ $regexNum ]]; then
            echo "ERRO --> Insira uma número de processos válido" >&2
            echo
            menu
            exit 1
        fi

        #Guarda o PID
        nProc=$OPTARG
        ;;

    r)
        reverse=1
        ;;

    w)
        WOrdem=1
        ;;
    *)
        #O argumento passado não está listado
        echo "insira uma das opções listadas" >&2
        echo
        menu
        exit 1
        ;;
    esac
done

# ---------------- Validação dos argumetos passados --------------------

# Verifica se é passado como ultimo argumento o número de segundos
if ! [[ ${@: -1} =~ $regexNum ]]; then
    echo "ERRO --> Insira como último argumento o número de segundos que pertende"
    echo
    menu
    exit 1
fi

if [[ "$reverse" -eq 1 && "$WOrdem" -eq 1 ]]; then
    echo "ERRO --> Insira apenas uma ordem"
    echo
    menu
    exit 1
fi

#---------------------leitura de rchar e wchar---------------
function processos() {

    #ciclo for para ler todos os ficheiro dentro do diretório
    cd /proc
    for PID in $(ls -a); do
        #filtrar os ficheiros que não estão no format /proc/[PID]
        if [[ "$PID" =~ $regexNum && "$PID" -ge $gamPidMin && "$PID" -le $gamPidMax ]]; then
            echo $PID
            #ver se a file io e comm existe no diretorio PID
            if [[ -f "$PID/io" && -f "$PID/comm" ]]; then
                #ver se as files estão no modo reed
                if [[ -r "$PID/io" && -r "$PID/comm" ]]; then
                    echo puta
                fi
            fi
        fi
    done

}
processos
