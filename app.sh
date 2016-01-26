### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib" --shared
make
make install
rm -v "${DEST}/lib/libz.a"
popd
}

### BZIP ###
_build_bzip() {
local VERSION="1.0.6"
local FOLDER="bzip2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://bzip.org/1.0.6/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd target/"${FOLDER}"
sed -i -e "s/all: libbz2.a bzip2 bzip2recover test/all: libbz2.a bzip2 bzip2recover/" Makefile
make -f Makefile-libbz2_so \
  CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" CFLAGS="${CFLAGS} -fpic -fPIC -Wall -D_FILE_OFFSET_BITS=64"
ln -s libbz2.so.1.0.6 libbz2.so
cp -vfaR *.h "${DEPS}/include/"
cp -vfaR *.so* "${DEST}/lib/"
popd
}

### LIBLZMA ###
_build_liblzma() {
local VERSION="5.2.2"
local FOLDER="xz-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://tukaani.org/xz/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static \
  --disable-{xz,xzdec,lzmadec,lzmainfo,lzma-links,scripts}
make
make install
popd
}

### LIBJPEG ###
_build_libjpeg() {
local VERSION="9a"
local FOLDER="jpeg-${VERSION}"
local FILE="jpegsrc.v${VERSION}.tar.gz"
local URL="http://www.ijg.org/files/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static \
  --enable-maxmem=8
make
make install
popd
}

### LIBPNG ###
_build_libpng() {
local VERSION="1.6.20"
local FOLDER="libpng-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://sourceforge.net/projects/libpng/files/libpng16/${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static
make
make install
popd
}

### LIBTIFF ###
_build_libtiff() {
local VERSION="4.0.6"
local FOLDER="tiff-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://ftp.remotesensing.org/pub/libtiff/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --disable-static \
  --enable-rpath
make
make install
popd
}

### LIBXML2 ###
_build_libxml2() {
local VERSION="2.9.3"
local FOLDER="libxml2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://xmlsoft.org/libxml2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PATH="${DEPS}/bin:${PATH}" \
  ./configure --host="${HOST}" --prefix="${DEPS}" \
    --libdir="${DEST}/lib" --disable-static \
    --with-zlib --without-python \
    LIBS="-lz"
make
make install
popd
}

### IMAGEMAGICK ###
_build_imagemagick() {
local MAJOR="6.9.3"
local VERSION="${MAJOR}-2"
local FOLDER="ImageMagick-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="http://sourceforge.net/projects/imagemagick/files/${MAJOR}-sources/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${DEST}/lib/pkgconfig" \
  ./configure --host="${HOST}" --prefix="${DEPS}" \
    --libdir="${DEST}/lib" --bindir="${DEST}/libexec" --enable-shared --disable-static
make
make install
popd
}

### GRAPHICSMAGICK ###
_build_graphicsmagick() {
local VERSION="1.3.23"
local FOLDER="GraphicsMagick-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/${VERSION}/${FILE}"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --bindir="${DEST}/libexec" --enable-shared --disable-static \
  --enable-magick-compat \
  --with-zlib --with-bzlib --with-lzma --with-jpeg --with-png --with-tiff --with-xml \
  --without-{dps,fpx,gslib,lcms2,perl,trio,ttf,webp,wmf,x}
make
make install
popd
}

### FFMPEG ###
_build_ffmpeg() {
local VERSION="2.8.4"
local FOLDER="ffmpeg-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://www.ffmpeg.org/releases/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --enable-cross-compile --cross-prefix="${HOST}-" --prefix="${DEPS}" \
  --libdir="${DEST}/lib" --shlibdir="${DEST}/lib" --bindir="${DEST}/libexec" \
  --arch="arm" --target-os=linux --enable-shared --disable-static \
  --enable-rpath --enable-small --enable-zlib \
  --disable-debug
make
make install
popd
}

### KOKEN ###
_build_koken() {
local VERSION="0.21.9"
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
  _build_zlib
  _build_bzip
  _build_liblzma
  _build_libjpeg
  _build_libpng
  _build_libtiff
  _build_libxml2
  _build_graphicsmagick
  _build_imagemagick
  _build_ffmpeg
  _build_koken
  _build_elementary
  _build_installer
  _package
}
