#!/usr/bin/env ruby


SIMULATION_COMMAND = "ns router.tcl"

VARIABLES_MAP = {
  :packet_size => 'PACKET_SIZE',
  :node_count => 'NODE_COUNT',
  :flows_count => 'FLOWS_COUNT',
  :link_throughput => 'THROUGHPUT',
  :cir => 'CIR',
  :pir => 'PIR'
}

class Simulation
  attr_accessor :command, :output, :queue_settings

  def self.run!(options={})
    sim = self.new(options)
    sim.run
    return sim
  end

  def initialize(options={})
    # minimum threshold, maximum threshold, dropping probability
    #                [   SD    ] [    DS    ]
    default_queue_settings = [[10, 20, 0.1,10, 20, 0.1], #10
                           [10, 20, 0.1,10, 20, 0.1], #11
                           [10, 20, 0.1,10, 20, 0.1]] #12
    
    self.queue_settings = options.delete(:queue_settings) || default_queue_settings

    variables = options.collect do |variable_name, value|
      env_variable_name = VARIABLES_MAP[variable_name]
      raise Exception.new("Variable #{variable_name} is not defined!") unless env_variable_name
      "#{env_variable_name}='#{value}'"
    end
    self.command = "#{variables.join(" ")} #{SIMULATION_COMMAND}"
    puts "Created command:\n  #{self.command}"
  end

  def run
    self.set_queue_settings
    puts "Issuing:\n  #{self.command}"
    self.output = eval "%x[#{ self.command }]"
  end
  
  def result
    table_text = self.output.split(/^=+$/).last
    table = table_text.split("\n").collect do |line|
      line.split(/(\t|\ )+/).delete_if {|str| str.empty? or str.match(/^(\t|\ )+$/)}
    end
    table.delete_at 2
    table.delete_at 0
    names = table.shift
    hashed_table = table.inject({}) {|sum, val| sum.merge({val.delete_at(0) => val})}
    puts "headers: #{names.join(' | ')}"
    return hashed_table
  end

  # this is a function that saves params to a file and exmple of the table that needs to be set
  def set_queue_settings
    queues = []
    self.queue_settings.each {|qp| queues << qp.join(" ")}
    queues = queues.join("\n")
    puts "Queue settings:\n-----------\n#{queues}\n-----------"
    queues_file = File.open("queue_params", "w") do |file|
      file.write queues 
    end
  end

end


#puts "Running simulations..."
#simulation = Simulation.run! :node_count => 3, :packet_size => 100, :flows_count => 10#, :link_throughput => '6Mb'
#puts "da enda"
puts "Run:\n   simulation = Simulation.run! :node_count => 3, :packet_size => 100, :flows_count => 10, :link_throughput => '6Mb', :cir => 3000, :pir => 10000"
