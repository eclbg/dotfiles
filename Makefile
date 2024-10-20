##All `get` commands update the local config with the config from the repo. We first backup the original files into the `backups` directory of this repository. The idea is to not commit these backups
##All `put` commands do the opposite: copy the local config here, so we can add the changes to the repo
##All `diff` commands show the diff between the local (first arg) and repo (second arg) configs
##
help:          ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

get-karabiner: ##
	mv --backup=numbered ~/.config/karabiner/karabiner.json backups/
	cp karabiner/karabiner.json ~/.config/karabiner/karabiner.json
put-karabiner: ##
	cp ~/.config/karabiner/karabiner.json karabiner/karabiner.json
diff-karabiner: ##
	-diff ~/.config/karabiner/karabiner.json karabiner/karabiner.json

get-kitty:     ## Only conf, no themes for now
	mv --backup=numbered ~/.config/kitty/kitty.conf backups/
	cp kitty/kitty.conf ~/.config/kitty/kitty.conf
put-kitty:     ## Only conf, no themes for now
	cp ~/.config/kitty/kitty.conf kitty/kitty.conf
diff-kitty:     ## Only conf, no themes for now
	-diff ~/.config/kitty/kitty.conf kitty/kitty.conf

get-skhd: ##
	mv --backup=numbered ~/.config/skhd/skhdrc backups/
	cp skhd/skhdrc ~/.config/skhd/skhdrc
put-skhd: ##
	cp ~/.config/skhd/skhdrc skhd/skhdrc
diff-skhd: ##
	-diff ~/.config/skhd/skhdrc skhd/skhdrc

get-starship:  ##
	mv --backup=numbered ~/.config/starship.toml backups/
	cp starship/starship.toml ~/.config/starship.toml
put-starship:  ##
	cp ~/.config/starship.toml starship/starship.toml
diff-starship:  ##
	-diff ~/.config/starship.toml starship/starship.toml

get-tmux: ##
	mv --backup=numbered ~/.config/tmux/tmux.conf backups/
	cp tmux/tmux.conf ~/.config/tmux/tmux.conf
put-tmux: ##
	cp ~/.config/tmux/tmux.conf tmux/tmux.conf
diff-tmux: ##
	-diff ~/.config/tmux/tmux.conf tmux/tmux.conf

get-yabai: ##
	mv --backup=numbered ~/.config/yabai/yabairc backups/
	cp yabai/yabairc ~/.config/yabai/yabairc
put-yabai: ##
	cp ~/.config/yabai/yabairc yabai/yabairc
diff-yabai: ##
	-diff ~/.config/yabai/yabairc yabai/yabairc

get-zsh: ##
	mv --backup=numbered ~/.zshrc backups/
	cp zsh/.zshrc ~/.zshrc
put-zsh: ##
	cp ~/.zshrc zsh/zshrc
diff-zsh: ##
	-diff ~/.zshrc zsh/zshrc

get-ipython: ##
	cp ipython/ipython_config.py ~/.ipython/profile_default/ipython_config.py
	cp ipython/keybindings.py ~/.ipython/profile_default/startup/keybindings.py
