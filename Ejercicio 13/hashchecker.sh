#!/usr/bin/env bash

# ==== Usage ====
USAGE="
Uso:    $0 -f <FICHERO> <COMANDO>
        $0 -h

COMANDOS

    Se debe seleccionar un único comando en la ejecución del script.

  -n, --new <DIRS>      Establece el modo de creación sobre el directorio o los
                        directorios especificados.
  -c, --check           Establece el modo de comprobación
  -h, --help            Muestra este mensaje y no realiza ninguna otra operación.

OPCIONES

  -f, --file <FICHERO>  Muestra este mensaje. Esta opción es obligatoria
"

OPTSTRING="hf:n:c"
OPTSTRING_LONG="help,file:,new:,check"


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
    echo "El fichero '$1' no existe o no tienes los permisos necesarios"
}

function FileError_exit() {
    FileError "$1"
    exit 1
}


# ==== Specifics ====



# ==== Argument parsing ====

function args() {
    # Parses args. May exit on errors or if the --help option is passed

    local options=$(getopt -o "$OPTSTRING" --long "$OPTSTRING_LONG" -- "$@")
    eval set -- "$options"

    while true; do
        case "$1" in
            -h | --help ) Help_exit;;

            # Existence and permissions will be checked later
            -f | --file ) checksums_file="$2"; shift 2;;

            # Actions
            -n | --new )
                [[ -n "$action" ]] && Wrong_exit # Mutually exclusive options
                action="new"
                dirs="$2"
                shift 2;;

            -c | --check ) [ -action ]
                [[ -n "$action" ]] && Wrong_exit # Mutually exclusive options
                action="check"
                shift;;

            # End of options
            --) shift; break;;
        esac
    done
}

# ==== Main flow ====

# Options. Just listing them here, since there are no defaults
checksums_file=
action=
dirs=

# Parse args and set options
args "$0" "$@"
