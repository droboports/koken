#!/usr/bin/env sh
#
# install script

prog_dir="$(dirname "$(realpath "${0}")")"
name="$(basename "${prog_dir}")"
data_dir="/mnt/DroboFS/Shares/DroboApps/.AppData/${name}"
tmp_dir="/tmp/DroboApps/${name}"
logfile="${tmp_dir}/install.log"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

# check firmware version
if ! /usr/bin/DroboApps.sh sdk_version &> /dev/null; then
  echo "Unsupported Drobo firmware, please upgrade to the latest version." > "${statusfile}"
  echo "4" > "${errorfile}"
fi

# install apache 2+
/usr/bin/DroboApps.sh install_version apache 2

# install mysql 5.6.26+
/usr/bin/DroboApps.sh install_version mysql 5.6.26

# migrate data folder to /mnt/DroboFS/Shares/DroboApps/.AppData
if [ ! -d "${data_dir}" ]; then
  mkdir -p "${data_dir}"
fi

# migrate data
mkdir -p "${data_dir}/storage/originals"
if [ -d "${prog_dir}/app/storage/originals" ] && [ ! -h "${prog_dir}/app/storage/originals" ]; then
  mv -f "${prog_dir}/app/storage/originals/"* "${data_dir}/storage/originals/" || true
  rmdir "${prog_dir}/app/storage/originals"
fi

if [ ! -h "${prog_dir}/app/storage/originals" ]; then
  ln -fs "${data_dir}/storage/originals" "${prog_dir}/app/storage/originals" || true
fi

# create koken password
openssl="/mnt/DroboFS/Shares/DroboApps/apache/libexec/openssl"
kokenpass="$(${openssl} rand -hex 10)"
echo "${kokenpass}" > "${prog_dir}/etc/.koken_password"
chmod 600 "${prog_dir}/etc/.koken_password"

if /mnt/DroboFS/Shares/DroboApps/mysql/scripts/mysql_db_exists.sh -n koken; then
  # update koken password
  /mnt/DroboFS/Shares/DroboApps/mysql/scripts/mysql_change_password.sh -n koken -u koken -p "${kokenpass}"
else
  # create koken database
  /mnt/DroboFS/Shares/DroboApps/mysql/scripts/mysql_create_db.sh -n koken -u koken -p "${kokenpass}"
fi

# generate database.php
cp -vf "${prog_dir}/app/storage/configuration/database.php.template" "${prog_dir}/app/storage/configuration/database.php"
sed -e "s|##0##|${kokenpass}|g" -i "${prog_dir}/app/storage/configuration/database.php"

# copy default configuration files
find "${prog_dir}" -type f -name "*.default" -print | while read deffile; do
  basefile="$(dirname "${deffile}")/$(basename "${deffile}" .default)"
  if [ ! -f "${basefile}" ]; then
    cp -vf "${deffile}" "${basefile}"
  fi
done

# upgrade steps
if [ ! -f "${prog_dir}/.update" ]; then
  touch "${prog_dir}/app/ready.txt"
  cp -vf "${prog_dir}/etc/installer.php" "${prog_dir}/app/index.php"
  rm -f "${prog_dir}/app/.htaccess"
else
  rm -f "${prog_dir}/.update"
fi
