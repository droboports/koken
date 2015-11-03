#!/usr/bin/env sh
#
# reset script

prog_dir="$(dirname "$(realpath "${0}")")"
name="$(basename "${prog_dir}")"
data_dir="/mnt/DroboFS/Shares/DroboApps/.AppData/${name}"
tmp_dir="/tmp/DroboApps/${name}"
logfile="${tmp_dir}/reset.log"

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
#set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

/bin/sh "${prog_dir}/service.sh" stop

"/mnt/DroboFS/Shares/DroboApps/mysql/bin/mysql" --user="koken" --password="$(cat "${prog_dir}/etc/.koken_password")" koken << EOF
SET @tables = NULL;
SELECT GROUP_CONCAT(table_schema, '.', table_name) INTO @tables FROM information_schema.tables WHERE table_schema = 'koken';
SET @tables = CONCAT('DROP TABLE ', @tables);
PREPARE stmt FROM @tables;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
EOF

rm -fR "${data_dir}/storage/originals"
mkdir -p "${data_dir}/storage/originals"

/bin/cp -f "${prog_dir}/etc/installer.php" "${prog_dir}/app/index.php"
/bin/touch "${prog_dir}/app/ready.txt"
/bin/rm -f "${prog_dir}/app/.htaccess"

/bin/sh "${prog_dir}/service.sh" start
