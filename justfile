default:
    just --list


# Set screenshot save location to ~/screenshots and format to JPG
[group('mac')]
update-screenshot-location-and-type:
    mkdir ~/screenshots
    defaults write com.apple.screencapture location ~/screenshots
    defaults write com.apple.screencapture "type" -string "jpg"
    killall SystemUIServer

# Install Homebrew Bundle plugin
[group('mac')]
install-brew-programs:
    brew install bundle

# Install Oh My Zsh framework
install-oh-my-zsh:
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install personal Mac apps via Homebrew casks
[group('mac')]
install-mac-home-apps:
    brew install --cask handbrake visual-studio-code steam

# Set scrolling direction back to where God intended it to be
[group('mac')]
fix-scrolling-direction:
    defaults write -g com.apple.swipescrolldirection -bool false
    killall Finder

# Install Tailscale VPN client
[group('mac')]
install-tailscale:
    brew install tailscale

# Install Homebrew package manager
[group('mac')]
install-brew:
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install iperf3 and start a bandwidth test server
[group('mac')]
perf-test-server:
    brew install iperf3
    iperf3 -s -f M

# Symlink Ghostty config file to correct location
[group('initial-setup')]
link-ghostty-config:
    mkdir -p $HOME/.config/ghostty/
    ln -sf $HOME/dotfiles/ghostty/config $HOME/.config/ghostty/

# Symlink Zed config file to correct location
[group('initial-setup')]
link-zed-config:
    mkdir -p $HOME/.config/zed/
    ln -sf $HOME/dotfiles/zed/settings.json $HOME/.config/zed/

# Look up a command cheatsheet via cheat.sh
cheat CMD:
    curl -sS cheat.sh/{{CMD}} | bat

# Re-link Docker in the event brew unlinks it
[group('annoyances')]
link-docker:
    brew link docker

# Scaffold a new Gradle-based Java project
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

# Scaffold a new Python project using uv
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

# Scaffold a new Rust project using Cargo
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

# Scaffold a new Node.js project using npm
[no-cd]
[group('coding')]
node-quickstart PROJECT_NAME:
    #!/usr/bin/env bash

    set -e

    PROJECT_NAME="{{PROJECT_NAME}}"

    echo "Creating Node.js project '$PROJECT_NAME'..."

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Setup mise configuration for Node.js
    # Using LTS is customary for general projects
    echo "Setting up mise..."
    cat <<EOF > .mise.toml
    [tools]
    node = "lts"
    EOF
    mise trust

    # Install node via mise
    if command -v mise &> /dev/null; then
        echo "Installing tools via mise..."
        set +e # Temporarily allow failure
        mise install
        MISE_EXIT_CODE=$?
        set -e # Re-enable strict mode

        if [ $MISE_EXIT_CODE -ne 0 ]; then
            echo "Warning: 'mise install' failed (likely GPG/network issue)."
            echo "Attempting to proceed with system Node.js..."
        fi
    fi

    # Check if node is available (either from mise or system)
    if ! command -v node &> /dev/null; then
        echo "Error: 'node' command not found."
        echo "Please ensure Node.js is installed (via mise or system) to proceed."
        exit 1
    fi

    # Initialize npm project
    echo "Initializing npm project..."
    # -y defaults everything
    npm init -y

    # Modify package.json to be more modern (ES modules) and have correct scripts
    # We use a temporary file to edit package.json using jq if available, or just sed/cat.
    # To be safe without assuming jq, we can just overwrite package.json or use node to edit it.

    node -e "
    const fs = require('fs');
    const pkg = require('./package.json');
    pkg.name = '$PROJECT_NAME';
    pkg.type = 'module';
    pkg.main = 'src/index.js';
    pkg.scripts = {
    test: 'node --test',
    start: 'node src/index.js'
    };
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "

    # Create source directory and file
    mkdir -p src
    cat <<EOF > src/index.js
    console.log("Just one more thing.");
    EOF

    # Create test file
    # Using native Node.js test runner (available in Node 18+) as it requires no dependencies
    # and is becoming customary for simple projects.
    mkdir -p tests
    cat <<EOF > tests/index.test.js
    import { test } from 'node:test';
    import assert from 'node:assert';

    test('the simplest test in the world', () => {
    assert.strictEqual(1, 1);
    });
    EOF

    # Create justfile
    cat <<EOF > justfile
    default:
        @just --list

    build:
        npm install

    test:
        npm test

    clean:
        rm -rf node_modules

    run:
        npm start
    EOF

    echo "Project setup complete at $(pwd)"

