#!/bin/bash

usage() {
  echo Certificate Revocation List Creator
  echo
  echo Description: creates certificate revocation lists.
  echo
  echo "Usage: $0 <CRL name> <CA Cert full name>"
  echo
  echo "   Ex. $0 crl.alpha.com ca.alpha.com"
  echo
  echo
  exit
}

[ $# -lt 2 ] && usage
[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d CRLS/$2 ] && mkdir -p CRLS/$2
[ ! -f PROCESS/$2/index.txt ] && echo -n 2 > PROCESS/$2/index.txt
[ ! -f PROCESS/$2/serial ] && echo 01 > PROCESS/$2/serial

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $2 >> CONFIGS/openssl_local
echo CERTIFICATE = ./CA/$2.cer >> CONFIGS/openssl_local
echo PRIVATE_KEY = ./CA/$2.key >> CONFIGS/openssl_local
echo CRL = null >> CONFIGS/openssl_local
cat CONFIGS/openssl.CRL.cnf >> CONFIGS/openssl_local

openssl ca -gencrl -config CONFIGS/openssl_local -out CRLS/$2/$1.crl.pem

rm CONFIGS/openssl_local

echo
echo -n "Do you want to create a DER version? y or n: "
read -n 1 if_der
echo
[ "$if_der" == "y" ] && openssl crl -in CRLS/$2/$1.crl.pem -outform DER -out CRLS/$2/$1.crl
echo
echo Complete.
echo -n "CRLS/$2/$1.pem"
[ "$if_der" == "y" ] && echo -n " and CRLS/$2/$1.crl" && echo && echo -n "Have" || echo && echo -n "Has"
echo " been created."
