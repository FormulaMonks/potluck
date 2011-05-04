name              "server"
maintainer        "Citrusbyte"
maintainer_email  "support@citrusbyte.com"
license           "Apache 2.0"
description       "Sets up the basic server requirements for all stacks"
version           "0.2"

%w{debian ubuntu}.each do |os|
  supports os
end
