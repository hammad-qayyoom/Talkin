#!/bin/sh
set -eu

if [ "${ACTION:-}" != "install" ] || [ "${EFFECTIVE_PLATFORM_NAME:-}" != "-iphoneos" ]; then
  exit 0
fi

if [ -z "${DWARF_DSYM_FOLDER_PATH:-}" ]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is not set; skipping vendor dSYM packaging"
  exit 0
fi

mkdir -p "${DWARF_DSYM_FOLDER_PATH}"

copy_dsym() {
  source="$1"
  name="$(basename "${source}")"

  if [ ! -d "${source}" ]; then
    echo "warning: Vendor dSYM not found: ${source}"
    return 0
  fi

  rsync -a --delete "${source}" "${DWARF_DSYM_FOLDER_PATH}/"
  echo "Included vendor dSYM: ${name}"
}

generate_dsym() {
  binary="$1"
  framework_name="$2"
  output="${DWARF_DSYM_FOLDER_PATH}/${framework_name}.framework.dSYM"

  if [ ! -f "${binary}" ]; then
    echo "warning: Vendor framework binary not found: ${binary}"
    return 0
  fi

  if [ -d "${output}" ]; then
    rm -rf "${output}"
  fi

  dsymutil "${binary}" -o "${output}" >/dev/null 2>&1 || {
    echo "warning: Failed to generate dSYM for ${framework_name}.framework"
    return 0
  }

  echo "Generated vendor dSYM: ${framework_name}.framework.dSYM"
}

# Zego does not currently ship a dSYM bundle in this pod. Generate a
# UUID-matching dSYM so App Store Connect receives the symbol file it expects.
generate_dsym "${SRCROOT}/.symlinks/plugins/zego_express_engine/ios/libs/ZegoExpressEngine.xcframework/ios-arm64/ZegoExpressEngine.framework/ZegoExpressEngine" "ZegoExpressEngine"
