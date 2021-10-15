# How to use Split GPG with Subkeys

## What is Split GPG?

Split GPG is a software alternative to keeping your main keypair on a separate device. Instead of using a physical USB drive, Split GPG utilizes non-networked qubes to store the keys. For more in-depth explanation, [refer to the official docs](https://www.qubes-os.org/doc/split-gpg/).

### Simple diagram of Split GPG
![Split GPG diagram. work-email qube calls a function that grabs the key from another qube, work-gpg, when it needs to use the key](https://www.qubes-os.org/attachment/doc/split-gpg-diagram.png)
<sup>[Source](https://www.qubes-os.org/attachment/doc/split-gpg-diagram.png)</sup>

## What are subkeys?

Subkeys are essentially children keys of the main keypair. The advantage is they can be revoked independently without needing to revoke your main. The drawback is you can have many subkeys for signing, but only 1 for encrypting. [See the Debian wiki on subkeys, especially the Caveats section](https://wiki.debian.org/Subkeys)

## How to setup Split GPG with subkeys

### Prerequisites
1. Follow the official Split GPG documentation on setting up Split GPG first: https://www.qubes-os.org/doc/split-gpg/#configuring-split-gpg

#### One possible key distribution

| Key type | VM location | Note             |
|:---------|:------------|:-----------------|
| sec      | vault       | Main secret key. Should be tarballed and stored, not actively on the keychain   |
| pub      | vault       | Main public key. You can use this if you want, but if you sign with a subkey (ssb) it cannot be verified with the main public key. If you don't use it, may as well keep it in the vault. |
| ssb      | gpg-store   | Secret subkey. Only accessed with Split GPG commands where needed. `gpg` VM is not connected to the internet. |
| sub      | personal    | Public subkey. Can be freely distributed  |


<sup>[Setup without subkeys](https://www.qubes-os.org/doc/split-gpg/#setup-description)</sup>


### Create main key

Skip to [Create Subkey](#create-subkey) if you already have a key.

In `vault`, create the main keypair, subkeys, and a revocation certificate.

```
[user@vault ~]$ gpg --full-generate-key
Real name: alice
Email address: alice@example.net
You selected this USER-ID:
    "alice <alice@example.net>"
[...]
```

### Create Subkey
Use `gpg -K` to find your key-id and name. Here the name is `alice`.

```
[user@vault ~]$ gpg --edit-key alice
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
  (14) Existing key from card
Your selection? 4
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Wed Oct 10 00:00:00 2022 PDT
Is this correct? (y/N) y
Really create? (y/N) y
```

Create revocation cert:
```
[user@vault ~]$ gpg --output alice_revocation.cert --gen-revoke alice
```

Backup keys and revocation cert, then shred the exported keys:
```
[user@vault ~]$ gpg --export-secret-keys --armor alice > alice_secret.key
[user@vault ~]$ gpg --export --armor alice > alice_public.key
[user@vault ~]$ tar -cf backup_alice_keys.tar alice* 
[user@vault ~]$ shred -u alice*
```
The main key is still in the keyring. Export its subkeys in a temp file, delete the main key from the keyring, then import the subkeys. Be sure to delete `subkeys` after importing.
```
[user@vault ~]$ gpg --export-secret-subkeys alice > subkeys
[user@vault ~]$ gpg --delete-secret-key alice
[user@vault ~]$ gpg --import subkeys
[user@vault ~]$ shred -u subkeys
```

To verify you're using the correct key, run `gpg -K` and ensure you see a `#` next to your secret key. Such as:
```
[user@vault ~]$ gpg -K
 /home/alice/.gnupg/ring.gpg
 -----------------------------
 sec# 4096R/[...]
 [...]
```

Export the public and secret key to `gpg-store` (or whatever your gpg VM is).
```
[user@vault ~]$ gpg --export-secret-keys --armor alice > alice_secret.key
[user@vault ~]$ gpg --export --armor alice > alice_public.key
[user@vault ~]$ qvm-copy alice_*.key
```
At the prompt, select `gpg-store` as the destination.

Now import the public and secret keys into `gpg-store`, then delete them.
```
[user@gpg-store ~]$ cd ~/QubesIncoming/vault
[user@gpg-store QubesIncoming/vault]$ gpg --import alice_*.key
[user@gpg-store QubesIncoming/vault]$ shred -u alice_*.key
```
Finally, in `personal`, import the public key from `gpg-store`
```
[user@gpg-store ~]$ qubes-gpg-client-wrapper --armor --export alice > alice_public.asc
[user@gpg-store ~]$ gpg --import alice_public.asc
```