# Scaffold a new Go project
[no-cd]
[group('coding')]
golang-quickstart PROJECT_NAME:
    #!/usr/bin/env bash

    set -e

    PROJECT_NAME="{{PROJECT_NAME}}"

    echo "Creating Go project '$PROJECT_NAME'..."

    # Create project directory
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"

    # Setup mise configuration for Go
    echo "Setting up mise..."
    cat <<EOF > .mise.toml
    [tools]
    go = "latest"
    EOF
    mise trust

    # Install go via mise
    if command -v mise &> /dev/null; then
        echo "Installing tools via mise..."
        mise install
    fi

    # Check if go is available
    if ! command -v go &> /dev/null; then
        echo "Error: 'go' command not found."
        echo "Please ensure Go is installed (via mise or system) to proceed."
        exit 1
    fi

    # Initialize Go module
    echo "Initializing Go module..."
    go mod init "$PROJECT_NAME"

    # Create main.go
    cat <<EOF > main.go
    package main

    import "fmt"

    func main() {
        fmt.Println("Just one more thing.")
    }
    EOF

    # Create main_test.go
    cat <<EOF > main_test.go
    package main

    import "testing"

    func TestApp(t *testing.T) {
        // The simplest test in the world
        if false {
            t.Fatal("unreachable")
        }
    }
    EOF

    # Create justfile
    cat <<EOF > justfile
    default:
        @just --list

    build:
        go build ./...

    test:
        go test ./...

    clean:
        go clean

    run:
        go run .
    EOF

    echo "Project setup complete at $(pwd)"

# Generate a README.md based on detected project type
[no-cd]
[group('coding')]
readme-quickstart:
    #!/usr/bin/env bash

    set -e

    PROJECT_NAME=$(basename "$(pwd)")
    README_FILE="README.md"

    echo "Generating README.md for '$PROJECT_NAME'..."

    # Detect project type
    IS_JAVA=false
    IS_PYTHON=false
    IS_RUST=false
    IS_NODE=false

    if [[ -f build.gradle.kts ]] || [[ -f build.gradle ]] || [[ -f pom.xml ]]; then
        IS_JAVA=true
    fi

    if [[ -f pyproject.toml ]]; then
        IS_PYTHON=true
    fi

    if [[ -f Cargo.toml ]]; then
        IS_RUST=true
    fi

    if [[ -f package.json ]]; then
        IS_NODE=true
    fi

    HAS_MISE=false
    if [[ -f .mise.toml ]]; then
        HAS_MISE=true
    fi

    # Build content
    cat <<EOF > "$README_FILE"
    # $PROJECT_NAME

    ## Introduction

    Welcome to **$PROJECT_NAME**. This project is a software application designed to do... well, *just one more thing*.

    ## Requirements

    To work with this project, you will need the following tools installed:

    - **[Just](https://github.com/casey/just)**: Used as the command runner for build, test, and execution tasks.
    EOF

    if [ "$HAS_MISE" = true ]; then
        echo "- **[mise](https://mise.jdx.dev/)**: Recommended. It will automatically install and manage the correct versions of the tools listed below (run \`mise install\`)." >> "$README_FILE"
    fi

    # Add language specific requirements
    if [ "$IS_JAVA" = true ]; then
        if [ "$HAS_MISE" = true ]; then
            echo "- **Java JDK**: Provided by mise." >> "$README_FILE"
        else
            echo "- **Java JDK**: Ensure you have a compatible Java Development Kit installed." >> "$README_FILE"
        fi
        echo "- **Gradle**: The build system (wrapper provided)." >> "$README_FILE"
    fi

    if [ "$IS_PYTHON" = true ]; then
        if [ "$HAS_MISE" = true ]; then
            echo "- **Python**: Provided by mise (or managed via uv)." >> "$README_FILE"
        else
            echo "- **Python**: A modern Python version." >> "$README_FILE"
        fi
        echo "- **[uv](https://github.com/astral-sh/uv)**: Used for Python project and dependency management." >> "$README_FILE"
    fi

    if [ "$IS_RUST" = true ]; then
        # Rust is usually managed by rustup, not typically mise (though mise can do it).
        # Our script didn't set up mise for Rust.
        echo "- **Rust**: The Rust programming language (install via [rustup](https://rustup.rs/))." >> "$README_FILE"
        echo "- **Cargo**: The Rust package manager (included with Rust)." >> "$README_FILE"
    fi

    if [ "$IS_NODE" = true ]; then
        if [ "$HAS_MISE" = true ]; then
            echo "- **Node.js**: Provided by mise." >> "$README_FILE"
        else
            echo "- **Node.js**: The JavaScript runtime." >> "$README_FILE"
        fi
        echo "- **npm**: The Node package manager." >> "$README_FILE"
    fi


    cat <<EOF >> "$README_FILE"

    ## Building and Running

    This project uses \`just\` to manage common development tasks.

    ### Available Commands

    - **Build the project:**
    \`\`\`bash
    just build
    \`\`\`

    - **Run the application:**
    \`\`\`bash
    just run
    \`\`\`

    - **Run tests:**
    \`\`\`bash
    just test
    \`\`\`

    - **Clean build artifacts:**
    \`\`\`bash
    just clean
    \`\`\`

    - **List all available recipes:**
    \`\`\`bash
    just --list
    \`\`\`

    EOF

    echo "README.md created successfully."

# Open a new tmux pane in the current directory
open-pane:
    tmux split-window -h -c "#{pane_current_path}"

# Push an empty commit to repo in order to trigger CI/CD
[group('coding')]
retrigger-with-empty-commit:
    git commit --allow-empty -m "retrigger CI" && git push
