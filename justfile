default:
    just --list


[group('mac')]
update-screenshot-location-and-type:
    mkdir ~/screenshots
    defaults write com.apple.screencapture location ~/screenshots
    defaults write com.apple.screencapture "type" -string "jpg"
    killall SystemUIServer

install-brew-programs:
    brew install bundle

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
create-open-webui-pod:
    podman create -p 127.0.0.1:3000:8080 \
    --env 'OLLAMA_BASE_URL=http://host.containers.internal:11434' \
    --env 'ANONYMIZED_TELEMETRY=False' \
    -v open-webui:/app/backend/data \
    --label io.containers.autoupdate=image \
    --name open-webui ghcr.io/open-webui/open-webui:main

[group('podman')]
start-open-webui-pod:
    podman start open-webui

[group('podman')]
update-open-webui-pod: && create-open-webui-pod start-open-webui-pod
    podman stop -i open-webui
    podman rm -i open-webui
    podman pull ghcr.io/open-webui/open-webui:main


cheat CMD:
    curl -sS cheat.sh/{{CMD}} | bat 

[no-cd]
duckdb-here-via-podman:
    podman run -it -v "$(pwd):/data" datacatering/duckdb:v1.2.2
