set ns [new Simulator] 

set Out [open Out.ns w];   # file containing transfer 
                           # times of different connections
set Conn [open Conn.tr w]; # file containing the number of connections 

set tf   [open out.tr w];  # Open the Trace file

set pktSize    1000
set NodeNb       10; # Number of source nodes
set throughput 6Mb
$ns trace-all $tf    


#proc setNodes {ns throughput} {
  set Agw [$ns node]
  set Bgw [$ns node]
  set Core [$ns node]
set flink [$ns simplex-link $Core $Agw 10Mb 1ms dsRED/core]
set flink [$ns simplex-link $Core $Bgw 10Mb 1ms dsRED/core]

  $ns simplex-link $Agw $Core $throughput 0.1ms dsRED/edge
  $ns simplex-link $Core $Agw $throughput 0.1ms dsRED/core
  $ns queue-limit  $Core $Agw  100

  $ns simplex-link $Bgw $Core $throughput 0.1ms dsRED/edge
  $ns simplex-link $Core $Bgw $throughput 0.1ms dsRED/core
  $ns queue-limit  $Core $Bgw  100

  for {set i 1} {$i < 10} {incr i} {
    set A($i) [$ns node]
    $ns duplex-link $Agw $A($i) $throughput 0.01ms DropTail
    $ns queue-limit $A($i) $Agw 100

    set B($i) [$ns node]
    $ns duplex-link $Bgw $B($i) $throughput 0.01ms DropTail
    $ns queue-limit $B($i) $Bgw 100
  }

  #diff serv  
proc setQueue {ns s d} {
  set queueSD [[$ns link $s $d] queue]
  $queueSD       meanPktSize 40
  $queueSD   set numQueues_   1
  $queueSD    setNumPrec      2

  $queueSD addPolicyEntry [$s id] [$d id] TSW2CM 10 3000 0.02
  $queueSD addPolicerEntry TSW2CM 10 11
  $queueSD addPHBEntry  10 0 0 
  $queueSD addPHBEntry  11 0 1 
  $queueSD configQ 0 0 10 30 0.1
  $queueSD configQ 0 1 10 30 0.1
  
  $queueSD printPolicyTable
  $queueSD printPolicerTable

  set queueDS [[$ns link $d $s] queue]
  $queueDS meanPktSize      40
  $queueDS set numQueues_   1
  $queueDS setNumPrec      2
  $queueDS addPHBEntry  10 0 0 
  $queueDS addPHBEntry  11 0 1 
  $queueDS configQ 0 0 10 20 0.1
  $queueDS configQ 0 1 10 20 0.1


  return [list $queueSD $queueDS]
}

  set q1 [setQueue $ns $Bgw $Core]
  set qBC [lindex $q1 0]
  set qCB [lindex $q1 1]

  set q2 [setQueue $ns $Agw $Core]
  set qAC [lindex $q2 0]
  set qCA [lindex $q2 1]


#}


  set monfile [open mon.tr w]
  set fmon [$ns makeflowmon Fid]
  $ns attach-fmon $flink $fmon
  $fmon attach $monfile
  
  #TCP Sources, destinations, connections
  for {set i 1} {$i<=$NodeNb} { incr i } {
    for {set j 1} {$j<=$NumberFlows} { incr j } {
      set tcpsrc($i,$j) [new Agent/TCP/Newreno]
      set tcp_snk($i,$j) [new Agent/TCPSink]
      set k [expr $i*1000 +$j];
      $tcpsrc($i,$j) set fid_ $k
      $tcpsrc($i,$j) set window_ 2000
      $ns attach-agent $S($i) $tcpsrc($i,$j)
      $ns attach-agent $D $tcp_snk($i,$j)
      $ns connect $tcpsrc($i,$j) $tcp_snk($i,$j)
      set ftp($i,$j) [$tcpsrc($i,$j) attach-source FTP]
    }
  }
  
  # Generators for random size of files. 
  set rng1 [new RNG]
  $rng1 seed 22
  
  # Random inter-arrival times of TCP transfer at each source i
  set RV [new RandomVariable/Exponential]
  $RV set avg_ 0.2
  $RV use-rng $rng1 
  
  # Random size of files to transmit 
  set RVSize [new RandomVariable/Pareto]
  $RVSize set avg_ 10000 
  $RVSize set shape_ 1.25
  $RVSize use-rng $rng1
  
  # dummy command
  set t [$RVSize value]
  
  # We now define the beginning times of transfers and the transfer sizes
  # Arrivals of sessions follow a Poisson process.
  #
  for {set i 1} {$i<=$NodeNb} { incr i } {
    set t [$ns now]
  
    for {set j 1} {$j<=$NumberFlows} { incr j } {
  	  # set the beginning time of next transfer from source and attributes
  	  $tcpsrc($i,$j) set sess $j
  	  $tcpsrc($i,$j) set node $i
  	  set t [expr $t + [$RV value]]
  	  $tcpsrc($i,$j) set starts $t
      $tcpsrc($i,$j) set size [expr [$RVSize value]]
      $ns at [$tcpsrc($i,$j) set starts] "$ftp($i,$j) send [$tcpsrc($i,$j) set size]"
      $ns at [$tcpsrc($i,$j) set starts ] "countFlows $i 1"
    }
  }
  
  for {set j 1} {$j<=$NodeNb} { incr j } {
    set Cnts($j) 0
  }   
  
  # The following procedure is called whenever a connection ends
  Agent/TCP instproc done {} {
    global tcpsrc NodeNb NumberFlows ns RV ftp Out tcp_snk RVSize 
    # print in $Out: node, session, start time,  end time, duration,      
    # trans-pkts, transm-bytes, retrans-bytes, throughput   
  
    set duration [expr [$ns now] - [$self set starts] ] 
    set i [$self set node] 
    set j [$self set sess] 
    set time [$ns now] 
    puts $Out "$i \t $j \t $time \t\
        $time \t $duration \t [$self set ndatapack_] \t\
        [$self set ndatabytes_] \t [$self set  nrexmitbytes_] \t\
        [expr [$self set ndatabytes_]/$duration ]"    
  
  	  # update the number of flows
        countFlows [$self set node] 0
  
  }
}


proc countflows { ind sign } {
  global Cnts Conn NodeNb
  set ns [Simulator instance]
  if { $sign==0 } {
    set Cnts($ind) [expr $Cnts($ind) - 1] 
  } 
  elseif { $sign==1 } {
    set Cnts($ind) [expr $Cnts($ind) + 1] 
  }
  else { 
    puts -nonewline $Conn "[$ns now] \t"
    set sum 0
    for {set j 1} {$j<=$NodeNb} { incr j } {
      puts -nonewline $Conn "$Cnts($j) \t"
      set sum [expr $sum + $Cnts($j)]
    }
    puts $Conn "$sum"
    puts $Conn ""
    $ns at [expr [$ns now] + 0.2] "countFlows 1 3"
    puts "in count"
  }
}

#Define a 'finish' procedure
proc finish {} {
  global ns tf file2
  $ns flush-trace
  close $file2 
  exit 0
}         

#setNodes $ns 6Mb

  $ns run
