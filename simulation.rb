#!/usr/bin/env ruby


SIMULATION_COMMAND = "ns router.tcl"

VARIABLES_MAP = {
  :packet_size => 'PACKET_SIZE',
  :node_count => 'NODE_COUNT',
  :flows_count => 'FLOWS_COUNT',
  :link_throughput => 'THROUGHPUT',
  :cir => 'CIR',
  :pir => 'PIR',
  :average_source_delay => 'AVERAGE_SOURCE_DELAY',
  :simulation_duration => 'SIMULATION_DURATION',
  :average_file_size => 'AVERAGE_FILE_SIZE'
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
    #puts "Created command:\n  #{self.command}"
  end

  def run
    self.set_queue_settings
    #puts "Issuing:\n  #{self.command}"
    self.output = eval "%x[#{ self.command }]"
  end
  
  def result
    tables = self.output.split(/^=+$/)
    tables.shift
    tables.pop
    tables = tables.collect {|table| t = table.split("\n"); t.shift; t.shift; t.shift; t.pop; t.pop; t}
    tables = tables.collect do |table|

      table = table.collect do |row|
        row.split(/(\t|\ )+/).delete_if {|str| str.empty? or str.match(/^(\t|\ )+$/)}
      end
      table.inject({}) {|sum, row| sum.merge({row.shift => row})}
    end
    return tables.collect {|t| StatRecord.new(t)}
  end
  
  def optimized_result
    r= self.result
    if r.count < 4
      raise Exception.new 'too less results to count average...'
    else
      return r[3*r.count/4] - r[r.count/4]
    end
  end

  # this is a function that saves params to a file and exmple of the table that needs to be set
  def set_queue_settings
    queues = []
    self.queue_settings.each {|qp| queues << qp.join(" ")}
    queues = queues.join("\n")
    #puts "Queue settings:\n-----------\n#{queues}\n-----------"
    queues_file = File.open("queue_params", "w") do |file|
      file.write queues 
    end
  end

  class StatRecord
    QUEUE_NAMES = [:all, :red, :yellow, :green]
    attr_accessor *QUEUE_NAMES
    def initialize(options={})
      self.all = options.delete('All') || [0,0,0,0]
      self.red = options.delete('12') || [0,0,0,0]
      self.yellow = options.delete('11') || [0,0,0,0]
      self.green = options.delete('10') || [0,0,0,0]
      QUEUE_NAMES.each do |queue|
         self.send "#{queue.to_s}=", (self.send(queue.to_s).collect {|x| x.to_i})
      end
    end
    
    def -(s)
      r = self.class.new
      QUEUE_NAMES.each do |queue|
         q1 = self.send queue
         q2 = s.send queue
         result = []
         q1.each_with_index do |x, index|
           result << x.to_i - q2[index].to_i
         end
         r.send "#{queue.to_s}=", result
      end
      return r
    end
    
    def to_s
      r = QUEUE_NAMES.collect do |queue|
        "#{queue.to_s.capitalize[0..0]}, #{self.send(queue).join(', ')}"
      end
      return r.join ', '
    end

    def inspect(hardcore=false)
      count_sum = self.all.first
      green_count = self.green.first 
      yellow_count = self.yellow.first
      red_count = self.red.first
      green_percentage  = count_sum > 0 ? (100.to_f * green_count / count_sum).round  : 0
      yellow_percentage = count_sum > 0 ? (100.to_f * yellow_count / count_sum).round : 0
      red_percentage    = count_sum > 0 ? (100.to_f * red_count / count_sum).round    : 0
      green_ldrops_percentage  = green_count > 0  ? self.green[2] / green_count    : 0
      green_edrops_percentage  = green_count > 0  ? self.green[3] / green_count    : 0
      yellow_ldrops_percentage = yellow_count > 0 ? self.yellow[2] / yellow_count  : 0
      yellow_edrops_percentage = yellow_count > 0 ? self.yellow[3] / yellow_count  : 0
      red_ldrops_percentage    = red_count > 0    ? self.red[2] / red_count        : 0
      red_edrops_percentage    = red_count > 0    ? self.red[3] / red_count        : 0
      puts self.to_s if hardcore
      return "SUM: #{count_sum}, G: #{green_percentage}#{green_count == 0 ? '' : '%'}, Y: #{yellow_percentage}#{yellow_count == 0 ? '' : '%'}, R: #{red_percentage}#{red_count == 0 ? '' : '%'}" \
      +  "\nLdrops     G: #{green_ldrops_percentage}%, Y: #{yellow_ldrops_percentage}%, R: #{red_ldrops_percentage}%" \
      +  "\nEdrops     G: #{green_edrops_percentage}%, Y: #{yellow_edrops_percentage}%, R: #{red_edrops_percentage}%"
    end
  end

end


##puts "Running simulations..."
#simulation = Simulation.run! :node_count => 3, :packet_size => 100, :flows_count => 10#, :link_throughput => '6Mb'
##puts "da enda"
#puts "Run:\n   simulation = Simulation.run! :node_count => 3, :packet_size => 100, :flows_count => 10, :link_throughput => '6Mb', :cir => 3000, :pir => 10000"
