# cryptographic-examples

Examples of AES 256 encryption and decryption and interoperation between:
* Ruby (openssl from standard library),
* Javascript (CryptoJS),
* and Shell (openssl).

The examples are the specs.

# AES Encryption

* key and iv are derived from the password and salt.
TODO

# Ruby

openssl is part of the standard library.

```ruby
require 'openssl'
```
Various ciphers are available.

Ruby can encrypt and decrypt using a password and salt, or
the a key and iv (initialization vector).

Unfortunately, to use password and salt, you have to use the
deprecated method `pkcs5_keyivgen` which uses non-standard
techniques.

# Command line: the openssl binary

The openssl library has an `enc` command that handles encryption and decryption.
* the ciphertext is Base64 encoded,
* the ciphertext consists of 3 parts:
  * the text `Salted__`,
  * the salt,
  * the encryted text.

When using a salt (the default), `enc`  prefixes the ciphertext with the string
`Salted__` followed by the 8 bytes of the salt.

```shell
$ echo -n 'ciao' | openssl enc -aes-256-cbc -pass pass:"passwordpasswordpasswordpassword" -e -base64 -p
salt=9BEE1E50DC27B678
key=FA348E60F18A35D9CF7B5B38D402B6DF3815D8C351F8AB95D41AEB50B3809D1F
iv =04801487B6EC101DA97CA430271838C0
U2FsdGVkX1+b7h5Q3Ce2eCoUbiDYbWVfs/TnWBVIbY4=
```

The command can optionally output the key and iv used.
* salt, key and iv are output as hex,

# Javascript: CryptoJS

CryptoJS can handle encryption and decryption both using a password and salt
and with a key an iv.

Password decryption can handle ciphertext produced by the openssl binary,
which has the salt included as bytes 9 - 16.

The library has a structure called a "Word Array", which keys and ivs
must be converted in order to be used.

# Dependencies

You need to have bower (and nodejs and npm) installed.
To install bower *globally* do this:

```shell
sudo npm install -g bower
```

# Setup

```shell
bundle
bower install
```
