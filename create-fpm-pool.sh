#!/bin/bash
set -e

CUR="$(dirname "$(readlink -f "$0")")"
POOLS="${POOLS:-/etc/php/fpm.d/}"

NAME="$1"
# convertir ejemplo.org a ejemplo-org
USER="${1//\./-}"
# el sistema tiene un límite de usuario de 31-32 caracteres
USER="${USER:0:30}"
GROUP=${GROUP:-http}
DIRECTORY=/srv/http/${NAME}

# la jaula ya existe
test -f "${DIRECTORY}/.jail" && exit 1

useradd --comment "PHP-FPM Jail" \
        --home-dir "/srv/http/${NAME}" \
        --no-create-home \
        --shell /bin/false \
        --gid ${GROUP} \
        ${USER}

sed -e "s|{{NAME}}|$NAME|g" \
    -e "s|{{GROUP}}|$GROUP|g" \
    "${CUR}/"data/pool.conf >"${POOLS}/${NAME}.conf"

# asegurar que no se pueda escapar de la jaula
install -dm 755 -g root -u root "${DIRECTORY}"

# comenzar
pushd "${DIRECTORY}" &>/dev/null

# crear directorios base y pub que es donde van los archivos php
install -dm 755 -g root -u root {etc,tmp,usr/{lib,bin},dev,pub}
# symlinks
ln -s usr/bin bin
ln -s usr/lib lib

# TODO montar como tmpfs
chmod a+rw tmp
chmod a+t  tmp
chmod u+s  tmp

# copiar archivos del sistema
cp --archive --dereference /etc/localtime etc/
cp --archive /etc/{hosts,nsswitch.conf,resolv.conf} etc/
cp --archive --dereference /lib/libnss_files* usr/lib/
cp --archive --dereference /lib/libnss_dns* usr/lib/

# generar un passwd especifico
cp "${CUR}/"data/passwd etc/
grep "^${USER}:" /etc/passwd >>etc/passwd

# generar un group especifico
cp "${CUR}/"data/group etc/
sed -i "s/{{USER}}/$USER/g" etc/group

chmod 644 etc/{group,passwd}

# permitir trabajar sobre pub
chown -R ${USER}:${GROUP} pub/
chmod -R g+s pub/
chmod -R u+s pub/
chmod -R 750 pub/

# crear archivos especiales
mknod dev/null c 1 3
mknod dev/random c 1 8
mknod dev/urandom c 1 9
chmod 666 dev/{null,random,urandom}

touch .jail
