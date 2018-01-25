# openssl.sh
Bash scripts to make maintianing an OpenSSL CA for testing and lab environments easier.

Adapted from Windows OpenSSL scripts from Kevin Stewart (k.stewart@f5.com).

# Usage

* make.caroot.sh - Make a self-signed root CA certificate
* make.casub.sh - Make a subordinate CA certificate
* make.webserver.sh - Make a web server certificate
* make.ocspsign.sh - Make an OCSP signing certificate
* make.user.sh - Make a smartcard user certificate
* make.revoke.user.sh - Revoke a user certificate
* make.revoke.server.sh - Revoke a server certificate
* make.crl.sh - Create a new certificate revocation list
* make.responder.sh - Start a simple OpenSSL OCSP responder
* make.crosscert.sh - Cross-certify a CA certificate
