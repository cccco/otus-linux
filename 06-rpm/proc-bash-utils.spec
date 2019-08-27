Name:           proc-bash-utils
Version:        0
Release:        1%{?dist}
Summary:        Bash scripts for process monitoring

License:        GPLv3
URL:            https://github.com/halaram/otus-linux/tree/master/05-proc
%undefine	_disable_source_fetch
Source0:        https://raw.githubusercontent.com/halaram/otus-linux/master/05-proc/ps-ax.sh
Source1:        https://raw.githubusercontent.com/halaram/otus-linux/master/05-proc/lsof.sh

BuildArch:      noarch

Requires:       bash >= 4.1

%description
Simple Bash scripts equivalent of ps and lsof


%prep


%build


%install
mkdir -p %{buildroot}%{_bindir}
install -D -p -m 0755 %{SOURCE0} %{buildroot}%{_bindir}
install -D -p -m 0755 %{SOURCE1} %{buildroot}%{_bindir}


%files
%{_bindir}/*

%changelog
* Tue Aug 27 2019 <halaram@gmail.com> 0-1
- Initial package
