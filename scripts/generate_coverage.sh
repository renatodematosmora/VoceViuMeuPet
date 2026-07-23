#!/bin/bash

# Script to generate coverage report for the Flutter project
# This script runs tests with coverage tracking and generates an HTML report

set -e

echo "🧪 Generating coverage report..."

# Run tests with coverage
flutter test --coverage

echo "✅ Tests completed with coverage enabled"

# Check if lcov is available, if not try to install it
if ! command -v lcov &> /dev/null; then
    echo "⚠️  lcov not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install lcov
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get install -y lcov
    fi
fi

# Filter out generated and test files
if command -v lcov &> /dev/null; then
    echo "🔍 Filtering coverage data..."
    lcov --remove coverage/lcov.info \
        'lib/**/*.freezed.dart' \
        'lib/**/*.g.dart' \
        'lib/**/*.config.dart' \
        'lib/l10n/**' \
        'lib/main.dart' \
        -o coverage/lcov_filtered.info

    echo "📊 Generating HTML report..."
    genhtml coverage/lcov_filtered.info -o coverage/html

    echo "✅ Coverage report generated!"
    echo "📍 Report location: coverage/html/index.html"
    echo ""
    echo "To view the report, open:"
    if [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "  start coverage/html/index.html"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  open coverage/html/index.html"
    else
        echo "  xdg-open coverage/html/index.html"
    fi
else
    echo "⚠️  lcov not available. Coverage data is in coverage/lcov.info"
fi

echo ""
echo "📈 Coverage Summary:"
echo "  • Minimum target: 70%"
echo "  • Run 'flutter test --coverage' to update coverage"
