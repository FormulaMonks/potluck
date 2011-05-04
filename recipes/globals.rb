def do_tail(log, via_sudo=false)
  via_sudo ? sudo("tail -f #{log}") : run("tail -f #{log}") do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:server]}: #{data}"
    break if stream == :err
  end
end

def message(message)
  puts
  puts "==============================================================================="
  puts
  puts message
  puts
  puts "==============================================================================="
  puts
end

# this relies on the convention that the first param to cap is always
# the name of the configuration we're using (i.e. staging, production, 
# etc...)
def configuration
  ARGV[0]
end

def require_params(*params)
  errors = []
  params.each do |param|
    errors << "Must provide value for #{param}" unless respond_to?(param)
  end

  puts "Must provide #{params.join(' ')}:\n\n\tcap <task> #{params.collect{ |p| "-s #{p}=foo"}.join(' ')}\n\n" if errors.any?
  errors.empty?
end

def before_all(task, namespace)
  namespace.tasks.each do |task_name, task_object|
    before [namespace.name, task_name].join(":"), task
  end
  
  namespace.namespaces.each do |namespace_name, namespace_object|
    before_all task, namespace_object
  end
end
