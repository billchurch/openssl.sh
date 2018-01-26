#!/bin/bash

usage() {
  echo
  echo "Self-Signed Root CA Certificate Creator"
  echo
  echo "Description: Creates a self-signed root CA certificate. Customization of the CA"
  echo "  certificate is provided in the CONFIGS/openssl.CAROOT.cnf file in the [ v3_ca ]"
  echo "  section."
  echo
  echo "Usage: $0 <certificate FQDN> [sha256|sha1] [rsa2048|rsa1024|rsa4096]"
  echo
  echo "   Ex. $0 ca.alpha.com"
  echo
  echo
  exit
}

[ $# -lt 1 ] && usage
[ ! -d PROCESS/$1 ] && mkdir -p PROCESS/$1
[ ! -d CA ] && mkdir CA
[ ! -f PROCESS/$1/index.txt ] && touch PROCESS/$1/index.txt
[ ! -f PROCESS/$1/serial ] && openssl rand -hex 16  > PROCESS/$1/serial

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo "PROCESSPATH = $1" >> CONFIGS/openssl_local
echo "ORGUNITNAME = Certificate Authority" >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=)" >> CONFIGS/openssl_local
echo "COMMONNAME = $1" >> CONFIGS/openssl_local
cat CONFIGS/openssl.CAROOT.cnf >> CONFIGS/openssl_local

case $2 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA256"
  SHA="sha256"
  ;;
esac

echo

case $3 in
rsa1024) echo "Setting encryption algorithm to RSA1024"
  RSA="rsa:1024"
  ;;
rsa4096) echo "Setting encryption algorithm to RSA2048"
  RSA="rsa:4096"
  ;;
*) echo "Setting encryption algorithm to RSA2048"
  RSA="rsa:2048"
  ;;
esac

echo

openssl req -new -x509 -$SHA -days 3650 -newkey $RSA -keyout CA/$1.key -out CA/$1.cer -config CONFIGS/openssl_local

rm CONFIGS/openssl_local

echo
echo
echo Complete.
echo $1.cer and $1.key have been created and are in the CA folder
