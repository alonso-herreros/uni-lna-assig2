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

            listar )
                action=list
                shift
                action_args="$@"
                ;;

            filtrar )
                [[ $# -lt 2 ]] && Wrong_exit
                action=filter
                shift
                action_args="$@"
                ;;

            agregar )
                [[ $# -lt 4 ]] && Wrong_exit
                action=add
                shift
                action_args="$@"
                ;;

            borrar )
                [[ $# -lt 3 ]] && Wrong_exit
                action=delete
                shift
                action_args="$@"
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
    echo "Not yet implemented"
}

function delete() {
    [[ $# -lt 2 ]] && Wrong_exit
    echo "Not yet implemented"
}

# ===== Main flow =====

# Variables
filename=$DEFAULT_FILENAME
action=""
action_args=""

args "$@"
$action "$action_args"
