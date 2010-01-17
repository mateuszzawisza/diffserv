set ns [new Simulator] 

proc createRouter {ns throughput nodes} {
  set Agw [$ns node]
  set Bgw [$ns node]
  # $ns duplex-link  $S($j) $E($j)  6Mb   0.01ms DropTail
  $ns simplex-link $Agw $Bgw $throughput 0.1ms dsRED/edge
  $ns simplex-link $Bgw $Agw $throughput 0.1ms dsRED/core
  # $ns queue-limit $S($j) $E($j) 100


  set queue_AB [[$ns link $Agw $Bgw] queue]
  $queue_AB       meanPktSize 40
  $queue_AB   set numQueues_   1
  $queue_AB    setNumPrec      2

  foreach node $nodes {
   $queue_AB addPolicyEntry [$Agw id] [$Bgw id] TSW2CM 10 3000 0.02
  }

  $queue_AB addPolicerEntry TSW2CM 10 11
  $queue_AB addPHBEntry  10 0 0 
  $queue_AB addPHBEntry  11 0 1 
  $queue_AB configQ 0 0 10 30 0.1
  $queue_AB configQ 0 1 10 30 0.1
  
  $queue_AB printPolicyTable
  $queue_AB printPolicerTable
}


set a [$ns node]
set b [$ns node]
set c [$ns node]
set nodes [list a b c]

createRouter $ns 6Mb $nodes
