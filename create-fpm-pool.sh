#!/bin/bash

POOL_PATH="/etc/php5/fpm/pool.d"
JAILS_PATH="/srv/jails"
OUT_PATH=""

echo "Creando pool de PHP-FPM"

NAME=""
CONFIRM=0
CREATE_JAIL=0
NGINX_CONF=0

while [ $CONFIRM -eq 0 ]; do

    while [ -z $NAME  ]; do
        read -p "Nombre: " NAME

        if [ -f "${POOL_PATH}/${NAME}.conf" ]; then
            echo "Ese pool ya existe"
            NAME=""
        fi

    done

    read  -p "Usuario [www-data]: " USER

    if [ -z $USER ]; then
        USER="www-data"
    fi

    read -p "Grupo [www-data]: " GROUP

    if [ -z $GROUP ]; then
        GROUP="www-data"
    fi

    read -p "Escucha en... [/var/run/php5-fpm-\$pool.sock]: " LISTEN

    if [ -z $LISTEN ]; then
        LISTEN="/var/run/php5-fpm-\$pool.sock"
    fi

    read -p "Jail [ninguna]: " JAIL

    if [ ! -z $JAIL ]; then

        if [ ! -d "${JAILS_PATH}/${JAIL}" ]; then
            read -p "Jail $JAIL no existe, crear? (y/n) " CC
            if [ $CC == "y" ]; then
               CREATE_JAIL=1
           fi

       fi

    fi

#    read -p "Crear configuración de Nginx? (y/n) " NC

#    if [ $NC -eq "y" ]; then
#        NGINX_CONF=1
#    fi

    CONFIRM=1

done

TFILE=/tmp/$(date +%Y%m%d%H%s)

cp data/pool.conf $TFILE

sed -i "s/\\{\\{NAME\\}\\}/$NAME/g" $TFILE
sed -i "s/\\{\\{USER\\}\\}/$USER/g" $TFILE
sed -i "s/\\{\\{GROUP\\}\\}/$GROUP/g" $TFILE
sed -i "s/\\{\\{LISTEN\\}\\}/$LISTEN/g" $TFILE

if [ -z $JAIL ]; then
    JAILP="/"
else
    JAILP="${JAILS_PATH}/${JAIL}"
fi

sed -i "s/\\{\\{CHROOT\\}\\}/$JAILP/g" $TFILE

DEST="${OUT_PATH}${POOL_PATH}/${NAME}.conf"

if [ ! -d "${OUT_PATH}${POOL_PATH}" ]; then
    mkdir -p "${OUT_PATH}${POOL_PATH}"
fi

echo "Copiando archivo de pool to $DEST"

mv $TFILE $DEST

if [ $CREATE_JAIL -eq 1 ]; then
    echo "Creando JAIL"
    ./create-php-jail.sh $JAIL
fi

echo "Listo"
