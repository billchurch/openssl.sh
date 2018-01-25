!/bin/bash

usage() {
  echo Certificate Signer
  echo
  echo "Description: Signs a certificate request with a specified CA certificate."
  echo "  Customization of the web server certificate is provided in the"
  echo "  CONFIGS/openssl.WEBSERVER.cnf file in the [ v3_ca ] section."
  echo
  echo "Usage: $0 <certificate name> <CA Cert Name> [sha256|sha1]"
  echo
  echo "   Ex. $0 /tmp/webserver1.alpha.com.csr ca.alpha.com"
  echo
  exit
}

[ $ -lt 2 ] && usage
[[ ! -f CA/$2.cer && ! -f CA/$2.key ]] && echo CA $2 does not exist && exit
[ ! -d SERVERCERTS/$2 ] && mkdir SERVERCERTS/$2
[ ! -f PROCESS/$2/index.txt ] && touch PROCESS/$2/index.txt
[ ! -f PROCESS/$2/serial ] && echo -n 01 > PROCESS/$2/serial

orgname=`openssl x509 -noout -subject -in CA/$2.cer | sed -n '/subject/s/.*O=//p' | sed 's///.*$//'`

[ -f CONFIGS/openssl_local ] && rm CONFIGS/openssl_localecho PROCESSPATH = $2 >> CONFIGS/openssl_local
echo ORGNAME = $orgname >> CONFIGS/openssl_local
echo ORGUNITNAME = Web Server Certificate >> CONFIGS/openssl_local
echo COMMONNAMESTRING = Common Name (CN=server.domain.com) >> CONFIGS/openssl_local
echo COMMONNAME = $1 >> CONFIGS/openssl_local
cat CONFIGS/openssl.SIGNCERT.cnf >> CONFIGS/openssl_local

case $3 in
sha1) echo "Setting hashing algorithm to SHA1"
  SHA="sha1"
  ;;
*) echo "Setting hashing algorithm to SHA1"
  SHA="sha256"
  ;;
esac

openssl x509 -req -$SHA -days 1024 -CA CA/$2.cer -CAkey CA/$2.key -in $1 -CAserial PROCESS/$2/serial -extfile CONFIGS/openssl_local -extensions v3_ca -out SERVERCERTS/$2/$1.crt

echo
echo
echo Complete.
echo Certificate in SERVERCERTS/$2/$1.crt
