global tcpsrc NodeCount FlowsCount ns randomVariable ftp TransferLogFile tcp_snk RandomFileSize 
# The following procedure is called whenever a connection ends
Agent/TCP instproc done {} {
global tcpsrc NodeCount FlowsCount ns randomVariable ftp TransferLogFile tcp_snk RandomFileSize 
# puts -nonewline "."
#logMessage "connection ended!"
  # print in $TransferLogFile: node, session, start time,  end time, duration,      
  # trans-pkts, transm-bytes, retrans-bytes, throughput   

  set duration [expr [$ns now] - [$self set starts] ] 
  set i [$self set node] 
  set j [$self set sess] 
  set time [$ns now] 
  puts $TransferLogFile "$i \t $j \t $time \t\
      $time \t $duration \t [$self set ndatapack_] \t\
      [$self set ndatabytes_] \t [$self set  nrexmitbytes_] \t\
      [expr [$self set ndatabytes_]/$duration ]"    

      countFlows [$self set node] 0

  global connectionsLeft
  set connectionsLeft [expr $connectionsLeft - 1]

   if {$connectionsLeft < 1} {
     [finish]
   }
}

proc countFlows { ind sign } {
  global Cnts ConnectionNumberLogFile NodeCount
  set ns [Simulator instance]
  if { $sign==0 } {
    set Cnts($ind) [expr $Cnts($ind) - 1] 
  } elseif { $sign==1 } {
    set Cnts($ind) [expr $Cnts($ind) + 1] 
  } else { 
    puts -nonewline $ConnectionNumberLogFile "[$ns now] \t"
    set sum 0
    for {set j 1} {$j<=$NodeCount} { incr j } {
      puts -nonewline $ConnectionNumberLogFile "$Cnts($j) \t"
      set sum [expr $sum + $Cnts($j)]
    }
    puts $ConnectionNumberLogFile "$sum"
    puts $ConnectionNumberLogFile ""
    $ns at [expr [$ns now] + 0.2] "countFlows 1 3"
    puts "in count"
  }
}

proc logMessage { message } {
#  puts "\n\n*****************************************\n"
#  puts $message
#  puts "\n*****************************************\n\n"
}

proc setQueue {ns s d a b nodeCount} {

  global queueParams
  global cir pir

  logMessage "setting up a queue"
  set queueSD [[$ns link $s $d] queue]
  $queueSD meanPktSize 40
  $queueSD set numQueues_ 1
  $queueSD setNumPrec 2
  $queueSD addPolicerEntry TSW3CM 10 11 12
  $queueSD addPHBEntry  10 0 0 
  $queueSD addPHBEntry  11 0 1 
  $queueSD addPHBEntry  12 0 2 
  $queueSD configQ 0 0 $queueParams(10,1) $queueParams(10,2) $queueParams(10,3)
  $queueSD configQ 0 1 $queueParams(11,1) $queueParams(11,2) $queueParams(11,3)
  $queueSD configQ 0 2 $queueParams(12,1) $queueParams(12,2) $queueParams(12,3)
  $queueSD printPHBTable

  set queueDS [[$ns link $d $s] queue]
  $queueDS meanPktSize      40
  $queueDS set numQueues_   1
  $queueDS setNumPrec      2
  #$queueDS addPolicerEntry TSW3CM 10 11 12
  $queueSD setMREDMode RIO-D
  $queueDS addPHBEntry  10 0 0 
  $queueDS addPHBEntry  11 0 1 
  $queueDS addPHBEntry  12 0 2 
  $queueDS configQ 0 0 $queueParams(10,4) $queueParams(10,5) $queueParams(10,6)
  $queueDS configQ 0 1 $queueParams(11,4) $queueParams(11,5) $queueParams(11,6)
  $queueDS configQ 0 2 $queueParams(12,4) $queueParams(12,5) $queueParams(12,6)
  $queueDS printPHBTable



  puts "queueSD configQ 0 0 $queueParams(10,1) $queueParams(10,2) $queueParams(10,3)"
  puts "queueSD configQ 0 1 $queueParams(11,1) $queueParams(11,2) $queueParams(11,3)"
  puts "queueSD configQ 0 2 $queueParams(12,1) $queueParams(12,2) $queueParams(12,3)"
  puts "queueDS configQ 0 0 $queueParams(10,4) $queueParams(10,5) $queueParams(10,6)"
  puts "queueDS configQ 0 1 $queueParams(11,4) $queueParams(11,5) $queueParams(11,6)"
  puts "queueDS configQ 0 2 $queueParams(12,4) $queueParams(12,5) $queueParams(12,6)"

  upvar $a A
  upvar $b B

  for {set i 1} {$i<=$nodeCount} { incr i } {
    for {set j 1} {$j<=$nodeCount} { incr j } {
      set codepoint 10
  #    if {$i <= [expr $nodeCount / 2]} {
  #      set codepoint 10
  #    } else {
  #      set codepoint 11
  #    }
      puts "A($i) = [$A($i) id]    --->     B($j) = [$B($j) id]"
      $queueSD addPolicyEntry [$A($i) id] [$B($j) id] TSW3CM $codepoint $cir $pir
      puts "queueSD addPolicyEntry [$A($i) id] [$B($j) id] TSW3CM $codepoint $cir $pir"
     # puts "A($i) = [$A($j) id]    <---     B($i) = [$B($j) id]"
     # $queueDS addPolicyEntry [$B($i) id] [$A($j) id] TSW3CM $codepoint $cir $pir
    }
  }

  #  set importantClass [new CBQClass]
  #  set normalClass [new CBQClass]
  #
  #
  #  $importantClass setparams none true 0.5 1 0 1 0.1
  #  $normalClass    setparams none true 0.5 1 9 1 0.1
  #  # $cbqclass setparams <parent> <okborrow> <allot> <maxidle> <prio> <level>
  #
  #  # $cbqclass install-queue <q>
  #
  #  # okborrow_ is a boolean indicating the class is permitted to borrow bandwidth from its parent.
  #
  #  # allot_ is the maximum fraction of link bandwidth allocated to the class expressed as a real number between 0.0 and 1.0
  #
  #  # maxidle_ is the maximum amount of time a class may be required to have its packets queued before they are permitted to be forwarded
  #
  #  # priority_ is the class’ priority level with respect to other classes. This value may range from 0 to 10, and more than one class may exist at the same priority. Priority 0 is the highest priority.
  #
  #  # level_ is the level of this class in the link-sharing tree. Leaf nodes in the tree are considered to be at level 1; their parents are at level 2, etc.
  #
  #  # extradelay_ increase the delay experienced by a delayed class by the speciﬁed time
  #
  #  $importantClass install-queue $queueDS
  #  $importantClass install-queue $queueSD
  #  $normalClass install-queue $queueDS
  #  $normalClass install-queue $queueSD


  $queueSD printPolicyTable
  $queueSD printPolicerTable

  #$queueDS printPolicyTable
  #$queueDS printPolicerTable

  return [list $queueSD $queueDS]
}

