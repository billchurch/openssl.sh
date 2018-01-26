#!/bin/bash

usage() {
  echo
  echo "Web Server Certificate Creator"
  echo
  echo "Description: creates a web server certificate. Customization of the web server"
  echo "  certificate is provided in the CONFIGS/openssl.WEBSERVER.cnf file in the [ v3_ca ]"
  echo "  section."
  echo
  echo "Usage: $0 <certificate name> <CA Cert Name> [sha256|sha1]"
  echo "  [rsa2048|rsa1024|rsa4096]"
  echo
  echo "   Ex. $0 webserver1.alpha.com ca.alpha.com"
  echo
  echo
  exit
}

[ $# -lt 2 ] && usage

[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d SERVERCERTS/$2 ] && mkdir -p SERVERCERTS/$2
[ ! -f PROCESS/$2/index.txt ] && touch PROCESS/$2/index.txt
[ ! -f PROCESS/$2/serial ] && openssl rand -hex 16 > PROCESS/$2/serial

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/^subject/s/^.*O=//p' | sed 's/\/.*$//'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $2 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = Web Server Certificate >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=server.domain.com)" >> CONFIGS/openssl_local
echo COMMONNAME = $1 >> CONFIGS/openssl_local
cat CONFIGS/openssl.WEBSERVER.cnf >> CONFIGS/openssl_local

case $3 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA1"
  SHA="sha256"
  ;;
esac

case $4 in
rsa1024) echo "Setting encryption algorithm to RSA1024"
  RSA="1024"
  ;;
rsa4096) echo "Setting encryption algorithm to RSA2048"
  RSA="4096"
  ;;
*) echo "Setting encryption algorithm to RSA2048"
  RSA="2048"
  ;;
esac

openssl genrsa -out SERVERCERTS/$2/$1.key $RSA
openssl req -new -config CONFIGS/openssl_local -days 1024 -key SERVERCERTS/$2/$1.key -out SERVERCERTS/$2/$1.csr
openssl x509 -req -$SHA -days 1024 -CA CA/$2.cer -CAkey CA/$2.key -in SERVERCERTS/$2/$1.csr -CAserial PROCESS/$2/serial -extfile CONFIGS/openssl_local -extensions v3_ca -out SERVERCERTS/$2/$1.crt

rm SERVERCERTS/$2/*.csr
rm CONFIGS/openssl_local

echo
echo
echo -n "Do you want to create a PKCS12 version? y or n: "
read -n 1 if_pkcs12
echo
echo

[ "$if_pkcs12" == "y" ] && openssl pkcs12 -export -in SERVERCERTS/$2/$1.crt -inkey SERVERCERTS/$2/$1.key -out SERVERCERTS/$2/$1.p12

echo
echo
echo Complete.
echo -n "$1.crt, $1.key"
[ "$if_pkcs12" == "y" ] && echo -n ", and $1.p12"
echo
echo "Have been created and are in the SERVERCERTS/$2 folder"
