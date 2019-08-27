

mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp /vagrant/proc-bash-utils.spec ~/rpmbuild/SPECS/
rpmbuild -ba ~/rpmbuild/SPECS/proc-bash-utils.spec
