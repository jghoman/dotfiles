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

perf-test-server:
    brew install iperf3
    iperf3 -s -f M

[group('podman')]
create-openwebui-pod:
    podman create -p 127.0.0.1:3000:8080 \
    --add-host=localhost:127.0.0.1 \
    --env 'OLLAMA_BASE_URL=http://localhost:11434' \
    --env 'ANONYMIZED_TELEMETRY=False' \
    -v open-webui:/app/backend/data \
    --label io.containers.autoupdate=registry \
    --name open-webui ghcr.io/open-webui/open-webui:main

[group('podman')]
start-openwebui-pod:
    podman start open-webui

cheat CMD:
    curl -sS cheat.sh/{{CMD}} | bat 
