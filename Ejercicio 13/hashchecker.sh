#!/usr/bin/env bash

# ==== Usage ====
USAGE="
Uso:    $0 -f <FICHERO> <COMANDO> [DIRECTORIOS]
        $0 -h

COMANDOS

    Se debe seleccionar un único comando en la ejecución del script.

  -n, --new             Establece el modo de creación sobre el directorio o los
                        directorios especificados como parámetros posicionales.
  -c, --check           Establece el modo de comprobación.
  -h, --help            Muestra este mensaje y no realiza ninguna operación.

OPCIONES

  -f, --file <FICHERO>  Selecciona el fichero de resúmenes para leer/escribir.
                        Esta opción es obligatoria
"

OPTSTRING="hf:nc"
OPTSTRING_LONG="help,file:,new,check"


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

function new_checksums_file() {
    # File errors will be reported automatically if there's a problem

    find "${targets[@]}" -type f -exec sha256sum "{}" \; > "$checksums_file"
}

function check_checksums_file () {
    # File errors will be reported automatically if there's a problem
    [[ -r "$checksums_file" ]] || FileError_exit "$checksums_file"

    if sha256sum -c "$checksums_file" >/dev/null 2>&1; then
        echo "No se han detectado cambios"
    else
        echo "Se han detectado cambios"
    fi
}

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
                shift;;

            -c | --check )
                [[ -n "$action" ]] && Wrong_exit # Mutually exclusive options
                action="check"
                shift;;

            # End of options
            --) shift; break;;
        esac
    done

    # All positional parameters are assumed to be the target dirs for the
    # 'new' command
    targets=("$@");
}

# ==== Main flow ====

# Options. Just listing them here, since there are no defaults
checksums_file=
action=
targets=

# Parse args and set options
args "$@"

[[ -z "$checksums_file" || -z "$action" ]] && Wrong_exit

case "$action" in
    new) new_checksums_file;;
    check) check_checksums_file;;
esac
