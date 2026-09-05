#!/usr/bin/env bash
set -euo pipefail

# Dependencies in this project require Flutter >= 3.38.1 / Dart >= 3.10.
# Pin to a stable patch release so Vercel builds remain reproducible.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.6}"
FLUTTER_ROOT="${HOME}/flutter"
VERSION_MARKER="${FLUTTER_ROOT}/.vercel-flutter-version"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]] || [[ ! -f "${VERSION_MARKER}" ]] || [[ "$(cat "${VERSION_MARKER}" 2>/dev/null || true)" != "${FLUTTER_VERSION}" ]]; then
  rm -rf "${FLUTTER_ROOT}"
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_ROOT}"
  printf '%s' "${FLUTTER_VERSION}" > "${VERSION_MARKER}"
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"
export CI=true

flutter --version
flutter config --enable-web
flutter pub get

DART_DEFINES=()
if [[ -n "${WEB_API_PROXY_BASE_URL:-}" ]]; then
  DART_DEFINES+=("--dart-define=WEB_API_PROXY_BASE_URL=${WEB_API_PROXY_BASE_URL}")
fi

flutter build web --release "${DART_DEFINES[@]}"
