##All `get` commands update the local config with the config from the repo. We first backup the original files into the `backups` directory of this repository. The idea is to not commit these backups
##All `put` commands do the opposite: copy the local config here, so we can add the changes to the repo
##All `diff` commands show the diff between the local (first arg) and repo (second arg) configs
##
export PATH := /opt/homebrew/opt/coreutils/libexec/gnubin:$(PATH)
help:          ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

get-all: get-atuin get-kitty get-skhd get-starship get-yabai get-zsh get-tmux ##

get-atuin: ##
	mkdir -p ~/.config/atuin
	[ -f ~/.config/atuin/config.toml ] && mv --backup=numbered ~/.config/atuin/config.toml backups/ || true
	cp atuin/config.toml ~/.config/atuin/config.toml
put-atuin: ##
	cp ~/.config/atuin/config.toml atuin/config.toml
diff-atuin: ##
	-diff ~/.config/atuin/config.toml atuin/config.toml

get-karabiner: ##
	mkdir -p ~/.config/karabiner
	[ -f ~/.config/karabiner.edn ] && mv --backup=numbered ~/.config/karabiner.edn backups/ || true
	cp karabiner/karabiner-seed.json ~/.config/karabiner/karabiner.json
	cp karabiner/karabiner.edn ~/.config/karabiner.edn
	goku
put-karabiner: ##
	cp ~/.config/karabiner.edn karabiner/karabiner.edn
diff-karabiner: ##
	-diff ~/.config/karabiner.edn karabiner/karabiner.edn

get-kitty:     ##
	mkdir -p ~/.config/kitty
	[ -f ~/.config/kitty/kitty.conf ] && mv --backup=numbered ~/.config/kitty/kitty.conf backups/ || true
	cp kitty/kitty.conf ~/.config/kitty/kitty.conf
	cp kitty/current-theme.conf ~/.config/kitty/current-theme.conf
	cp -r kitty/themes ~/.config/kitty/themes
put-kitty:     ##
	cp ~/.config/kitty/kitty.conf kitty/kitty.conf
	cp ~/.config/kitty/current-theme.conf kitty/current-theme.conf
	cp -r ~/.config/kitty/themes kitty/
diff-kitty:    ##
	-diff ~/.config/kitty/kitty.conf kitty/kitty.conf
	-diff ~/.config/kitty/current-theme.conf kitty/current-theme.conf

get-skhd: ##
	mkdir -p ~/.config/skhd
	[ -f ~/.config/skhd/skhdrc ] && mv --backup=numbered ~/.config/skhd/skhdrc backups/ || true
	cp skhd/skhdrc ~/.config/skhd/skhdrc
put-skhd: ##
	cp ~/.config/skhd/skhdrc skhd/skhdrc
diff-skhd: ##
	-diff ~/.config/skhd/skhdrc skhd/skhdrc

get-starship:  ##
	[ -f ~/.config/starship.toml ] && mv --backup=numbered ~/.config/starship.toml backups/ || true
	cp starship/starship.toml ~/.config/starship.toml
put-starship:  ##
	cp ~/.config/starship.toml starship/starship.toml
diff-starship:  ##
	-diff ~/.config/starship.toml starship/starship.toml

get-tmux: ##
	mkdir -p ~/.config/tmux
	[ -f ~/.config/tmux/tmux.conf ] && mv --backup=numbered ~/.config/tmux/tmux.conf backups/ || true
	cp tmux/tmux.conf ~/.config/tmux/tmux.conf
	[ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	~/.tmux/plugins/tpm/bin/install_plugins
put-tmux: ##
	cp ~/.config/tmux/tmux.conf tmux/tmux.conf
diff-tmux: ##
	-diff ~/.config/tmux/tmux.conf tmux/tmux.conf

get-yabai: ##
	mkdir -p ~/.config/yabai
	[ -f ~/.config/yabai/yabairc ] && mv --backup=numbered ~/.config/yabai/yabairc backups/ || true
	cp yabai/yabairc ~/.config/yabai/yabairc
put-yabai: ##
	cp ~/.config/yabai/yabairc yabai/yabairc
diff-yabai: ##
	-diff ~/.config/yabai/yabairc yabai/yabairc

get-zsh: ##
	[ -f ~/.zshrc ] && mv --backup=numbered ~/.zshrc backups/ || true
	cp zsh/zshrc ~/.zshrc
put-zsh: ##
	cp ~/.zshrc zsh/zshrc
diff-zsh: ##
	-diff ~/.zshrc zsh/zshrc

