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



# this is function that saves params to fiel and exmple of table that needs to be set
def set_queue_params(queue_params)
  queues = []
  queue_params.each {|qp| queues << qp.join(" ")}
  queues = queues.join("\n")
  queues_file = File.open("queue_params", "w") do |file|
    puts queues
    file.write queues 
  end
end

# minimum threshold, maximum threshold, dropping probability
#                [   SD    ] [    DS    ]
queue_params = [[10, 20, 0.1,10, 20, 0.1], #10
                [10, 20, 0.1,10, 20, 0.1], #11
                [10, 20, 0.1,10, 20, 0.1]] #12

set_queue_params queue_params
