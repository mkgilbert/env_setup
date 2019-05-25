#!/bin/bash
# Note: run this as root or with sudo!

# install dependencies
echo "installing dependencies..."
yum install -y epel-release ruby ruby-devel lua lua-devel luajit \
	luajit-devel ctags git python python-devel \
	python3 python3-devel tcl-devel \
	perl perl-devel perl-ExtUtils-ParseXS \
	perl-ExtUtils-XSpp perl-ExtUtils-CBuilder \
	perl-ExtUtils-Embed > /dev/null

if [ "$?" != "0" ]; then
	echo "Error building dependencies"
	exit 1
fi

# get the source
[ -e vim ] && rm -rf vim
echo -n "cloning vim repo..."
git clone https://github.com/vim/vim.git > /dev/null
echo "done"
echo "configuring vim"
sleep 1
cd vim
./configure --with-features=huge \
            --enable-multibyte \
	    --enable-rubyinterp=yes \
	    --enable-pythoninterp=yes \
	    --with-python-config-dir=/lib64/python2.7/config \ # pay attention here check directory correct
	    --enable-python3interp=yes \
	    --with-python3-config-dir=/usr/lib/python3.6/config \
	    --enable-perlinterp=yes \
	    --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
	   --prefix=/usr/local

echo "done"
echo "running make"
sleep 1
make VIMRUNTIMEDIR=/usr/local/share/vim/vim81 && make install
[ "$?" != "0" ] && echo "Error running make...exiting" && exit 1
echo DONE
