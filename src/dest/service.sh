#!/usr/bin/env sh
#
# Service.sh for koken

# import DroboApps framework functions
. /etc/service.subr

framework_version="2.1"
name="koken"
version="0.21.11"
description="Content management and web site publishing for photographers"
depends="apache mysql"
webui="WebUI"

prog_dir="$(dirname "$(realpath "${0}")")"
conffile="${prog_dir}/etc/kokenapp.conf"
apachefile="${DROBOAPPS_DIR}/apache/conf/includes/kokenapp.conf"
daemon="${DROBOAPPS_DIR}/apache/service.sh"
tmp_dir="/tmp/DroboApps/${name}"
pidfile="${tmp_dir}/pid.txt"
logfile="${tmp_dir}/log.txt"
statusfile="${tmp_dir}/status.txt"
errorfile="${tmp_dir}/error.txt"

# check firmware version
_firmware_check() {
  local rc
  local semver
  rm -f "${statusfile}" "${errorfile}"
  if [ -z "${FRAMEWORK_VERSION:-}" ]; then
    echo "Unsupported Drobo firmware, please upgrade to the latest version." > "${statusfile}"
    echo "4" > "${errorfile}"
    return 1
  fi
  semver="$(/usr/bin/semver.sh "${framework_version}" "${FRAMEWORK_VERSION}")"
  if [ "${semver}" == "1" ]; then
    echo "Unsupported Drobo firmware, please upgrade to the latest version." > "${statusfile}"
    echo "4" > "${errorfile}"
    return 1
  fi
  return 0
}

start() {
  _firmware_check
  # ensure plugins are enabled
  cp -vf "${conffile}" "${apachefile}"
  "${daemon}" restart || true
  return 0
}

is_running() {
  if [ -e "${apachefile}" ]; then
    return 0
  fi
  return 1
}

stop() {
  rm -vf "${apachefile}"
  "${daemon}" restart || true
  return 0
}

force_stop() {
  stop
}

# boilerplate
if [ ! -d "${tmp_dir}" ]; then mkdir -p "${tmp_dir}"; fi
exec 3>&1 4>&2 1>> "${logfile}" 2>&1
STDOUT=">&3"
STDERR=">&4"
echo "$(date +"%Y-%m-%d %H-%M-%S"):" "${0}" "${@}"
set -o errexit  # exit on uncaught error code
set -o nounset  # exit on unset variable
set -o xtrace   # enable script tracing

main "${@}"
