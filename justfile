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

install-oh-my-zsh:
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

link-docker:
    brew link docker

[no-cd]
[group('coding')]
java-quickstart JAVA_VERSION PROJECT_NAME:
    #!/usr/bin/env bash

    set -e

    JAVA_VERSION="{{JAVA_VERSION}}"
    PROJECT_NAME="{{PROJECT_NAME}}"

    # Helper to extract major Java version
    function get_major_version() {
        local ver=$1
        if [[ "$ver" == "1.8" ]]; then
            echo "8"
        else
            # Extract first number found in the string
            echo "$ver" | grep -oE '[0-9]+' | head -1
        fi
    }

    # Normalize version for mise
    # If user provides just a number like "8", "11", "25", default to corretto
    if [[ "$JAVA_VERSION" =~ ^[0-9]+$ ]] || [[ "$JAVA_VERSION" == "1.8" ]]; then
        # Handle 1.8 special case for mise which usually uses "8"
        if [[ "$JAVA_VERSION" == "1.8" ]]; then
            MISE_VERSION="corretto-8"
            JAVA_INT=8
        else
            MISE_VERSION="corretto-$JAVA_VERSION"
            JAVA_INT=$JAVA_VERSION
        fi
    else
        MISE_VERSION="$JAVA_VERSION"
        JAVA_INT=$(get_major_version "$JAVA_VERSION")
    fi

    echo "Creating project '$PROJECT_NAME' with Java $JAVA_INT (using $MISE_VERSION)..."

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Setup mise configuration
    echo "Setting up mise..."
    cat <<EOF > .mise.toml
    [tools]
    java = "$MISE_VERSION"
    EOF
    mise trust

    # Setup project structure
    echo "Creating project structure..."
    mkdir -p src/main/java/com/columbo
    mkdir -p src/test/java/com/columbo

    # Create Main class
    cat <<EOF > src/main/java/com/columbo/Main.java
    package com.columbo;

    public class Main {
        public static void main(String[] args) {
            System.out.println("Just one more thing.");
        }
    }
    EOF

    # Create MainTest class
    cat <<EOF > src/test/java/com/columbo/MainTest.java
    package com.columbo;

    import org.junit.jupiter.api.Test;
    import static org.junit.jupiter.api.Assertions.assertTrue;

    public class MainTest {
        @Test
        void testApp() {
            assertTrue(true, "The simplest test in the world");
        }
    }
    EOF

    # Create build.gradle.kts
    cat <<EOF > build.gradle.kts
    plugins {
        application
        jacoco
    }

    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of($JAVA_INT))
        }
    }

    application {
        mainClass.set("com.columbo.Main")
    }

    repositories {
        mavenCentral()
    }

    dependencies {
        testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
        testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    }

    tasks.named<Test>("test") {
        useJUnitPlatform()
    }
    EOF

    # Create settings.gradle.kts
    cat <<EOF > settings.gradle.kts
    rootProject.name = "$PROJECT_NAME"
    EOF

    # Create justfile
    cat <<EOF > justfile
    default:
        @just --list

    build:
        ./gradlew build

    test:
        ./gradlew test

    clean:
        ./gradlew clean

    run:
        ./gradlew run

    coverage:
        ./gradlew jacocoTestReport
    EOF

    # Attempt to generate gradle wrapper
    echo "Attempting to generate Gradle wrapper..."
    if command -v gradle &> /dev/null; then
        # We try to install the java version first so gradle can use it if needed
        if command -v mise &> /dev/null; then
            echo "Running 'mise install'..."
            mise install
        fi
        
        GRADLE_ARGS=""
        # Gradle 9+ requires Java 17+ (approx)
        # Gradle 8 requires Java 11+
        # Gradle 7 supports Java 8+
        if [ "$JAVA_INT" -lt 11 ]; then
            echo "Java version < 11 detected. Using Gradle 7.6.4 for compatibility."
            GRADLE_ARGS="--gradle-version 7.6.4"
        elif [ "$JAVA_INT" -lt 17 ]; then
            echo "Java version < 17 detected. Using Gradle 8.5 for compatibility."
            GRADLE_ARGS="--gradle-version 8.5"
        fi

        gradle wrapper $GRADLE_ARGS
    else
        echo "Warning: 'gradle' command not found. Gradle wrapper not generated."
        echo "Please ensure Gradle is installed and run 'gradle wrapper' manually."
    fi

    echo "Project setup complete at $(pwd)"

