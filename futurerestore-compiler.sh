#!/bin/zsh

cd "$(dirname "$0")"
# check homebrew
which brew
if [ $? -ne 0 ]; then
	echo "Homebrew not found, install it before running me!"
	exit
fi

if [[ $1 == *"--without-dependencies"* ]]; then
	echo WARNING: WILL NOT CLONE AND COMPILE DEPENDENCIES BEFORE COMPILING FUTURERESTORE
	echo YOU SHOULD ONLY SPECIFY THIS ARGUMENT IF YOUR COMPUTER HAS HAD ENOUGH DEPENDENCIES FOR COMPILING FUTURERESTORE
	echo OR ELSE THE PROCESS WILL FAIL
fi


if [[ $1 != *"--without-dependencies"* ]]; then

	if [[ $2 != *"--skip-brew"* ]]; then
		BREW_PACKAGE=("openssl" "libpng" "libzip" "libimobiledevice" "autoconf" "automake" "autogen" "libtool" "cmake" "coreutils")
		for PACKAGE in $BREW_PACKAGE; do
			echo
			echo Installing $PACKAGE
			brew install $PACKAGE
			brew link $PACKAGE
			echo
			echo Finished installing $PACKAGE
		done
	fi
	export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
	export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"
	# Gain sudo permission
	sudo -v

	# Clone dependencies
	DEPENDENCIES=("https://github.com/libimobiledevice/libplist" "https://github.com/libimobiledevice/libusbmuxd" "https://github.com/libimobiledevice/libirecovery" "https://github.com/libimobiledevice/libimobiledevice-glue" "https://github.com/nyuszika7h/xpwn" "https://github.com/tihmstar/libgeneral" "https://github.com/tihmstar/libfragmentzip" "https://github.com/tihmstar/libinsn" "https://github.com/tihmstar/img4tool" "https://github.com/Cryptiiiic/liboffsetfinder64" "https://github.com/Cryptiiiic/libipatcher")
	DIRECTORIES=("libimobiledevice-glue"  "libusbmuxd" "libplist" "libirecovery" "libgeneral" "libfragmentzip" "libinsn" "img4tool" "liboffsetfinder64" "libipatcher")
	RM=("libplist" "libusbmuxd" "libirecovery" "libgeneral" "libfragmentzip" "libinsn" "img4tool" "liboffsetfinder64" "libipatcher" "xpwn" "futurerestore" "libimobiledevice-glue")

	for DIR in $RM; do
		rm -rf $DIR
	done

	for REPO in $DEPENDENCIES; do
		git clone --recursive $REPO
	done


	# autogen

	for DIR in $DIRECTORIES; do
		echo
		echo Compiling $DIR
		if [ $DIR = "libipatcher" ]; then
			sudo rm -r /usr/local/include/xpwn
			mkdir -p /usr/local/include/xpwn &> /dev/null
			unzip -d /usr/local/include/xpwn xpwn/xpwn-modified-headers.zip
			unzip -d /usr/local/lib xpwnlibs.zip
		fi
		if [ $DIR = "liboffsetfinder64" ]; then
			cd $DIR
			./build.sh
			make -C cmake-build-debug install
			cd ../
			echo
			echo Finished compiling $DIR
			continue
		fi
		cd $DIR
		./autogen.sh --without-cython
		make
		make install
		cd ../
		echo
		echo Finished compiling $DIR
	done
fi

# Clone futurerestore
sudo rm -rf futurerestore &> /dev/null
sudo git clone --recursive https://github.com/futurerestore/futurerestore

echo
echo Compiling futurerestore
cd futurerestore
./build.sh -DARCH=x86_64
echo
echo Finished compiling futurerestore
echo Cleaning up
# Clean up
if [[ $3 != *"--no-cleanup"* ]]; then
	for DIR in $RM; do
		rm -rf $DIR
	done
fi
