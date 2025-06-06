#!/usr/bin/env bash

# ===== Constants =====
DEFAULT_FILENAME="agenda.txt"
DATE_PATTERN="[0-9]{2}/[0-9]{2}/[0-9]{2}" # dd/mm/yy

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

# Decided to make the base functions do just one thing.
# Since the most frequent use case is exiting right after, I added wrapper
# functions to also exit with the corresponding exit code.

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

    # I'm using getopt to allow options after (or even between) positional
    # arguments
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
    action_args=("$@") # Must be a list to pass it around properly later
}

# ===== Specific functionality =====

function list() {
    [[ -r "$filename" ]] || FileError_exit

    # Print line number and content, with semicolons replaced by tabs
    awk '{gsub(";","\t"); print NR ":" $0}' "$filename"
}

function filter() {
    [[ $# -eq 1 ]] && validate_date "$1" || Wrong_exit
    [[ -r "$filename" ]] || FileError_exit

    # Filter by the argument given, which we already checked for format
    list | grep "^[0-9]\+:$1"
}

function add() {
    # Used to check both separately, but they give the same error anyway...
    [[ $# -eq 3 ]] && validate_date "$1" || Wrong_exit
    touch "$filename" || FileError_exit

    # Date;Event;Comment
    echo "$1;$2;$3" >> "$filename"
}

function delete() {
    [[ $# -eq 2 ]] || Wrong_exit
    [[ -w "$filename" ]] || FileError_exit

    # Assigned to names for clarity
    mode=$1
    key=$2

    # Check the mode, and check that the key argument is as expected
    if [[ "$mode" == "registro" && "$key" =~ ^[0-9]+$ ]]; then
        # Simply delete that line
        sed -i "${key}d" "$filename"

    elif [[ "$mode" == "fecha" && "$key" =~ ^$DATE_PATTERN$ ]]; then
        # Delete the line starting with that date. Note that, due to having
        # slashes in $key, instead of using the standard / delimiter, I'm
        # using the custom | delimiter
        sed -i "\|^$key;|d" "$filename"

    # Anything that doesn't fall into the two double checks above is wrong
    else
        Wrong_exit

    fi
}

function validate_date() {
    [[ "$1" =~ ^$DATE_PATTERN$ ]] && date -d "$1" >/dev/null 2>&1
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
    fecha   ) filter "${action_args[@]}";;
    agregar ) add    "${action_args[@]}";;
    borrar  ) delete "${action_args[@]}";;

    *       ) Wrong_exit ;; # This also serves as a check for lack of action
esac
