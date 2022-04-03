#!/bin/zsh


# check homebrew
which brew
if [ $? -ne 0 ]; then
	echo "Homebrew not found, install it before running me!"
	exit
fi

echo Select 1 of these repositories below to install
echo "[1] https://github.com/m1stadev/futurerestore"
echo "[2] https://github.com/Mini-Exploit/futurerestore"
read choice

if [ $choice = "1" ] || [ $choice = "2" ]; then
	true
else
	echo Invalid input
	exit
fi

# Clone dependencies
DEPENDENCIES=("https://github.com/libimobiledevice/libplist" "https://github.com/libimobiledevice/libusbmuxd" "https://github.com/libimobiledevice/libirecovery" "https://github.com/libimobiledevice/libimobiledevice-glue" "https://github.com/nyuszika7h/xpwn" "https://github.com/tihmstar/libgeneral" "https://github.com/tihmstar/libfragmentzip" "https://github.com/tihmstar/libinsn" "https://github.com/tihmstar/img4tool" "https://github.com/Cryptiiiic/liboffsetfinder64" "https://github.com/Cryptiiiic/libipatcher")
DIRECTORIES=("libplist" "libusbmuxd" "libirecovery" "libgeneral" "libfragmentzip" "libinsn" "img4tool" "liboffsetfinder64" "libipatcher" "libimobiledevice-glue")
RM=("libplist" "libusbmuxd" "libirecovery" "libgeneral" "libfragmentzip" "libinsn" "img4tool" "liboffsetfinder64" "libipatcher" "xpwn" "futurerestore" "libimobiledevice-glue")

for DIR in $RM; do
	rm -rf $DIR
done

for REPO in $DEPENDENCIES; do
	git clone --recursive $REPO
done

# Install dependencies
# brew


BREW_PACKAGE=("libpng" "libzip" "openssl" "libimobiledevice")
for PACKAGE in $BREW_PACKAGE; do
	echo
	echo Installing $PACKAGE
	brew install $PACKAGE
	echo
	echo Finished installing $PACKAGE
done

# autogen

for DIR in $DIRECTORIES; do
	echo
	echo Building $DIR
	if [ $DIR = "libipatcher" ]; then
		cp -r xpwn/includes/* libipatcher/include/
	fi
	cd $DIR
	./autogen.sh
	make
	sudo make install
	cd ../
	echo
	echo Finished installing $DIR
done

# Clone futurerestore
rm -rf futurerestore &> /dev/null
if [ $choice = "1" ]; then
	sudo git clone -b test --recursive https://github.com/futurerestore/futurerestore
elif [ $choice = "2" ]; then
	sudo git clone -b test --recursive https://github.com/Mini-Exploit/futurerestore
fi

echo
echo Building futurerestore
cd futurerestore
sudo ./autogen.sh --prefix=/usr/local
sudo make
sudo make install
echo
echo Finished compiling futurerestore
echo You can now call futurerestore by running \"futurerestore\"

