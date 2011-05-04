name              "iptables"
maintainer        "Citrusbyte"
maintainer_email  "support@citrusbyte.com"
license           "Apache 2.0"
description       "Sets up common iptables firewall rules"
version           "0.1"

%w( debian ubuntu ).each do |os|
  supports os
end
