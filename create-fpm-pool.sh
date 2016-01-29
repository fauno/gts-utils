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
DIRECTORY="${BASE:-/srv/http}/${NAME}"
LIB="${LIB:-/lib}"

# la jaula ya existe
test -f "${DIRECTORY}/.jail" && exit 1

useradd --comment "PHP-FPM Jail" \
        --home-dir "${DIRECTORY}" \
        --no-create-home \
        --shell /bin/false \
        --gid ${GROUP} \
        ${USER}

sed -e "s|{{NAME}}|$NAME|g" \
    -e "s|{{GROUP}}|$GROUP|g" \
    "${CUR}/"data/pool.conf >"${POOLS}/${NAME}.conf"

# asegurar que no se pueda escapar de la jaula
install -dm 555 -g root -o root "${DIRECTORY}"

# comenzar
pushd "${DIRECTORY}" &>/dev/null

# crear directorios base y pub que es donde van los archivos php
install -dm 755 -g root -o root {etc,tmp,usr/{lib,bin},pub}
install -dm 111 -g root -o root dev
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
ldconfig -p | grep -E "/libnss_(files|dns)" | cut -d ">" -f2 \
| sort -u | while read nss; do
  cp --archive --dereference "${nss}" usr/lib/
done

# generar un passwd especifico
install -Dm444 "${CUR}/"data/passwd etc/passwd
grep "^${USER}:" /etc/passwd >>etc/passwd

# generar un group especifico
install -Dm444 "${CUR}/"data/group etc/group
sed -i "s/{{USER}}/$USER/g" etc/group

# instalar shell estatica
install -Dm555 "${CUR}/"data/dash usr/bin/sh

# instalar esmtp estático como sendmail
install -Dm444 "${CUR}/"data/esmtprc etc/esmtprc
install -Dm555 "${CUR}/"data/sendmail usr/bin/sendmail

# permitir trabajar sobre pub
chown -R ${USER}:${GROUP} pub/
chmod -R g+s pub/
chmod -R u+s pub/
chmod -R 750 pub/

# engañar a php-fpm
# TODO esto es un misterio, porque dandole DOCUMENT_ROOT=/pub y
# SCRIPT_FILENAME=/pub/index.php a php-fpm deberia bastar, pero aun asi
# intenta buscar las cosas en /srv/http...
install -dm755 -o root -g root "${CUR}${CUR}"
ln -s ../../../pub "${CUR}${CUR}/pub"

# crear archivos especiales
mknod dev/null c 1 3
mknod dev/random c 1 8
mknod dev/urandom c 1 9
chmod 666 dev/null
chmod 444 dev/{u,}random

# copiar timezones
install -dm755 -o root -g root usr/share/zoneinfo
cp -a /usr/share/zoneinfo usr/share/

# crear directorio de sesiones
install -dm755 -o root -g root var/lib/php5
install -dm1733 -o root -g root var/lib/php5/sessions
ln -s php5 var/lib/php

install -dm751 -o root -g root usr/lib/locale
cp -a /usr/lib/locale/locale-archive usr/lib/locale/

# limpiar las sesiones
if ! test -f /etc/cron.d/php-fpm-sessions ; then
  echo "09,39 * * * * root find ${BASE:-/srv/http}/*/var/lib/php5/sessions -name 'sess_*' -type f -cmin +24 -print0 | xargs -0 rm" >/etc/cron.d/php-fpm-sessions
  chmod 700 /etc/cron.d/php-fpm-sessions
  chown root:root /etc/cron.d/php-fpm-sessions
fi

touch .jail
