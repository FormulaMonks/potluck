%w( libc6-dev libssl-dev libssl-dev libreadline5-dev zlib1g-dev ).each do |pkg|
  package pkg
end

script "install_ruby_from_source" do
  version = "1.9.2-p0"

  not_if "test -x /usr/bin/ruby#{version}"
  interpreter "bash"
  user "root"
  cwd "/tmp"
  # http://ubuntuforums.org/archive/index.php/t-1560070.html
  # FIXME: couldn't get this to work...
  code <<-BASH
    wget ftp://ftp.ruby-lang.org//pub/ruby/1.9/ruby-1.9.2-p0.tar.gz
    tar xvf ruby-#{version}.tar.gz
    cd ruby-#{version}
    autoconf
    ./configure --with-ruby-version=#{version} --prefix=/usr --program-suffix=#{version} \
      --with-openssl-dir=/usr --with-readline-dir=/usr --with-zlib-dir=/usr
    make
    make install
    update-alternatives \
      --install /usr/bin/ruby ruby /usr/bin/ruby#{version} 192 \
      --slave /usr/bin/erb erb /usr/bin/erb#{version} \
      --slave /usr/bin/irb irb /usr/bin/irb#{version} \
      --slave /usr/bin/rdoc rdoc /usr/bin/rdoc#{version} \
      --slave /usr/bin/ri ri /usr/bin/ri#{version}
      --slave /usr/bin/rake rake /usr/bin/rake#{version}
    update-alternatives --install /usr/bin/gem gem /usr/bin/gem#{version} 192
    update-alternatives --config ruby
    update-alternatives --config gem
  BASH
end

# install chef for 1.9
execute "gem1.9.2-p0 install chef --no-rdoc --no-ri" do
  not_if "cat /usr/bin/chef-solo | grep 1.9.2"
end