[no-cd]
[group('coding')]
python-quickstart PROJECT_NAME:
    #!/usr/bin/env bash

    set -e

    PROJECT_NAME="{{PROJECT_NAME}}"
    # Default to a modern Python version
    PYTHON_VERSION="3.12"

    echo "Creating project '$PROJECT_NAME' with Python $PYTHON_VERSION using uv..."

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Setup mise to ensure uv is available
    echo "Setting up mise..."
    # We just need uv to start with.
    cat <<EOF > .mise.toml
    [tools]
    uv = "latest"
    python = "$PYTHON_VERSION"
    EOF
    mise trust

    # Install tools via mise
    if command -v mise &> /dev/null; then
        echo "Installing tools via mise..."
        mise install
    fi

    # Initialize uv project
    echo "Initializing uv project..."
    # We use 'uv' from the path, which mise should have set up, or system uv.
    # We explicitly set the python version for the project.
    uv init --python "$PYTHON_VERSION" --name "$PROJECT_NAME" --app --package --vcs none .

    # Add pytest as dev dependency
    echo "Adding dependencies..."
    uv add --dev pytest

    # Create Main script
    # uv init creates 'hello.py' or 'main.py' depending on version/flags, usually 'hello.py' for app?
    # Let's see what uv init creates. It usually creates a file named after the project or hello.py.
    # We will force create src/main.py or similar, but uv init default structure is flat or src-based.
    # --app implies it's an application. --package implies it's a library.
    # To be safe and standard, we'll check what was created or just overwrite/create 'src/$PROJECT_NAME/main.py' or 'main.py'.
    # The standard uv init creates 'hello.py'. Let's rename it to main.py and configure the entry point.

    # Actually, let's just create our own main.py and update pyproject.toml if needed.
    # For simplicity in this script, we'll create 'main.py' in the root or src.
    # 'uv init --app' creates a 'hello.py'.

    if [ -f "hello.py" ]; then
        mv hello.py main.py
    fi

    cat <<EOF > main.py
    def main():
        print("Just one more thing.")

    if __name__ == "__main__":
        main()
    EOF

    # Update pyproject.toml to point to main:main if it exists?
    # For a simple script, 'uv run main.py' works.
    # But 'uv run' by default runs the project command defined in pyproject.toml.
    # We'll just rely on the justfile for explicit commands.

    # Create test directory and file
    mkdir -p tests
    cat <<EOF > tests/test_main.py
    def test_app():
        assert True, "The simplest test in the world"
    EOF

    # Create justfile
    cat <<EOF > justfile
    default:
        @just --list

    build:
        uv build

    test:
        uv run pytest

    clean:
        rm -rf .venv dist .ruff_cache .pytest_cache
        find . -type d -name "__pycache__" -exec rm -rf {} +

    run:
        uv run main.py

    coverage:
        uv run pytest --cov
    EOF

    echo "Project setup complete at $(pwd)"

[no-cd]
[group('coding')]
rust-quickstart PROJECT_NAME:
    #!/usr/bin/env bash

    set -e

    PROJECT_NAME={{PROJECT_NAME}}

    echo "Creating Rust project '$PROJECT_NAME'..."

    if ! command -v cargo &> /dev/null; then
        echo "Error: 'cargo' is not installed. Please install Rust via rustup."
        exit 1
    fi

    # Create new cargo project
    cargo new --bin --vcs none "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Modify main.rs
    cat <<EOF > src/main.rs
    fn main() {
        println!("Just one more thing.");
    }

    #[cfg(test)]
    mod tests {
        #[test]
        fn test_app() {
            assert!(true, "The simplest test in the world");
        }
    }
    EOF

    # Create justfile
    cat <<EOF > justfile
    default:
        @just --list

    build:
        cargo build

    test:
        cargo test

    clean:
        cargo clean

    run:
        cargo run
    EOF

    echo "Project setup complete at $(pwd)"

