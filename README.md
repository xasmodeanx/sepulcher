# Sepulcher
A docker tomb for your encrypted messages built from
* [webstore](https://github.com/Fullaxx/webstore)
* [gnupg](https://gnupg.org/)

## About this Software
Sepulcher is designed for those who want full control over their communications.
It provides an alternative to typical key/message distribution methods.
For example, maybe you don't want your public key made available to the everyone.
Maybe you want to distribute a different set of keys to different recipients.
Maybe you don't want all your encrypted communications left in your inbox until the end of time.
Sepulcher facilitates the distribution of encrypted data on systems that you control.

## Base Docker Image
[Ubuntu](https://hub.docker.com/_/ubuntu) 20.04 (x64)

## Get the image from Docker Hub or build it yourself
```
docker pull fullaxx/sepulcher
docker build -t="fullaxx/sepulcher" github.com/Fullaxx/sepulcher
```

## Launch Sepulcher Docker Container
```
docker run -it \
-v /srv/docker/alice/gnupg:/root/.gnupg \
-v /srv/docker/alice/xfer:/root/xfer \
fullaxx/sepulcher
```

## Generate your GPG identity
```
# gpg2 --full-gen-key
Real name: Alice
Email address: alice@gmail.com
Comment:
You selected this USER-ID:
    "Alice <alice@gmail.com>"
...
pub   rsa4096 2021-01-30 [SC] [expires: 2021-04-30]
      951D7434D9DD329BC695BD3690B8A2BADF61CAF3
uid                      Alice <alice@gmail.com>
sub   rsa4096 2021-01-30 [E] [expires: 2021-04-30]
```

## Export and Publish your GPG identity
Alice will export her public key and publish it to the keyserver. \
The final token can be given out at her discretion.
```
# gpg2 -a -o alice.asc --export 951D7434D9DD329BC695BD3690B8A2BADF61CAF3

# ws_post.exe -c -v -s -H keys.dspi.org -P 443 -a 4 -f alice.asc
Compressing: 3134 bytes
Uploading: 2981 bytes
Token: 258c5a8abc050d9f4a3c60674ea3b9808b2b8c3b6a6195e22f46325670d3cb7d
```

## Download and Import a published identity
We assume that Bob followed the above example and published his public key. \
Bob will gave Alice the token: 30970b83c47b03cd2c3ea36439bea1d7886a6e538e6a24cd2fa0f929848ee62f
```
# ws_get.exe -s -H keys.dspi.org -P 443 -t 30970b83c47b03cd2c3ea36439bea1d7886a6e538e6a24cd2fa0f929848ee62f -f bob.asc

# gpg2 --import bob.asc
gpg: key F128878CD6EAEE8B: public key "XbobX <XbobX@gmail.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1

# gpg2 --fingerprint F128878CD6EAEE8B
pub   rsa4096 2021-01-30 [SC] [expires: 2021-04-30]
      7341 95A1 AA90 088B EE71  96D1 F128 878C D6EA EE8B
uid           [  full  ] XbobX <XbobX@gmail.com>
sub   rsa4096 2021-01-30 [E] [expires: 2021-04-30]

# gpg2 --sign-key F128878CD6EAEE8B
```

## Encrypt and Publish a message
Now that Alice has a public key for Bob, she can encrypt a msg to Bob. \
After she publishes her message, she can send Bob the token.
```
# echo "This is a message for Bob" >msg_for_bob.txt

# gpg2 -o msg_for_bob.gpg -r XbobX -s -e msg_for_bob.txt

# ws_post.exe -v -s -H msgs.dspi.org -P 443 -a 6 -f msg_for_bob.gpg
Uploading: 786 bytes
Token: 11cf1c5f3155319e86f733c05c041ea578c55ed283d81b21a9a3049cb04d1ad349632e5b3e82366071b3af44d060a7093a8364a7dc2aa769cca46f97daa19686
```

## Retrieve and Decrypt a message
Bob will use the token he got from Alice to retrieve and decrypt the message.
```
# ws_get.exe -s -H msgs.dspi.org -P 443 -t 11cf1c5f3155319e86f733c05c041ea578c55ed283d81b21a9a3049cb04d1ad349632e5b3e82366071b3af44d060a7093a8364a7dc2aa769cca46f97daa19686 -f msg_for_bob.gpg

# gpg2 -o msg_for_bob.txt -d msg_for_bob.gpg
gpg: encrypted with 4096-bit RSA key, ID 44851B4FAD37B260, created 2021-01-30
      "XbobX <XbobX@gmail.com>"

# cat msg_for_bob.txt
This is a message for Bob
```

## More Info
* [GnuPG User Guides](https://www.gnupg.org/documentation/guides.html)
* A Practical Guide to GPG: 
[P1](https://www.linuxbabe.com/security/a-practical-guide-to-gpg-part-1-generate-your-keypair) /
[P2](https://www.linuxbabe.com/security/a-pratical-gpg-guide-part-2-encrypt-and-decrypt-message) /
[P3](https://www.linuxbabe.com/security/a-practical-guide-to-gpg-part-3-working-with-public-key) /
[P4](https://www.linuxbabe.com/security/a-practical-guide-to-gpg-part-4-digital-signature)
