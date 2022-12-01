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

function menu() { # Menu de execução do programa.
    echo "------------------------  Menu de Execução do Programa  ------------------------"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~  Filtros  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo " -c  -----> Seleção  dos  processos  a  visualizar  pode  ser  realizada através de uma expressão regular."
    echo " -s  -----> Seleção de processos a visualizar num periodo temporal - data mínima"
    echo " -e  -----> Seleção de processos a visualizar num periodo temporal - data máxima"
    echo " -u  -----> Seleção de processos a visualizar através do nome do utilizador"
    echo " -m  -----> Seleção de processos a visualizar através de uma gama de pids"
    echo " -M  -----> Seleção de processos a visualizar através de uma gama de pids"
    echo " -p  -----> Número de processos a visualizar"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~  Ordenação (Escolher apenas uma)  ~~~~~~~~~~~~~~~~~~~~~"
    echo " -r  -----> Ordenação reversa"
    echo " -w  -----> Ordenação da tabela por valores de escrita"
    echo " NOTA: o último argumento terá de ser número de segundos"

}
menu