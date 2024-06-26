#!/bin/sh

set -e

default_version=${1}
src_dir=${2}
out_file=${3}

if [ -d "${src_dir}/.git" ] && command -v git >/dev/null; then
	workdir=$(pwd)
	cd "${src_dir}"

	if git describe --tags >/dev/null 2>&1; then
		git_version=$(git describe --always --tags)
	else
		git_version="${default_version}"
	fi

	git_branch=$(git rev-parse --abbrev-ref HEAD)
	cd "${workdir}"

	new_version="${git_version} ($(date "+%b %d %Y"), branch: '${git_branch}')"
else
	new_version="${default_version}"
fi

new_version="#define TBAR_VERSION \"${new_version}\""

if [ -f "${out_file}" ]; then
	old_version=$(cat "${out_file}")
else
	old_version=""
fi

if [ "${old_version}" != "${new_version}"]; then
	echo "${new_version}" >"${out_file}"
fi
