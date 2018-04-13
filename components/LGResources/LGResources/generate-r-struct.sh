#!/bin/sh

# Script responsible for transforming assets and strings into type safe variables by automatically generating 
# the `Strings.swift` and `Asset.swift` files in LGResources.

# Absolute path of this script file
SCRIPT_PATH=$(realpath "$0")
# Absolute folder of this script file
BASE_PATH=$(dirname "${SCRIPT_PATH}")"/"
# Resources Classes 
RESOURCES_PATH="${BASE_PATH}Classes/"
ASSETS_FILE="${RESOURCES_PATH}Assets.swift"
STRINGS_FILE="${RESOURCES_PATH}Strings.swift"


# ASSET GENERATION

echo "Generating ${ASSETS_FILE}..."

# Look for all .xcassets files inside the LGResources component folder and runs SwiftGen for xcassets passing the assets 
# list as param and using a custom template. 
find "${BASE_PATH}" -type d -iname *.xcassets \
-exec "${BASE_PATH}"/swiftgen/bin/swiftgen xcassets \
-p "${BASE_PATH}"/swiftgen-template/xcassets/letgo-swift4-template.stencil --param publicAccess -o "${ASSETS_FILE}" {} +;

# STRING GENERATION

echo "Generating ${STRINGS_FILE}..."

# Run SwiftGen for strings using a cusomt template.
# To generate the 'Strings.swift' file takes 'Base.lproj/Localizable.strings' as the reference file.
"$BASE_PATH"/swiftgen/bin/swiftgen strings -p "$BASE_PATH"/swiftgen-template/strings/letgo-flat-swift4.stencil \
--param publicAccess --param enumName=Strings "$BASE_PATH"/Assets/i18n/Base.lproj/Localizable.strings -o "${STRINGS_FILE}" ;
