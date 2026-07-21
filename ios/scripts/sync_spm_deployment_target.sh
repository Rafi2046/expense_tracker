#!/bin/bash
# Sync FlutterGeneratedPluginSwiftPackage iOS minimum version with the Xcode project.
# Firebase SPM plugins require iOS 15.0+. Flutter generates Package.swift at 13.0 by
# default; `flutter build ios` patches it, but direct Xcode builds need this script.

set -euo pipefail

DEPLOYMENT_TARGET="${IPHONEOS_DEPLOYMENT_TARGET:-15.0}"
PACKAGE_SWIFT="${SRCROOT}/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"

if [ ! -f "$PACKAGE_SWIFT" ]; then
  exit 0
fi

/usr/bin/sed -i '' -E "s/\\.iOS\\(\"[0-9.]+\"\\)/.iOS(\"${DEPLOYMENT_TARGET}\")/" "$PACKAGE_SWIFT"
