# nokogiri requirements
%w( libxml2 libxml2-dev libxslt1-dev libxslt-ruby ).each { |pack| package pack }

gem_package "nokogiri"
