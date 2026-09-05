#!/usr/bin/env bash
set -euo pipefail

# Pin Flutter to a version compatible with this project's Dart SDK constraint.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.29.3}"
FLUTTER_ROOT="${HOME}/flutter"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_ROOT}"
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_ROOT}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter pub get

DART_DEFINES=()
if [[ -n "${WEB_API_PROXY_BASE_URL:-}" ]]; then
  DART_DEFINES+=("--dart-define=WEB_API_PROXY_BASE_URL=${WEB_API_PROXY_BASE_URL}")
fi

flutter build web --release "${DART_DEFINES[@]}"
