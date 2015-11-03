### KOKEN ###
_build_koken() {
local VERSION="0.21.4"
local FOLDER="koken"
local FILE="latest.zip"
local URL="https://s3.amazonaws.com/koken-installer/releases/${FILE}"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/app"
unzip -d "${DEST}/app" "download/${FILE}"
cp -vfa "src/${FOLDER}-${VERSION}-cache-relative-URLs.patch" "${DEST}/app/"
pushd "${DEST}/app"
patch -p1 -i "${FOLDER}-${VERSION}-cache-relative-URLs.patch"
rm -f "${FOLDER}-${VERSION}-cache-relative-URLs.patch"
popd
}

### ELEMENTARY ###
_build_elementary() {
local FILE="be1cb2d9-ed05-2d81-85b4-23282832eb84.zip"
local URL="https://koken-store.s3.amazonaws.com/plugins/${FILE}"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/app/storage/themes"
unzip -d "${DEST}/app/storage/themes" "download/${FILE}"
mv -vf "${DEST}/app/storage/themes/be1cb2d9-ed05-2d81-85b4-23282832eb84" "${DEST}/app/storage/themes/elementary"
}

### INSTALLER ###
_build_installer() {
local FILE="index.php"
local URL="https://raw.githubusercontent.com/koken/docker-koken-lemp/master/php/index.php"

_download_file "${FILE}" "${URL}"
mkdir -p "${DEST}/app/" "${DEST}/etc/"
cp -vfa "download/${FILE}" "${DEST}/app/"
cp -vfa "download/${FILE}" "${DEST}/etc/"
}

_build() {
  _build_koken
  _build_elementary
  _build_installer
  _package
}
