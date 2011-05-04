name              "ruby"
maintainer        "Citrusbyte"
maintainer_email  "support@citrusbyte.com"
license           "Apache 2.0"
description       "Installs ruby 1.9.2"
version           "0.1"

%w( debian ubuntu ).each do |os|
  supports os
end
