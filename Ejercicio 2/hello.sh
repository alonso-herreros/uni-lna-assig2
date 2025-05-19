#!/usr/bin/env bash

#====================================================================
# Administracion de Redes Linux - Ejercicios sobre bash
# Ejercicio 2: Información sobre el sistema
#
# Profesora: Iria Manuela Estévez Ayres
# Alumno: Alonso Herreros Copete
#====================================================================

# ==== Instrucciones =====

# ---- Plantilla ----

# Hola <Nombre_usuario>!
#
# Soy <Nombre_script>, mi PID es <Número_proceso>
# el PID de mi proceso padre es <Número_proceso_del_proceso_padre>.
# Ahora es: <día_y_hora>
# En UTC: <día_y_hora_en_utc>
#
# Me has invocado con <Número_argumentos> argumentos, que son:
# Todos: <todos los argumentos>
# <Argumentos_recibidos cada uno en una línea con el formato Arg[i] = argumento>
# En orden inverso: <todos en orden inverso y como un array separado por comas>
#
# Estás en el ordenador <Nombre_ordenador>,
# con IP <dirección_ip_ordenador>
# que es un <Tipo_ordenador>
# usando el sistema operativo <Sistema_operativo>,
# con núcleo <nombre_núcleo>
# versión del núcleo (versión) <version_del_núcleo>
# (release) <release_del_núcleo>
#
# Tu identificador es <Identificador_usuario>
# tu directorio personal es <Directorio_raíz_usuario>
# y tu PATH: <Variable_PATH_usuario>
# Estás trabajando en el directorio <directorio_en_el_que_se_encuentra>
# El anterior directorio donde trabajaste es <directorio_anterior>

# ===== Respuesta =====

# ----- Intro -----
cat <<EOF
Hola $USER!

Soy $0, mi PID es $$
el PID de mi proceso padre es $PPID
Ahora es: $(date)
En UTC: $(date -u)

EOF

# ----- Args -----
echo "Me has invocado con $# argumentos, que son:"
echo "Todos: $*"

for ((i=1; i<=$#; i++)); do
    echo "Arg[$i] = ${!i}"
done

echo -n "En orden inverso y como array con comas: {"
for ((i--; i>0; i--)); do
    echo -n "${!i}"
    [[ $i -gt 1 ]] && echo -n ", " || break;
done
echo "}"
echo ""

# ----- System -----
cat <<EOF
Estás en el ordenador $HOSTNAME
Con IP: $(hostname -I)
Que es un $(uname -m)
Usando el sistema operativo $(uname -o)
Con núcleo $(uname -s)
Versión del núcleo (versión) $(uname -v)
(release) $(uname -r)

EOF

# ----- User and state -----
cat <<EOF
Tu identificador es $UID
Tu directorio personal es $HOME
y tu PATH: $PATH

Estás trabajando en el directorio $PWD
El anterior directorio donde trabajaste es $OLDPWD

EOF
