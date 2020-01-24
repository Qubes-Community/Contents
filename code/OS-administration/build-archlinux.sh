#!/bin/bash
BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
directory=$BASE/qubes-builder
sudo rm -Rf "$directory"
sudo dnf install wget make git qubes-gpg-split
git clone "https://github.com/QubesOS/qubes-builder.git"

key1=$(curl -s https://keys.qubes-os.org/keys/qubes-master-signing-key.asc | sha512sum | cut -d " " -f 1)
key2=$(sha512sum /usr/share/qubes/qubes-master-key.asc | cut -d " " -f 1)

if [ "$key1" != "$key2" ]; then
	echo "CRITICAL SECURITY FAILURE: qubes master signing key is not the same on different source (local and official qubes os website)" >&2
  exit 1
fi

gpg --import /usr/share/qubes/qubes-master-key.asc
echo "Check the key, if it is good for you, set the trust to 5 and exit"
echo "fpr" | gpg --edit-key 0x427F11FD0FAA4B080123F01CDDFA1A3E36879494

wget https://keys.qubes-os.org/keys/qubes-developers-keys.asc
gpg --import qubes-developers-keys.asc

commit_data=$(cd "$directory" && git tag -v $(git describe) 2>&1 | grep "gpg: ")
echo "$commit_data"
echo "$commit_data"  | tail -n 1 | grep "Good signature from "
success=$?

if (( $success == 1 )); then 
  echo "CRITICAL SECURITY FAILURE: last commit from qubes-builder is not signed with an approved gpg key" >&2
  exit 1
fi

echo "Does this seems good to you ?"
read trash

cp $directory/example-configs/qubes-os-r4.0.conf $directory/builder.conf
sed -i 's/DISTS_VM ?=.*/DISTS_VM ?= archlinux+minimal/' $directory/builder.conf
sed -i 's/#COMPONENTS += builder-archlinux/COMPONENTS += builder-archlinux/g' $directory/builder.conf
sed -i 's/#BUILDER_PLUGINS += builder-archlinux/BUILDER_PLUGINS += builder-archlinux/g' $directory/builder.conf

( cd "$directory" && make get-sources )
( cd "$directory" && make install-deps )

# If you need to use some custom version, you can do a copy and replace like the
# line below
# cp -R ~/qubes-gui-agent-linux "$directory/qubes-src/gui-agent-linux"
# This is really usefull when the template building fail and that you are trying
# fixes to make it work
#rm -Rf "$directory/qubes-src/gui-agent-linux/"
#cp -R ~/qubes-gui-agent-linux "$directory/qubes-src/gui-agent-linux"

cd "$directory"
make qubes-vm
make template

# At this point, the packages and the template have been build and are ready to be used.
# The code below will sign everything with your GPG key then copy the result to another VM
# The goal is to create a archlinux repository, to update the
# qubes specific packages using "pacman -Syu".
# My personal webserver hosting the package I compile is here: https://neowutran.ovh/qubes/vm-archlinux/

echo "Read to type your password ? "
read trash

$directory/qubes-src/builder-archlinux/update-remote-repo.sh
rpmfile=$(ls -1 $directory/qubes-src/linux-template-builder/rpm/noarch/*.rpm | head -n 1)
qubes-gpg-client-wrapper --detach-sign $rpmfile > $rpmfile.sig
qvm-copy $rpmfile
qvm-copy $rpmfile.sig
qvm-copy $directory/qubes-packages-mirror-repo/vm-archlinux/pkgs/
