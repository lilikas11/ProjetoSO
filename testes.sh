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

#expReg = "*"

function menu() { # Menu de execução do programa.
    echo "------------------------  Menu de Execução do Programa  ------------------------"
    echo
    echo "        ~~~~~~~~~~~~~~~~  Filtros  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~        "
    echo " -c  -----> Seleção  dos  processos  a  visualizar  pode  ser  realizada através de uma expressão regular."
    echo " -s  -----> Seleção de processos a visualizar num periodo temporal - data mínima"
    echo " -e  -----> Seleção de processos a visualizar num periodo temporal - data máxima"
    echo " -u  -----> Seleção de processos a visualizar através do nome do utilizador"
    echo " -m  -----> Seleção de processos a visualizar através de uma gama de pids"
    echo " -M  -----> Seleção de processos a visualizar através de uma gama de pids"
    echo " -p  -----> Número de processos a visualizar"
    echo
    echo "        ~~~~~~~~~~~~~~~~  Ordenação (Escolher apenas uma)  ~~~~~~~~~~~~~        "
    echo " -r  -----> Ordenação reversa"
    echo " -w  -----> Ordenação da tabela por valores de escrita"
    echo
    echo " NOTA: o último argumento terá de ser o número de segundos pertendido"

}
while getopts "c:s:e:u:m:M:rw" option; do

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

    echo ${OPTARG:0:1}

done

# ---------------- Validação dos argumetos passados --------------------

# Verifica se o ultimo argumento é um número
if ! [[ ${@: -1} =~ $re ]]; then
    echo "Insira como último argumento o número de segundos que pertende"
    menu
    exit 1
fi
