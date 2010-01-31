require 'simulation'
q1 = [[10, 20, 0.1,10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1]]
q2 = [[10, 20, 0.9,10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9]]

simulation1 = Simulation.new :node_count => 3, :packet_size => 10000, :flows_count => 100, :queue_settings => q1, :link_throughput => '0.05Mb'
simulation2 = Simulation.new :node_count => 3, :packet_size => 10000, :flows_count => 100, :queue_settings => q2, :link_throughput => '0.05Mb'

simulation1.run and simulation2.run

puts "\nFirst simulation:"
puts simulation1.result.inspect
puts "\nSecond simulation:"
puts simulation2.result.inspect

#puts simulation1.output
#puts simulation2.output
