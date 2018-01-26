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

# Instructions

1. Make a self-signed root: ./make.caroot.sh ca.test.lab
2. Make a subordinate signing CA: ./make.casub.sh sub-ca.test.lab ca.test.lab
3. Make a server cert using the subordinate ca: ./make.webserver.sh webserver.test.lab sub-ca.test.lab
4. Make a subordinate signing CA for your users: ./make.casub.sh user-ca.test.lab ca.test.lab
5. Make a user/smartcard certificate using your user-ca: ./make.user.sh joe.user user-ca.test.lab 0123456789@mil

# Notes

The certificate authorities are all created with a password of "password" if ever prompted, the password should be password. You can change by modifying the templates in CONFIGS.
