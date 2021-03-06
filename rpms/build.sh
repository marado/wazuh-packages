#!/bin/bash

set -exf
# Optional package release
build_target=$1
wazuh_version=$2
architecture_target=$3
threads=$4
package_release=$5
directory_base=$6
if [ -z "${package_release}" ]; then
    package_release="1"
fi

# Build directories
build_dir=/build_wazuh
rpm_build_dir=${build_dir}/rpmbuild
mkdir -p ${rpm_build_dir}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# Generating source tar.gz
package_name=wazuh-${build_target}-${wazuh_version}
cd ${build_dir} && tar cvzf "${rpm_build_dir}/SOURCES/${package_name}.tar.gz" "${package_name}"

# Including spec file
mv ${build_dir}/wazuh.spec ${rpm_build_dir}/SPECS/${package_name}.spec

if [ "${architecture_target}" == "i386" ]; then
    linux="linux32"
fi

# Building RPM
$linux rpmbuild --define "_topdir ${rpm_build_dir}" --define "_threads ${threads}" \
        --define "_release ${package_release}" --define "_localstatedir ${directory_base}" \
        --target ${architecture_target} -ba ${rpm_build_dir}/SPECS/${package_name}.spec

find ${rpm_build_dir} -name "*.rpm" -exec mv {} /var/local/wazuh \;
