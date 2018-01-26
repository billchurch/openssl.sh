#!/bin/bash

usage() {
  echo
  echo "Smartcard User Certificate Creator"
  echo
  echo "Description: creates a smartcard user certificate. Customization of the user"
  echo "  certificate is provided in the CONFIGS/openssl.USER.cnf file in the [ usr_cert ]"
  echo "  section."
  echo
  echo "Usage: $0 <certificate name> <CA Cert FQDN> <UPN@suffix> [sha256|sha1]"
  echo "  [rsa2048|rsa1024|rsa4096]"
  echo
  echo "   Ex. $0 joe.user ca.alpha.com 1234567890@alpha.com"
  echo
  exit
}

[ $# -lt 3 ] && usage
[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d USERCERTS/$2 ] && mkdir -p USERCERTS/$2
[ ! -f PROCESS/$2/index.txt ] && touch PROCESS/$2/index.txt
[ ! -f PROCESS/$2/index.txt.attr ] && touch PROCESS/$2/index.txt.attr
[ ! -f PROCESS/$2/serial ] && openssl rand -hex 16 > PROCESS/$2/serial
[ ! -f PROCESS/$2/serial ] && touch PROCESS/$2/$2.srl

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/^subject/s/^.*O=//p' | sed 's/\/.*$//'`
edipi=`echo $3 | grep -o "[[:alnum:]]*@" | sed -e 's/@//g'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_local
echo PROCESSPATH = $2 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = User Certificate >> CONFIGS/openssl_local
echo "COMMONNAMESTRING = Common Name (CN=subject.name.edipi)" >> CONFIGS/openssl_local
echo COMMONNAME = $1.$edipi >> CONFIGS/openssl_local
echo EMAIL = $1@$orgname >> CONFIGS/openssl_local
echo UPN = $3 >> CONFIGS/openssl_local
cat CONFIGS/openssl.USER.cnf >> CONFIGS/openssl_local

case $4 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA256"
  SHA="sha256"
  ;;
esac

echo

case $5 in
rsa1024) echo "Setting encryption algorithm to RSA1024"
  RSA="1024"
  ;;
rsa4096) echo "Setting encryption algorithm to RSA4096"
  RSA="4096"
  ;;
*) echo "Setting encryption algorithm to RSA2048"
  RSA="2048"
  ;;
esac

echo

openssl genrsa -out USERCERTS/$2/$1.key $RSA
openssl req -new -days 3650 -key USERCERTS/$2/$1.key -out USERCERTS/$2/$1.csr -config CONFIGS/openssl_local
openssl x509 -req -$SHA -days 3650 -CA CA/$2.cer -CAkey CA/$2.key -in USERCERTS/$2/$1.csr -CAserial PROCESS/$2/serial -extfile CONFIGS/openssl_local -extensions usr_cert -out USERCERTS/$2/$1.crt

rm USERCERTS/$2/*.csr
rm CONFIGS/openssl_local

echo
echo
echo -n "Do you want to create a PKCS12 version? y or n: "
read -n 1 if_pkcs12
echo
echo

[ "$if_pkcs12" == "y" ] && openssl pkcs12 -export -in USERCERTS/$2/$1.crt -inkey USERCERTS/$2/$1.key -out USERCERTS/$2/$1.p12

echo
echo
echo Complete.
echo -n "$1.crt, $1.key"
[ "$if_pkcs12" == "y" ] && echo -n ", and $1.p12"
echo
echo "Have been created and are in the USERCERTS/$2 folder"