proc finish {} {
  logMessage "finished"
  global ns qAC
  $ns flush-trace
  # puts "\n\nFinished.\n\n"
  $qAC printStats
  exit 0
}         

proc readFromEnvOrDefault {variableName defaultValue} {
  global env
  if { [info exists env($variableName)] } {
    set passedValue $env($variableName)
    puts "$variableName set to $passedValue"
    return $passedValue
  } else {
    puts "$variableName not found, defaulted to $defaultValue"
    return $defaultValue
  }
}

proc initQueueParams {} {
  set QueuesParamsFile [open "queue_params" r]
  set QueuesParamsRead [read $QueuesParamsFile] 
  set QueuesParamsLines [split $QueuesParamsRead "\n"]
  
  set codePoint 10
  
  foreach line $QueuesParamsLines {
    set values [split $line " "]
    set i 1
    foreach value $values {
      set queueParams($codePoint,$i) $value 
      incr i
    }
    incr codePoint
  }
  return [array get queueParams]
}

#########################################################################################################


set ns [new Simulator] 

set TransferLogFile [open output/TransferLogFile.ns w];   # file containing transfer 
set LinkLogFile [open output/link_AC_log.tr w]

set packetSize [readFromEnvOrDefault PACKET_SIZE 1000]; # packet size
set simulationDuration [readFromEnvOrDefault SIMULATION_DURATION 10]; # simulation duration
set NodeCount  [readFromEnvOrDefault NODE_COUNT  4   ]; # Number of source nodes
set FlowsCount [readFromEnvOrDefault FLOWS_COUNT 10  ]; # Number of flows per source node 
set throughput [readFromEnvOrDefault THROUGHPUT  5Mb ]; # router's thorughput
set averageFileSize [readFromEnvOrDefault AVERAGE_FILE_SIZE 1000 ]; # average file size

#$ns trace-all $traceFile    

set connectionsLeft [expr $FlowsCount * $NodeCount]



# setting up queues attributes

set cir [readFromEnvOrDefault CIR  3000]; # end-users' cir value
set pir [readFromEnvOrDefault PIR 10000]; # end-users' pir value

set averageSourceTransferDelay [readFromEnvOrDefault AVERAGE_SOURCE_DELAY 0.1]; # average delay before a source starts the next transfer

