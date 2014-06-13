# Script para crear chroots de PHP-FPM

Contiene esmtp compilado estáticamente para poder enviar mails.  Esmtp
está licencia bajo GPL y el código fuente puede encontrarse en
data/\*.src.tar.gz


## Uso

    ./create-fpm-pool.sh ejemplo.org

## Qué hace

* Crea una cuenta ejemplo-org cuyo ~ es /srv/http/ejemplo.org
* Crea una jaula en /srv/http/ejemplo.org con archivos base del sistema
* Pone un cliente smtp en usr/bin/sendmail configurado para enviar
  correo localmente (si el postfix del sistema tiene habilitado
  permit_mynetworks, por ejemplo)
* Crea la configuración del pool de php-fpm (hay que reiniciar el
  servicio)

## Dónde van los archivos

En /srv/http/ejemplo.org/pub/

## Variables de entorno

* *GROUP:* cambia el grupo por defecto (http)
* *BASE:* cambia el directorio base por defecto (/srv/http)
* *POOLS:* ubicación de los pooles de php-fpm (/etc/php/fpm.d)

## Agregar programas

Lo mejor, pero no tan simple, es compilar los programas estáticamente
para poder copiarlos directamente a usr/bin/

De lo contrario hay que copiar los programas desde el sistema junto con
las librerías a usr/lib/

Para saber las librerías necesarias:

    ldd usr/bin/programa
