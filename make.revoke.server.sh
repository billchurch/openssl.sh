#!/bin/bash

usage() {
  echo
  echo  "Server Certificate Revocation Utility"
  echo
  echo  "Description: revokes Server certificates."
  echo
  echo  "Usage: $0 <certificate name> <CA Cert full name> <CRL full name>"
  echo
  echo  "   Ex. $0 webserver.alpha.com ca.alpha.com crl.alpha.com"
  echo
  exit
}

[ $# -lt 3 ] && usage

[ ! -d CRLS/$2 ] && mkdir CRLS/$2
[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -f CRLS/$2/$3.crl ] && echo CA/CRL CRLS/$2/$3.crl does not exist && exit
[ ! -f SERVERCERTS/$2/$1.crt ] && echo Server cert SERVERCERTS/$2/$1.crt does not exist && exit

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $2 >> CONFIGS/openssl_local
echo CERTIFICATE = ./CA/$2.cer >> CONFIGS/openssl_local
echo PRIVATE_KEY = ./CA/$2.key >> CONFIGS/openssl_local
echo CRL = ./CRLS/$2/$3.crl >> CONFIGS/openssl_local
cat CONFIGS/openssl.REVOKEUSER.cnf >> CONFIGS/openssl_local

openssl ca -config CONFIGS/openssl_local -revoke SERVERCERTS/$2/$1.crt
openssl ca -gencrl -config CONFIGS/openssl_local -out CRLS/$2/$3.crl.pem
openssl crl -in CRLS/$2/$3.crl.pem -outform DER -out CRLS/$2/$3.crl

rm CONFIGS/openssl_local

echo
echo Complete.
echo Certificate for user $1 has been marked revoked in CA $2
echo A new CRL has been created at CRLS/$2/$3.crl
