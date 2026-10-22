#!/bin/bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd "$(dirname "$0")"

# Runs on connected iPhone in release mode automatically
flutter run --release "$@"
