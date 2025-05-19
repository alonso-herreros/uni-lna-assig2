#!/usr/bin/env bash

# USAGE: $0 <script_location> <test_name|'all'>

TEST_NAMES=( "listar1" "fecha1" "fecha2" "agregar1" "borrar1" "borrar2" )

TEST_ARGS_listar1=( "listar" )
TEST_ARGS_fecha1=( "fecha" "11/02/24" )
TEST_ARGS_fecha2=( "fecha" "10/02/24" )
TEST_ARGS_agregar1=( "agregar" "10/02/24" "natación" "recordar comprar gorro" )
TEST_ARGS_borrar1=( "borrar" "fecha" "10/02/24" )
TEST_ARGS_borrar2=( "borrar" "registro" "2" )

DATA_DIR="data"
ORIG_FILENAME="$DATA_DIR/agenda-orig.txt"

DEFAULT_FILENAME="agenda.txt"
OUTPUT_FILENAME="out.txt"

function run_standard_test() {
    test_name=$1

    expected_output_file="$DATA_DIR/$test_name-exp.txt"
    expected_file="$DATA_DIR/$test_name-exp-agenda.txt"

    declare -n args="TEST_ARGS_$test_name"

    cp "$ORIG_FILENAME" "$DEFAULT_FILENAME"

    # Run the test with args
    $script "${args[@]}" > "$OUTPUT_FILENAME"
    if [[ ! "$test_name" =~ ^(listar|fecha) ]]; then
        $script listar > "$OUTPUT_FILENAME"
    fi

    if [[ -f "$expected_file" ]] && \
            ! cmp -s "$DEFAULT_FILENAME" "$expected_file"
        then
        echo "[Test:$test_name] Final file different. Showing diff:"
        diff "$DEFAULT_FILENAME" "$expected_file"

    elif [[ -f "$expected_output_file" ]] && \
            ! cmp -s "$OUTPUT_FILENAME" "$expected_output_file"
        then
        echo "[Test:$test_name] Output is different. Showing diff:"
        diff "$OUTPUT_FILENAME" "$expected_output_file"

    else
        echo "[Test:$test_name] Success."

    fi

    rm "$DEFAULT_FILENAME" "$OUTPUT_FILENAME"
}

function run_options_test() {
    echo "Not yet implemented, sorry"
}

script="$1"
shift

if [[ "$1" == "all" ]]; then
    for test_name in ${TEST_NAMES[@]}; do
        echo "- Now running test '$test_name'"
        run_standard_test $test_name
        echo " "
    done

else
    test_name="$1"
    case "$test_name" in
        file ) run_options_test "file";;
        *) run_standard_test "$test_name";;
    esac
fi
