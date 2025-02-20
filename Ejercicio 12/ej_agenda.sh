#!/usr/bin/env bash

# ===== Constants =====
DEFAULT_FILENAME="agenda.txt"

OPTSTRING="hf:"
OPTSTRING_LONG="help,file:"

# ===== Help =====
USAGE="
Uso: $0 [OPCIONES] <ACCIÓN> [<ARGUMENTOS>]
       $0 -h

Opciones:
  -f, --file <FICHERO>      Utiliza el fichero especificado. Por defecto el
                            fichero es 'agenda.txt'

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

function FileError() {
    echo "El fichero '$filename' no existe o no tienes los permisos necesarios"
}

function FileError_exit() {
    FileError
    exit 1
}

# ===== Argument parsing =====

function args() {
    # Parses args. May exit on errors or if the --help option is passed

    # --- Options and flags ---
    local options=$(getopt -o "$OPTSTRING" --long "$OPTSTRING_LONG" -- "$@")
    eval set -- "$options"

    # Most people use 'while true', but I don't trust myself
    while [[ $# -ne 0 ]]; do
        case "$1" in
            -h | --help ) Help_exit;;

            # If the value is wrong, so be it. We'll notice.
            -f | --file ) filename="$2"; shift 2;;

             # End of options
            -- ) shift; break;;
        esac
    done

    # --- Positional arguments ---
    action="$1"
    shift
    action_args=("$@")
}

# ===== Specific functionality =====

function list() {
    [[ -r "$filename" ]] || FileError_exit

    cat $filename
    # TODO: prettify output
}

function filter() {
    [[ $# -ne 1 ]] && Wrong_exit
    [[ -r "$filename" ]] || FileError_exit

    list | grep "$1"
}

function add() {
    [[ $# -ne 3 ]] && Wrong_exit
    touch "$filename" || FileError_exit

    date="$1"
    event="$2"
    comment="$3"

    validate_date $date || Wrong_exit

    echo "$date;$event;$comment" >> "$filename"
}

function delete() {
    [[ $# -ne 2 ]] && Wrong_exit
    [[ -w "$filename" ]] || FileError_exit

    echo "Not yet implemented"
}

function validate_date() {
    [[ "$1" =~ ^([0-9]{2}/){2}[0-9]{4}$ ]] && date -d "$1" >/dev/null 2>&1
}

# ===== Main flow =====

# Variables
filename=$DEFAULT_FILENAME
action=""
action_args=""

args "$@"

# Resolve action 'names' to their functions, and call them
case $action in
    listar  ) list;;
    filtrar ) filter "${action_args[@]}";;
    agregar ) add    "${action_args[@]}";;
    borrar  ) delete "${action_args[@]}";;

    *       ) Wrong_exit ;; # This also serves as a check for lack of action
esac

# Call the function we got earlier with its arguments
# $action_function "${action_args[@]}"
