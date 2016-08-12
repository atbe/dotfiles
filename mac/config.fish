##############################################################################
#   Filename: config.fish                                                    #
# Maintainer: Ibrahim Ahmed <abeahmed2@gmail.com>                            #
#        URL: http://github.com/atbe/dotfiles                                #
#                                                                            #
#                                                                            #
# Sections:                                                                  #
#   01. General ................. General Fish behavior                      #
#   02. Program Specific......... CLI Program Configurations                 #
##############################################################################

##############################################################################
# 01. General                                                                #
##############################################################################

##############################################################################
# 02. Program Specific                                                       #
##############################################################################

# Fish
#
# Path to Oh My Fish install.
set -gx OMF_PATH "/Users/abe/.local/share/omf"
#`
# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "/Users/abe/.config/omf"
#
# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# homebrew
#
# brew command-not-found
brew command command-not-found-init > /dev/null; and . (brew command-not-found-init)

# source the aliases.fish config
. "$HOME/.config/fish/aliases.fish"

# autojump config
 [ -f /usr/local/share/autojump/autojump.fish  ]; and source /usr/local/share/autojump/autojump.fish
