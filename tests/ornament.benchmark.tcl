# Add module dir to tm paths
set ThisScriptDir [file dirname [info script]]
set ModuleDir [file normalize [file join $ThisScriptDir ..]]
::tcl::tm::path add $ModuleDir

package require ornament
namespace import ornament::*

proc bench_run {numIterations} {
  set tpl {
!* commandSubst true variableSubst true
Here are [expr {1+2}] numbers:
!!
!! for {set i 0} {$i < 10} {incr i} {
    number: $i
!! }
!!
That's all folks!
}
  set script [compile $tpl]
  time {run $script} $numIterations
}

set benchmarks {
  bench_run 100000
}

dict for {procName numIterations} $benchmarks {
  puts "$procName: [$procName $numIterations]"
}
