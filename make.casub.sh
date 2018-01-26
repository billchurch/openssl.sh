#!/bin/bash

usage() {
  echo "Subordinate CA Certicate Creator"
  echo
  echo "Description: creates subordinate CA certicates. Customization of the subordinate"
  echo "  certicate is provided in the CONFIGS/openssl.CASUB.cnf file in the [ v3_ca ]"
  echo "  section."
  echo
  echo "Usage: $0 <certicate fqdn> <CA Cert Name> [[sha1|sha256]"
  echo "  [rsa2048|rsa1024|rsa4096]]"
  echo
  echo "   Ex. $0 sub-ca1.alpha.com ca.alpha.com"
  echo
  echo
  exit
}

[ $# -lt 2 ] && usage

[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -f PROCESS/$2/index.txt ] && touch PROCESS/$2/index.txt
[ ! -f PROCESS/$2/serial ] && openssl rand -hex 16 > PROCESS/$2/serial
[ ! -d PROCESS/$1 ] && mkdir PROCESS/$1
[ ! -f PROCESS/$1/index.txt ] && touch PROCESS/$1/index.txt
[ ! -f PROCESS/$1/serial ] && openssl rand -hex 16 > PROCESS/$1/serial

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/^subject/s/^.*O=//p' | sed 's/\/.*$//'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $1 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = Subordinate Authority >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=server.domain.com)" >> CONFIGS/openssl_local
echo COMMONNAME = $1 >> CONFIGS/openssl_local
cat CONFIGS/openssl.CASUB.cnf >> CONFIGS/openssl_local

case $3 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA256"
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

openssl genrsa -out CA/$1.key $RSA
openssl req -new -config CONFIGS/openssl_local -days 1024 -key CA/$1.key -out CA/$1.csr
openssl x509 -req -$SHA -days 1024 -CA CA/$2.cer -CAkey CA/$2.key -in CA/$1.csr -CAserial PROCESS/$1/serial -extfile CONFIGS/openssl_local -extensions v3_ca -out CA/$1.cer

rm CA/*.csr
# rm CONFIGS/openssl_local

echo
echo
echo Complete.
echo $1.cer and $1.key have been created and are in the CA folder

