#!/bin/bash

usage() {
  echo "OCSP Signing Certificate Creator"
  echo
  echo "Description: creates an OCSP signing certificate for use with an OCSP responder."
  echo "  Customiization of the OCSP signing certificate is provided in the"
  echo "  CONFIGS/openssl.OCSP.cnf file in the [ v3_ca ] section."
  echo
  echo "Usage: $0 <certificate name> <CA Cert Name> [sha256|sha1]"
  echo "  [rsa2048|rsa1024|rsa4096]"
  echo
  echo "   Ex. $0 ocsp1.alpha.com ca.alpha.com"
  echo
  exit
}

[ $# -lt 2 ] && usage

[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d SERVERCERTS/$2 ] && mkdir SERVERCERTS/$2
[ ! -f PROCESS/$2/index.txt ] && touch PROCESS/$2/index.txt
[ ! -f PROCESS/$2/serial ] && echo -n 01 > PROCESS/$2/serial

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/^subject/s/^.*O=//p' | sed 's/\/.*$//'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $2 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = OCSP Signing Certificate >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=server.domain.com)" >> CONFIGS/openssl_local
echo COMMONNAME = $1 >> CONFIGS/openssl_local
cat CONFIGS/openssl.OCSP.cnf >> CONFIGS/openssl_local

case $3 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA256"
  SHA="sha256"
  ;;
esac
echo
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
echo
openssl genrsa -out SERVERCERTS/$2/$1.key $RSA
openssl req -new -config CONFIGS/openssl_local -days 3650 -key SERVERCERTS/$2/$1.key -out SERVERCERTS/$2/$1.csr
openssl x509 -req -$SHA -days 1024 -CA CA/$2.cer -CAkey CA/$2.key -in SERVERCERTS/$2/$1.csr -CAserial PROCESS/$2/serial -extfile CONFIGS/openssl_local -extensions v3_ca -out SERVERCERTS/$2/$1.crt

rm SERVERCERTS/$2/*.csr
rm CONFIGS/openssl_local
echo
echo -n "Do you want to create a PKCS12 version? y or n: "
read -n 1 if_pkcs12
echo
echo

echo Complete.
echo -n "$1.crt, $1.key"
[ "$if_pkcs12" == "y" ] && echo -n ", and $1.p12"
echo
echo "Have been created and are in the USERCERTS/$2 folder."
