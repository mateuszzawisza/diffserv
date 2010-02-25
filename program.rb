#!/usr/bin/env ruby
require 'simulation'
require "rubygems"
require "ruby-debug"
default_queue = [[10, 20, 0.1,10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1]]

settings = { :node_count => 1,
             :packet_size => 100,
             :flows_count => 100,
             :link_throughput => '6Mb',
             :average_source_delay => '0.7',
             :queue_settings => default_queue,
             :average_file_size => 200000,
             :cir => 2000000,
             :pir => 3000000
            }

File.open("output/program.log", "w") do |f|
  simulation = Simulation.run! settings
  result = simulation.result.last
  #result = simulation.optimized_result
  puts result.inspect
#  puts simulation.theoretical_user_load, simulation.cir, simulation.pir, simulation.theoretical_link_load
  t_green = 100 * simulation.cir / simulation.theoretical_user_load
  t_red = 100 - (100*simulation.pir / simulation.theoretical_user_load)
  t_yellow = 100 - t_green - t_red
#  puts "theor. G: #{t_green}, Y: #{t_yellow}, R: #{t_red}"
#  puts "time: #{simulation.result.count/10}s"
#  puts "ther.load = #{simulation.average_file_size * simulation.flows_count * 10 * 8 / simulation.result.count }"
#  puts simulation.output
#  puts "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s}", hash
#  f.write "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s}, " + hash.to_s
end
            
#File.open("output/program.log", "w") do |f|
##  (0..10).each do |prob1|
##    prob1 = prob1/10.to_f
##    (0..10).each do |prob2|
##      prob2 = prob2/10.to_f
##      (0..10).each do |prob3|    
##        prob3 = prob3/10.to_f
##        q1 = [[10, 20, prob1,10, 20, prob1], [10, 20, prob2, 10, 20, prob2], [10, 20, prob3, 10, 20, prob3]]
#        simulation1 = Simulation.new settings.merge({
#        #simulation2 = Simulation.new settings.merge({:queue_settings => q2})
#
#        simulation1.run #and simulation2.run
#        hash = simulation1.optimized_result
#        #debugger
#        puts "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s}", hash
#        #.inspect, 100*(hash["All"][1].to_f/hash["All"][0].to_f) #, "\nSecond simulation:", simulation2.result.inspect
#        f.write "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s}, " + hash.to_s
#        #.inspect + " " + (100*(hash["All"][1].to_f/hash["All"][0].to_f)).to_s
##      end
##    end
##  end
#end

#puts simulation2.output
