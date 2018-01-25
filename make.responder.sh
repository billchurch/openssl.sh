#!/bin/bash

usage() {
  echo  OpenSSL OCSP Server
  echo
  echo  Description: provides a simple OpenSSL OCSP server.
  echo
  echo  "Usage:  $0 <CA Cert full name> <Signing Certificate> <Port number>"
  echo
  echo    Ex. $0 crl.alpha.com ocsp1.alpha.com 8888
  echo
  echo
  exit
}

[ $# -lt 2 ] && usage

[[ ! -f CA/$1.cer && -f CA/$1.key ]] && echo CA $1 does not exist && exit
[[ ! -f SERVERCERTS/$1/$2.crt && ! -f SERVERCERTS/$1/$2.key ]] && echo "SERVERCERTS/$1/$2.(crt|key) signing cert|key does not exist" && exit
[ ! -f PROCESS/$1/index.txt ] && echo "Revocation database PROCESS/$1/index.txt does not exist." && exit

while true; do
  openssl ocsp -index PROCESS/$1/index.txt -CA CA/$1.cer -rsigner SERVERCERTS/$1/$2.crt -rkey SERVERCERTS/$1/$2.key -port $3
  echo
  echo recycling...
  echo
done