array set queueParams [initQueueParams]
 


###############################  MAIN NODES  ###############################

set Agw [$ns node]
set Bgw [$ns node]
set Core [$ns node]

###############################  MAIN LINKS  ###############################

set linkAC [$ns simplex-link $Agw $Core $throughput 0.1ms dsRED/edge]
set linkCA [$ns simplex-link $Core $Agw $throughput 0.1ms dsRED/core]
$ns queue-limit  $Core $Agw  100

#set linkBC [$ns duplex-link $Bgw $Core $throughput 0.1ms dsRED/core]
set linkBC [$ns simplex-link $Bgw $Core $throughput 0.1ms dsRED/edge]
set linkCB [$ns simplex-link $Core $Bgw $throughput 0.1ms dsRED/core]
$ns queue-limit  $Core $Bgw  100



###############################  FLOW MONITOR  ###############################

# set linkFlowMonitor [$ns makeflowmon Fid]
# $ns attach-fmon $linkAC $linkFlowMonitor
# $linkFlowMonitor attach $LinkLogFile



###############################  END NODES AND LINKS  ###############################

for {set i 1} {$i <= $NodeCount} {incr i} {
  set A($i) [$ns node]
  $ns duplex-link $Agw $A($i) $throughput 0.01ms DropTail
  $ns queue-limit $A($i) $Agw 100

  set B($i) [$ns node]
  $ns duplex-link $Bgw $B($i) $throughput 0.01ms DropTail
  $ns queue-limit $B($i) $Bgw 100
}


###############################  QUEUES  ###############################

set q1 [setQueue $ns $Bgw $Core B A $NodeCount]
set qBC [lindex $q1 0]
set qCB [lindex $q1 1]

set q2 [setQueue $ns $Agw $Core A B $NodeCount]
set qAC [lindex $q2 0]
set qCA [lindex $q2 1]

###############################  SOURCES  ###############################

logMessage "setting up sources"
for {set i 1} {$i <= $NodeCount} { incr i } {
  for {set j 1} {$j <= $FlowsCount} { incr j } {
    set tcpsrc($i,$j) [new Agent/TCP/Newreno]
    set tcp_snk($i,$j) [new Agent/TCPSink]
    set k [expr $i*1000 +$j];
    $tcpsrc($i,$j) set fid_ $k
    $tcpsrc($i,$j) set window_ 20
    $tcpsrc($i,$j) set packetSize_ $packetSize
    $ns attach-agent $A($i) $tcpsrc($i,$j)
    $ns attach-agent $B($i) $tcp_snk($i,$j)
    $ns connect $tcpsrc($i,$j) $tcp_snk($i,$j)
    set ftp($i,$j) [$tcpsrc($i,$j) attach-source FTP]
  }
}
logMessage "Generators for random size of files."
# Generators for random size of files. 
set randomNumberGenerator [new RNG]
$randomNumberGenerator seed 22

# Random inter-arrival times of TCP transfer at each source i
set randomVariable [new RandomVariable/Exponential]
$randomVariable set avg_ $averageSourceTransferDelay
$randomVariable use-rng $randomNumberGenerator 

logMessage "Random size of files to transmit"
set RandomFileSize [new RandomVariable/Pareto]
$RandomFileSize set avg_ $averageFileSize 
$RandomFileSize set shape_ 1.25
$RandomFileSize use-rng $randomNumberGenerator


# We now define the beginning times of transfers and the transfer sizes
# Arrivals of sessions follow a Poisson process.

logMessage "defining beginning times of transfers"
for {set i 1} {$i<=$NodeCount} { incr i } {
  set t 0
  #[$ns now]

  for {set j 1} {$j<=$FlowsCount} { incr j } {
	  # set the beginning time of next transfer from source and attributes
	  $tcpsrc($i,$j) set sess $j
	  $tcpsrc($i,$j) set node $i
	  set t [expr $t + [$randomVariable value]]
	  $tcpsrc($i,$j) set starts $t
    $tcpsrc($i,$j) set size [expr [$RandomFileSize value]]
    $ns at [$tcpsrc($i,$j) set starts] "$ftp($i,$j) send [$tcpsrc($i,$j) set size]"
    $ns at [$tcpsrc($i,$j) set starts] "countFlows $i 1"
  }
}

logMessage "setting smthng"
for {set j 1} {$j<=$NodeCount} { incr j } {
  set Cnts($j) 0
}   
 
# puts "\n\nRunning!\n\n"
for {set j 1} {$j<=10000} { incr j } {
	 $ns at [expr $j/10] "$qAC printStats"
	
	 # $ns at 0.1 "puts 1"
 }

#$ns at $simulationDuration "finish"

$ns run
