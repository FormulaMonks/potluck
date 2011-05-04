#
# Cookbook Name:: googlechrome
# Recipe:: default
# Author:: Ben Alavi (ben@citrusbyte.com)
#
# Copyright 2011, Citrusbyte, LLC.
#
# Installs Google Chrome 12+ and Selenium Chrome Driver for using Chrome
# (therefore Webkit) w/ Selenium
# 

cookbook_file "/etc/apt/sources.list.d/google-chrome.list" do
  owner "root"
  group "root"
  mode "0644"
  source "google-chrome.list"
  action :create_if_missing
end

execute "add google signing key" do
  # not_if %Q{test -x }
  command %Q{wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -}
end

execute "apt-get update" do
  action :run
end

# Selenium Webdriver requires Chrome 12+
package "google-chrome-unstable"

script "install_chromedriver" do
  not_if "test -e /usr/local/bin/chromedriver"
  cwd "/tmp"
  interpreter "bash"
  user "root"
  code <<-BASH
    wget http://selenium.googlecode.com/files/chromedriver_linux32_12.0.727.0.zip -O chromedriver_linux32_12.0.727.0.zip
    unzip chromedriver_linux32_12.0.727.0.zip
    mv chromedriver /usr/local/bin/chromedriver
  BASH
end
