#!/bin/bash

usage() {
  echo "Cross-Certification Utility"
  echo
  echo "Description: allows for the cross-certificate of CA certificates."
  echo "  Customization of the cross-certified certificate is provided in the"
  echo "  CONFIGS/openssl.CROSSCERT.cnf file in the [ v3_ca] section."
  echo
  echo "Usage: $0 <signee certificate> <signer certificate>"
  echo
  echo "   Ex. $0 ca.alpha.com ca.bravo.com"
  echo
  exit
}

[ $# -lt 2 ] && usage

[[ ! -f CA/$1.cer && ! -f CA/$1.key ]] && echo CA $1 does not exist && exit
[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d PROCESS/$1 ] && mkdir PROCESS/$1
[ ! -f PROCESS/$1/index.txt ] && echo -n 2 > PROCESS/$1/index.txt
[ ! -s PROCESS/$1/serial ] && openssl rand -hex 16 > PROCESS/$1/serial
[ ! -s PROCESS/$2/serial ] && openssl rand -hex 16 > PROCESS/$2/serial

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/^subject/s/^.*O=//p' | sed 's/\/.*$//'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $1 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = Certificate Authority >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=)" >> CONFIGS/openssl_local
echo COMMONNAME = $1 >> CONFIGS/openssl_local
cat CONFIGS/openssl.CROSSCERT.cnf >> CONFIGS/openssl_local

openssl req -new -config CONFIGS/openssl_local -key CA/$1.key -out CA/$1.csr
openssl x509 -req -CA CA/$2.cer -CAkey CA/$2.key -in CA/$1.csr -CAserial PROCESS/$2/serial -extfile CONFIGS/openssl_local -extensions v3_ca -out CA/x-$1.crt

rm CA/$1.csr
rm CONFIGS/openssl_local

echo
echo Complete.
echo x-$1.crt was created and is in the CA folder
