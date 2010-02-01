#!/usr/bin/env ruby
require 'simulation'
q1 = [[10, 20, 0.1,10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1]]
q2 = [[10, 20, 0.9,10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9]]

settings = { :node_count => 3,
             :packet_size => 10000,
             :flows_count => 1000,
             :link_throughput => '5Mb',
             :cir => 100, :pir => 100,
             :average_source_delay => '0.003'
           }

simulation1 = Simulation.new settings.merge({:queue_settings => q1})
simulation2 = Simulation.new settings.merge({:queue_settings => q2})

simulation1.run and simulation2.run

puts "\nFirst simulation:", simulation1.result.inspect, "\nSecond simulation:", simulation2.result.inspect

puts simulation1.output
puts simulation2.output
