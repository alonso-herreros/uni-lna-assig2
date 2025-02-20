#!/usr/bin/env bash

# ===== Constants =====
DEFAULT_FILENAME="agenda.txt"

# ===== Help =====
USAGE="
Uso: $0 [OPCIONES] <ACCIÓN> [<ARGUMENTOS>]
       $0 -h

Opciones:
   -f, --file=FICHERO   Utiliza el fichero especificado. Por defecto el fichero
                        es 'agenda.txt'

Acciones:
    listar
        Lista el contenido de la agenda, segun el formato
        'n:dd/mm/yy Evento Comentario'
        donde 'n' es el numero de registro dentro del fichero

    fecha <fecha>
        Lista los eventos de la fecha dada, usando el formato dd/mm/yy.

    agregar <fecha> <evento> <comentario>
        Añade un nuevo evento con la información dada. La fecha debe estar
        en formato dd/mm/yy.

    borrar fecha <fecha>
        Elimina todos los registros correspondientes a una fecha en formato
        dd/mm/yy.

    borrar registro <n>
        Elimina el registro cuyo número es <n>
"

function Help() {
    echo "$USAGE"
}

function Help_exit() {
    Help
    exit 0
}

function Wrong() {
    echo "Uso incorrecto. Prueba a usar '$0 --help'"
}

function Wrong_exit() {
    Wrong
    exit 1
}

# ===== Argument parsing =====

function args() {
    # Parses args. May exit on errors or if the --help option is passed
    [[ $# -eq 0 ]] && Wrong_exit

    while [[ $# -ne 0 ]]; do
        case "$1" in

            -f | --file )
                [[ $# -lt 2 ]] && Wrong_exit
                filename="$2"
                shift 2
                ;;

            -h | --help )
                Help
                exit 0
                ;;

            listar | filtrar | agregar | borrar )
                action="$1"
                shift
                action_args="$@"
                break
                ;;

            * )
                Wrong
                exit 1
                ;;

        esac
    done
}

# ===== Specific functionality =====

function list() {
    cat $filename
    # TODO: prettify output
}

function filter() {
    [[ $# -lt 1 ]] && Wrong_exit

    list | grep "$1"
}

function add() {
    [[ $# -lt 3 ]] && Wrong_exit
    echo "Not yet implemented"
}

function delete() {
    [[ $# -lt 2 ]] && Wrong_exit
    echo "Not yet implemented"
}

function validate_date() {
    date "+%d/%m/%Y" -d "$1" >/dev/null 2>&1
}

# ===== Main flow =====

# Variables
filename=$DEFAULT_FILENAME
action=""
action_args=""

args "$@"

case $action in
    listar )  $action_function=list ;;
    filtrar ) $action_function=filter ;;
    agregar ) $action_function=add ;;
    borrar )  $action_function=delete ;;
    * ) Wrong_exit ;;
esac

$action_function "$action_args"
