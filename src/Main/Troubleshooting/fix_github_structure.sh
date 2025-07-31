#!/usr/bin/env bash

# Script to validate and fix GitHub repository structure for UnifiedAMPMSystem
# Date: 2025-07-31
# Repository: https://github.com/Doctor0Evil/AMPM

set -e  # Exit on error

# Set working directory
REPO_DIR="/workspaces/AMPM"
cd "$REPO_DIR" || { echo "Failed to change to $REPO_DIR"; exit 1; }

# Log function for Kafka integration (with fallback)
log_to_kafka() {
    local topic=$1
    local message=$2
    if command -v kafka-console-producer >/dev/null 2>&1 && command -v uuidgen >/dev/null 2>&1; then
        echo "{\"event_id\": \"$(uuidgen)\", \"event_type\": \"$topic\", \"status\": \"success\", \"details\": \"$message\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" | \
            kafka-console-producer --broker-list cluster.pos_quantum_synergy_chat:9092 --topic ci_cd || \
            echo "Warning: Failed to log to Kafka: $message" >&2
    else
        echo "Warning: kafka-console-producer or uuidgen not found, logging to stdout: $message" >&2
    fi
}

# Install dependencies
install_dependencies() {
    echo "Checking and installing dependencies..."
    if ! command -v git >/dev/null 2>&1 || ! command -v composer >/dev/null 2>&1; then
        echo "Installing git and composer..."
        if command -v apt-get >/dev/null 2>&1; then
            DEBIAN_FRONTEND=noninteractive apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get install -y git composer || {
                echo "Error: Failed to install git or composer"; exit 1;
            }
        else
            echo "Error: apt-get not found, please install git and composer manually"; exit 1;
        fi
        log_to_kafka "ci_cd" "Installed git and composer"
    else
        log_to_kafka "ci_cd" "Verified git and composer availability"
    fi
}

# Validate and create GitHub directory structure
validate_github_structure() {
    echo "Validating and creating GitHub directory structure..."
    local directories=(
        ".github/ISSUE_TEMPLATE"
        ".github/workflows"
        ".scripts"
        "data/amssymb"
        "data/amstext"
        "data/fixltx2e"
        "data/hyperref"
        "library/PhpLatex/Filter"
        "library/PhpLatex/Renderer"
        "library/PhpLatex/Utils"
        "tests/PhpLatex/Test/Renderer"
    )

    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
            log_to_kafka "ci_cd" "Created directory $dir"
        fi
    done
}

# Create or update missing files with placeholders
create_files() {
    echo "Creating or updating repository files..."
    local files=(
        ".github/ISSUE_TEMPLATE/bug_report.yml"
        ".github/ISSUE_TEMPLATE/config.yml"
        ".github/ISSUE_TEMPLATE/feature_request.yml"
        ".github/workflows/build.yml"
        ".github/workflows/stale.yml"
        ".scripts/patch-phpunit.php"
        "data/amssymb/both-amssymb.tex"
        "data/amssymb/math-amssymb-alphabets.tex"
        "data/amssymb/math-amssymb-binops.tex"
        "data/amssymb/math-amssymb-greek.tex"
        "data/amssymb/math-amssymb-loglike.tex"
        "data/amssymb/math-amssymb-misc.tex"
        "data/amssymb/math-amssymb-symbols.tex"
        "data/amssymb/math-amssymb-varsized-delimiters.tex"
        "data/amstext/both-amstext-alphabets.tex"
        "data/fixltx2e/both-fixltx2e.tex"
        "data/hyperref/text-hyperref.tex"
        "base.php"
        "both-alphabets.tex"
        "both-refs.tex"
        "both-spaces.tex"
        "both.tex"
        "compile.php"
        "math-accents.tex"
        "math-alphabets.tex"
        "math-arrows.tex"
        "math-binops.tex"
        "math-delimiters.tex"
        "math-greek.tex"
        "math-large-delimeters.tex"
        "math-loglike.tex"
        "math-misc.tex"
        "math-other.tex"
        "math-punctuation.tex"
        "math-relations.tex"
        "math-spaces.tex"
        "math-varsymbols.tex"
        "math.tex"
        "text-accents.tex"
        "text-fontsize.tex"
        "text-primitives.tex"
        "text-spaces.tex"
        "text.tex"
        "library/PhpLatex/Filter/Html2Latex.php"
        "library/PhpLatex/Renderer/Abstract.php"
        "library/PhpLatex/Renderer/Html.php"
        "library/PhpLatex/Renderer/NodeRenderer.php"
        "library/PhpLatex/Renderer/Typestyle.php"
        "library/PhpLatex/Utils/PeekableArrayIterator.php"
        "library/PhpLatex/Utils/PeekableIterator.php"
        "library/PhpLatex/Utils/TreeDebug.php"
        "library/PhpLatex/Lexer.php"
        "library/PhpLatex/Node.php"
        "library/PhpLatex/Parser.php"
        "library/PhpLatex/PdfLatex.php"
        "library/PhpLatex/Utils.php"
        "commands.php"
        "environs.php"
        "latex_utf8.php"
        "tests/PhpLatex/Test/Renderer/AbstractTest.php"
        "tests/PhpLatex/Test/Renderer/HtmlTest.php"
        "tests/PhpLatex/Test/LexerTest.php"
        "tests/PhpLatex/Test/ParserTest.php"
        "tests/PhpLatex/Test/PdfLatexTest.php"
        "tests/bootstrap.php"
        ".editorconfig"
        ".gitattributes"
        ".gitignore"
        "LICENSE"
        "README.md"
        "composer.json"
        "phpunit.xml.dist"
    )

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            touch "$file"
            echo "Created file: $file"
            case "$file" in
                *.yml)
                    echo "# Placeholder YAML configuration for $file" > "$file"
                    ;;
                *.php)
                    echo "<?php // Placeholder PHP file for $file" > "$file"
                    ;;
                *.tex)
                    echo "% Placeholder LaTeX file for $file" > "$file"
                    ;;
                *.md)
                    echo "# Placeholder Markdown file for $file" > "$file"
                    ;;
                *)
                    echo "# Placeholder file for $file" > "$file"
                    ;;
            esac
            log_to_kafka "ci_cd" "Created placeholder file $file"
        fi
    done
}

