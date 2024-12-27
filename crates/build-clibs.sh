set -e

###############################################################################
# CONFIGURATION
###############################################################################
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIRECTORY=$SCRIPT_DIR
# RUST_LIB_DIRECTORY=$ROOT_DIRECTORY
DIST_DIRECTORY=$ROOT_DIRECTORY/dist

###############################################################################
# HELPERS
###############################################################################
ECHO_RED='\033[1;31m'
ECHO_GREEN='\033[1;32m'
ECHO_CYAN='\033[1;36m'
ECHO_NC='\033[0m' # No Color

###############################################################################
# SETUP
###############################################################################
mkdir -p $DIST_DIRECTORY
mkdir -p $DIST_DIRECTORY/include
mkdir -p $DIST_DIRECTORY/x86_64-apple-darwin
mkdir -p $DIST_DIRECTORY/aarch64-apple-ios
mkdir -p $DIST_DIRECTORY/x86_64-apple-ios-macabi
mkdir -p $DIST_DIRECTORY/aarch64-apple-ios-macabi
mkdir -p $DIST_DIRECTORY/universal
mkdir -p $DIST_DIRECTORY/universal/MacOS
mkdir -p $DIST_DIRECTORY/universal/iOS
mkdir -p $DIST_DIRECTORY/universal/Catalyst
mkdir -p $DIST_DIRECTORY/universal/XCFrameworks

###############################################################################
# C HEADER FILE GENERATION
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}C HEADER FILE${ECHO_NC}"
cd $ROOT_DIRECTORY
cbindgen --config markdown-parser-ffi/cbindgen.toml --crate markdown-parser-ffi --output $DIST_DIRECTORY/include/markdown_parser_ffi.h
cp $ROOT_DIRECTORY/assets/MarkdownParserFFI/module.modulemap $DIST_DIRECTORY/include/module.modulemap

###############################################################################
# BUILD NATIVE MAC-OS
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}x86_64-apple-darwin staticlib${ECHO_NC}"
cd $ROOT_DIRECTORY
cargo +nightly build -Z build-std --release --target x86_64-apple-darwin
cp  target/x86_64-apple-darwin/release/libmarkdown_parser_ffi.a $DIST_DIRECTORY/x86_64-apple-darwin/libmarkdown_parser_ffi.a

###############################################################################
# BUILD NATIVE IOS
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}aarch64-apple-ios staticlib${ECHO_NC}"
cd $ROOT_DIRECTORY
cargo +nightly build -Z build-std --release --target aarch64-apple-ios
cp  target/aarch64-apple-ios/release/libmarkdown_parser_ffi.a $DIST_DIRECTORY/aarch64-apple-ios/libmarkdown_parser_ffi.a

###############################################################################
# BUILD CATALYST
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}x86_64-apple-ios-macabi & aarch64-apple-ios-macabi staticlib${ECHO_NC}"
cd $ROOT_DIRECTORY
cargo +nightly build -Z build-std --release --target x86_64-apple-ios-macabi
cargo +nightly build -Z build-std --release --target aarch64-apple-ios-macabi

cp target/x86_64-apple-ios-macabi/release/libmarkdown_parser_ffi.a $DIST_DIRECTORY/x86_64-apple-ios-macabi/libmarkdown_parser_ffi.a
cp target/aarch64-apple-ios-macabi/release/libmarkdown_parser_ffi.a $DIST_DIRECTORY/aarch64-apple-ios-macabi/libmarkdown_parser_ffi.a

###############################################################################
# WRAP EACH ARCHITECTURE INTO A UNIVERSAL STATIC LIBRARY
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}WRAPPING EACH ARCHITECTURE INTO A UNIVERSAL STATIC LIBRARY${ECHO_NC}"
cd $ROOT_DIRECTORY
# MACOS (X86_64 ONLY)
lipo -create -output $DIST_DIRECTORY/universal/MacOS/libmarkdown_parser_ffi.a $DIST_DIRECTORY/x86_64-apple-darwin/libmarkdown_parser_ffi.a

# IOS (ARM64 ONLY)
lipo -create -output $DIST_DIRECTORY/universal/iOS/libmarkdown_parser_ffi.a $DIST_DIRECTORY/aarch64-apple-ios/libmarkdown_parser_ffi.a

# CATALYST (X86_64 AND ARM64)
lipo -create -output $DIST_DIRECTORY/universal/Catalyst/libmarkdown_parser_ffi.a \
    $DIST_DIRECTORY/aarch64-apple-ios-macabi/libmarkdown_parser_ffi.a \
    $DIST_DIRECTORY/x86_64-apple-ios-macabi/libmarkdown_parser_ffi.a

###############################################################################
# CREATE XC-FRAMEWORK
###############################################################################
echo "${ECHO_CYAN}BUILDING: ${ECHO_GREEN}XC-FRAMEWORK${ECHO_NC}"
rm -rf $DIST_DIRECTORY/universal/XCFrameworks/MarkdownParserFFI.xcframework
xcodebuild -create-xcframework \
    -library $DIST_DIRECTORY/universal/MacOS/libmarkdown_parser_ffi.a \
    -headers $DIST_DIRECTORY/include \
    -library $DIST_DIRECTORY/universal/iOS/libmarkdown_parser_ffi.a \
    -headers $DIST_DIRECTORY/include \
    -library $DIST_DIRECTORY/universal/Catalyst/libmarkdown_parser_ffi.a \
    -headers $DIST_DIRECTORY/include \
    -output $DIST_DIRECTORY/universal/XCFrameworks/MarkdownParserFFI.xcframework

