#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

# System detection script
if_os () { [[ $OSTYPE == *$1* ]]; }
if_nix () { 
	case "$OSTYPE" in
		*linux*|*hurd*|*msys*|*cygwin*|*sua*|*interix*) sys="gnu";;
		*bsd*|*darwin*) sys="bsd";;
		*sunos*|*solaris*|*indiana*|*illumos*|*smartos*) sys="sun";;
	esac
	[[ "${sys}" == "$1" ]];
}
#

echo "You are running $OSTYPE"

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
files="vimrc tmux.conf bashrc config.fish"    # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
	echo "Moving any existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old/
	echo "Creating symlink to $file in home directory."
	if_os linux && ln -s $dir/linux/$file ~/.$file && echo "LINUX"
	if_os darwin && ln -s $dir/mac/$file ~/.$file && echo "MAC"
done
