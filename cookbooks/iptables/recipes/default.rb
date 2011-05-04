execute "update_iptables" do
  user "root"
  command "iptables --list && iptables-save > /etc/iptables.rules.chef-#{Time.now.strftime("%Y%m%d%H%M%S")} && iptables-restore < /etc/iptables.rules"
  action :nothing
end

template "/etc/iptables.rules" do
  source "iptables.rules.erb"
  owner "root"
  group "root"
  notifies :run, resources(:execute => "update_iptables")
end