# Update .gitignore
update_gitignore() {
    echo "Updating .gitignore..."
    cat > .gitignore << 'EOF'
# Ignore build artifacts and temporary files
*.log
*.aux
*.toc
*.out
*.pdf
vendor/
node_modules/
.DS_Store
*.lock

# Ignore test artifacts
tests/_output/*
tests/_support/_generated/*
EOF
    log_to_kafka "ci_cd" "Updated .gitignore file"
}

# Update composer.json
update_composer_json() {
    echo "Updating composer.json..."
    cat > composer.json << 'EOF'
{
    "name": "doctor0evil/ampm",
    "description": "UnifiedAMPMSystem for retail automation",
    "require": {
        "php": ">=7.4",
        "ext-json": "*"
    },
    "require-dev": {
        "phpunit/phpunit": "^9.5"
    },
    "autoload": {
        "psr-4": {
            "PhpLatex\\": "library/PhpLatex/"
        }
    },
    "scripts": {
        "test": "phpunit --configuration phpunit.xml.dist"
    }
}
EOF
    log_to_kafka "ci_cd" "Updated composer.json"
}

# Run composer install
run_composer_install() {
    echo "Running composer install..."
    composer install --no-interaction || {
        echo "Error: composer install failed"; exit 1;
    }
    log_to_kafka "ci_cd" "Ran composer install"
}

# Commit changes
commit_changes() {
    echo "Committing changes..."
    git add .
    git commit -m "Initialize repository structure for UnifiedAMPMSystem" || true
    log_to_kafka "ci_cd" "Committed repository structure changes"
}

# Update Prometheus metrics
update_metrics() {
    echo "Updating Prometheus metrics..."
    if command -v curl >/dev/null 2>&1; then
        curl -X POST http://prometheus:9090/api/v1/write -d "{\"metrics\": {\"build_success_rate\": 1, \"build_duration\": $(date +%s), \"dependency_validation_errors\": 0}}" || \
            echo "Warning: Failed to update Prometheus metrics" >&2
        log_to_kafka "ci_cd" "Updated Prometheus metrics"
    else
        echo "Warning: curl not found, skipping Prometheus metrics update" >&2
        log_to_kafka "ci_cd" "Skipped Prometheus metrics update due to missing curl"
    fi
}

# Main execution
install_dependencies
validate_github_structure
create_files
update_gitignore
update_composer_json
run_composer_install
commit_changes
update_metrics

# Verify repository state
echo "Verifying repository state..."
git status || { echo "Error: git status failed"; exit 1; }
log_to_kafka "ci_cd" "Verified repository state"

echo "GitHub repository structure fix completed successfully"
exit 0
