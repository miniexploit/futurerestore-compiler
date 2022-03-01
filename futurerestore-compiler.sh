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

# Clone dependencies
DEPENDENCIES=("https://github.com/libimobiledevice/libplist" "https://github.com/libimobiledevice/libusbmuxd" "https://github.com/libimobiledevice/libirecovery" "https://github.com/nyuszika7h/xpwn" "https://github.com/tihmstar/libgeneral" "https://github.com/tihmstar/libfragmentzip" "https://github.com/tihmstar/libinsn" "https://github.com/tihmstar/img4tool" "https://github.com/Cryptiiiic/liboffsetfinder64" "https://github.com/Cryptiiiic/libipatcher")
DIRECTORIES=("libplist" "libusbmuxd" "libirecovery" "libgeneral" "libfragmentzip" "libinsn" "img4tool" "liboffsetfinder64" "libipatcher")

for DIR in $DIRECTORIES; do
	rm -rf $DIR
done

for REPO in $DEPENDENCIES; do
	git clone --recursive $REPO
done

# Install dependencies
# brew


BREW_PACKAGE=("libpng" "libzip")
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
		cp xpwn/includes/* libipatcher/include/
	fi
	cd $DIR
	./autogen.sh
	make
	cd ../
	echo
	echo Finished installing $DIR
done

# Clone futurerestore
rm -rf futurerestore &> /dev/null
if [ $choice = "1" ]; then
	git clone -b test --recursive https://github.com/m1stadev/futurerestore
elif [ $choice = "2" ]; then
	git clone -b test --recursive https://github.com/Mini-Exploit/futurerestore
else
	echo Invalid input
	exit
fi

echo
echo Building futurerestore
cd futurerestore
./autogen.sh
make
echo
echo Finished building futurerestore
rm /usr/local/bin/futurerestore
cp futurerestore/futurerestore /usr/local/bin
echo You can now call futurerestore by running \"futurerestore\"

