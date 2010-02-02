#!/usr/bin/env ruby
require 'simulation'
require "rubygems"
require "ruby-debug"
q1 = [[10, 20, 0.1,10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1], [10, 20, 0.1, 10, 20, 0.1]]
q2 = [[10, 20, 0.9,10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9], [10, 20, 0.9, 10, 20, 0.9]]

settings = { :node_count => 3,
             :packet_size => 1000,
             :flows_count => 100,
             :link_throughput => '4Mb',
             :cir => 30000, :pir => 60000,
             :average_source_delay => '0.1'
            }
            
File.open("output.log", "w") do |f|
  (0..10).each do |prob1|
    prob1 = prob1/10.to_f
    (0..10).each do |prob2|
      prob2 = prob2/10.to_f
      (0..10).each do |prob3|    
        prob3 = prob3/10.to_f
        q1 = [[10, 20, prob1,10, 20, prob1], [10, 20, prob2, 10, 20, prob2], [10, 20, prob3, 10, 20, prob3]]
        simulation1 = Simulation.new settings.merge({:queue_settings => q1})
        #simulation2 = Simulation.new settings.merge({:queue_settings => q2})

        simulation1.run #and simulation2.run
        hash = simulation1.result
        #debugger
        puts "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s}", hash.inspect, 100*(hash["All"][1].to_f/hash["All"][0].to_f) #, "\nSecond simulation:", simulation2.result.inspect
        f.write "\n#{prob1.to_s}, #{prob2.to_s}, #{prob3.to_s} " + hash.inspect + " " + (100*(hash["All"][1].to_f/hash["All"][0].to_f)).to_s
      end
    end
  end
end

#puts simulation2.output
