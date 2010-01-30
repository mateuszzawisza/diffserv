SIMULATION_COMMAND = "ns router.tcl"

VARIABLES_MAP = {
  :packet_size => 'PACKET_SIZE',
  :node_count => 'NODE_COUNT',
  :flows_count => 'FLOWS_COUNT',
  :link_throughput => 'THROUGHPUT'
}

class Simulation
  attr_accessor :command, :output

  def self.run!(options={})
    sim = self.new(options)
    sim.run
    return sim
  end

  def initialize(options={})
    variables = options.collect do |variable_name, value|
      env_variable_name = VARIABLES_MAP[variable_name]
      raise Exception.new("Variable #{variable_name} is not defined!") unless env_variable_name
      "#{env_variable_name}='#{value}'"
    end
    self.command = "#{variables.join(" ")} #{SIMULATION_COMMAND}"
    puts "Created command:\n  #{self.command}"
  end

  def run
    puts "Issuing:\n  #{self.command}"
    self.output = eval "%x[#{ self.command }]"
  end
  
  def parse_outuput
    puts self.output
  end
end

puts "Running simulations..."
simulation = Simulation.run! :node_count => 3, :packet_size => 100, :flows_count => 10#, :link_throughput => '6Mb'
puts "da enda"
