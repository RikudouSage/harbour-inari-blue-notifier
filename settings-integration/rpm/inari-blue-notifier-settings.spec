Name:       inari-blue-notifier-settings
Summary:    Settings integration for Inari Blue Notifier
Version:    1.0.0
Release:    1
License:    MIT
URL:        https://github.com/RikudouSage/harbour-inari-blue-notifier
Source0:    %{name}-%{version}.tar.bz2
BuildArch:  noarch
Requires:   harbour-inari-blue-notifier >= 1.7.1
Requires:   jolla-settings
Requires:   nemo-qml-plugin-dbus-qt5
Requires(posttrans): desktop-file-utils
Requires(postun): desktop-file-utils

%description
Adds Inari Blue Notifier to Sailfish OS settings and hides its launcher icon.

%prep
%setup -q -n %{name}-%{version}

%build

%install
install -D -m 644 inari-blue-notifier-settings.json %{buildroot}%{_datadir}/jolla-settings/entries/inari-blue-notifier-settings.json
install -D -m 644 InariBlueNotifierSettingsItem.qml %{buildroot}%{_datadir}/inari-blue-notifier-settings/InariBlueNotifierSettingsItem.qml
install -D -m 644 /dev/null %{buildroot}%{_datadir}/inari-blue-notifier-settings/hide-launcher

%posttrans
if [ -f "%{_datadir}/inari-blue-notifier-settings/hide-launcher" ] && \
   [ -f "%{_datadir}/applications/harbour-inari-blue-notifier.desktop" ]; then
    desktop-file-edit --set-key=NoDisplay --set-value=true "%{_datadir}/applications/harbour-inari-blue-notifier.desktop"
fi

%postun
if [ "$1" -eq 0 ] && [ -f "%{_datadir}/applications/harbour-inari-blue-notifier.desktop" ]; then
    desktop-file-edit --remove-key=NoDisplay "%{_datadir}/applications/harbour-inari-blue-notifier.desktop"
fi

%files
%defattr(-,root,root,-)
%{_datadir}/jolla-settings/entries/inari-blue-notifier-settings.json
%{_datadir}/inari-blue-notifier-settings
