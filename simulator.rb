#!/usr/bin/env ruby


SIMULATION_COMMAND = "ns router.tcl"

VARIABLES_MAP = {
  :packet_size => 'PACKET_SIZE',
  :node_count => 'NODE_COUNT',
  :flows_count => 'FLOWS_COUNT',
  :link_throughput => 'THROUGHPUT'
}

def run_simulation(options={})
  variables = options.collect do |variable_name, value|
    env_variable_name = VARIABLES_MAP[variable_name]
    raise Exception.new("Variable #{variable_name} is not defined!") unless env_variable_name
    "#{env_variable_name}='#{value}'"
  end
  system "#{variables.join(" ")} #{SIMULATION_COMMAND}"
end

puts "Running simulations..."
run_simulation :node_count => 3#, :packet_size => 100, :flows_count => 100, :link_throughput => '6Mb'
puts "da enda"
