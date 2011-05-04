#
# Cookbook Name:: selenium
# Recipe:: default
#
# Sets up server for using selenium (not actually selenium itself). Perhaps
# should use a different name?
# 

# TODO: breakout Firefox now that we have googlechrome cookbook
# XServer + Firefox for Selenium testing
package "xinit"
package "x11-xserver-utils"
package "firefox"
  
# Install firebug for every user (most notably every selenium session ;))
package "unzip"
script "install_firebug_globally" do
  not_if "test -e /usr/lib/firefox-addons/extensions/firebug@software.joehewitt.com/license.txt"
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-BASH
    wget https://addons.mozilla.org/en-US/firefox/downloads/latest/1843/addon-1843-latest.xpi -O firebug.xpi
    mkdir -p /usr/lib/firefox-addons/extensions/firebug@software.joehewitt.com
    unzip -o firebug.xpi -d /usr/lib/firefox-addons/extensions/firebug@software.joehewitt.com
  BASH
end
  
# Allows anybody to access the X session (so you can remote it from SSH)
cookbook_file "/etc/X11/Xwrapper.config" do
  source "Xwrapper.config"
  mode "0600"
end
  
# Sets vagrant user's X display to the one on the VM
execute "export DISPLAY in profile" do
  not_if "cat ~vagrant/.profile | grep DISPLAY"
  user "vagrant"
  command %Q{echo "export DISPLAY=:0.0" >> ~vagrant/.profile}
end
  
# Sets VM to 1024x768 @ 24-bit color depth
cookbook_file "/etc/X11/xorg.conf" do
  source "xorg.conf"
  mode "0644"
end
