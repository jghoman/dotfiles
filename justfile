default:
    just --list


[group('mac')]
update-screenshot-location-and-type:
    mkdir ~/screenshots
    defaults write com.apple.screencapture location ~/screenshots
    defaults write com.apple.screencapture "type" -string "jpg"
    killall SystemUIServer

install-cli-programs:
    brew install helix tig htop tree ncdu awscli bat coreutils jq the_silver_searcher btop just rust

[group('mac')]
install-mac-home-apps:
    brew install --cask handbrake visual-studio-code steam

install-tailscale:
    brew install tailscale

install-brew:
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
