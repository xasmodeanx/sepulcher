# Sepulcher
A docker tomb for your encrypted messages built from
* [webstore](https://github.com/Fullaxx/webstore)
* [gnupg](https://gnupg.org/)

## Base Docker Image
[Ubuntu](https://hub.docker.com/_/ubuntu) 20.04 (x64)

## Get the image from Docker Hub or build it yourself
```
docker pull fullaxx/sepulcher
docker build -t="fullaxx/sepulcher" github.com/Fullaxx/sepulcher
```

## Launch Sepulcher Docker Container
```bash
docker run -it \
-v /srv/docker/alice/gnupg:/root/.gnupg \
-v /srv/docker/alice/xfer:/root/xfer \
fullaxx/sepulcher
```

## Generate your GPG identity
```bash
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
```bash
# gpg2 --armor --output alice.asc --export 951D7434D9DD329BC695BD3690B8A2BADF61CAF3

# ws_post.exe -c -v -s -H keys.dspi.org -P 443 -a 4 -f alice.asc
Compressing: 3134 bytes
Uploading: 2981 bytes
Token: 258c5a8abc050d9f4a3c60674ea3b9808b2b8c3b6a6195e22f46325670d3cb7d
```

## Download and Import a published identity
```bash
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
```bash
# echo "This is a message for Bob" >msg_for_bob.txt

# gpg2 --output msg_for_bob.gpg --encrypt --recipient XbobX msg_for_bob.txt

# ws_post.exe -v -s -H msgs.dspi.org -P 443 -a 6 -f msg_for_bob.gpg
Uploading: 786 bytes
Token: 11cf1c5f3155319e86f733c05c041ea578c55ed283d81b21a9a3049cb04d1ad349632e5b3e82366071b3af44d060a7093a8364a7dc2aa769cca46f97daa19686
```

## Retrieve and Decrypt a message
```bash
# ws_get.exe -s -H msgs.dspi.org -P 443 -t 11cf1c5f3155319e86f733c05c041ea578c55ed283d81b21a9a3049cb04d1ad349632e5b3e82366071b3af44d060a7093a8364a7dc2aa769cca46f97daa19686 -f msg_for_bob.gpg

# gpg2 --output msg_for_bob.txt --decrypt msg_for_bob.gpg
gpg: encrypted with 4096-bit RSA key, ID 44851B4FAD37B260, created 2021-01-30
      "XbobX <XbobX@gmail.com>"

# cat msg_for_bob.txt
This is a message for Bob
```
