package require tcltest
namespace import tcltest::*

# Add module dir to tm paths
set ThisScriptDir [file dirname [info script]]
set ModuleDir [file normalize [file join $ThisScriptDir ..]]
::tcl::tm::path add $ModuleDir

source [file join $ThisScriptDir test_helpers.tcl]

package require ornament
namespace import ornament::*


test compile-1 {Returns error when incorrect ! template command used} \
-setup {
  set tpl {
!hello
  }
} -body {
  compile $tpl
} -returnCodes {error} \
-result {unrecognized template command '!h' at start of line number: 2}


test compile-2 {Returns no error !! immediately followed by valid text} \
-setup {
  set tpl {
!!set a 4
a: $a
  }
} -body {
  llength [split [compile $tpl] "\n"]
} -returnCodes {OK} -result {7}


test compile-3 {Returns error when invalid commandChar used} \
-setup {
  set tpl {
!* commandChar <
  }
} -body {
  compile $tpl
} -returnCodes {error} -result {invalid config commandChar: <}


test run-1 {Returns correct result for template with no newline at end} \
-setup {
  set tpl {
Here is an addition:
  1 + 2 == [expr {1+2}]}
  set script [compile $tpl]
  set cmds [dict create]
} -body {
  run $script
} -result {
Here is an addition:
  1 + 2 == 3}


test run-2 {Returns correct result for template with newline at end} \
-setup {
  set tpl {
Here is an addition:
  1 + 2 == [expr {1+2}]
}
  set script [compile $tpl]
  set cmds [dict create]
} -body {
  run $script
} -result {
Here is an addition:
  1 + 2 == 3
}


test run-3 {Returns correct result when ! is used to create a loop} \
-setup {
  set tpl {
Here are [expr {1+2}] numbers:
!
! for {set i 0} {$i < 3} {incr i} {
    number: $i
! }
!
That's all folks!
}
  set script [compile $tpl]
  set cmds [dict create]
} -body {
  run $script
} -result {
Here are 3 numbers:
    number: 0
    number: 1
    number: 2
That's all folks!
}


test run-4 {Returns correct result when !! is used to create a loop} \
-setup {
  set tpl {
Here are [expr {1+2}] numbers:
!!
!! for {set i 0} {$i < 3} {incr i} {
    number: $i
!! }
!!
That's all folks!
}
  set script [compile $tpl]
  set cmds [dict create]
} -body {
  run $script
} -result {
Here are 3 numbers:
    number: 0
    number: 1
    number: 2
That's all folks!
}


test run-5 {Returns correct result when !# is as a comment} \
-setup {
  set tpl {
Here are [expr {1+2}] numbers:
!#########################
!# here are some comments
!#########################
!!
!! for {set i 0} {$i < 3} {incr i} {
    number: $i
!! }
!!
That's all folks!
}
  set script [compile $tpl]
  set cmds [dict create]
} -body {
  run $script
} -result {
Here are 3 numbers:
    number: 0
    number: 1
    number: 2
That's all folks!
}


test run-6 {Returns correct result when ! or !! are used in position other than first column} \
-setup {
  set tpl {
 ! this is just some text
 !! and so is this
I have something big to say!
and finally so is this
}
  set script [compile $tpl]
} -body {
  run $script
} -result {
 ! this is just some text
 !! and so is this
I have something big to say!
and finally so is this
}


test run-7 {Returns correct result when an external command is called} \
-setup {
  set tpl {
! plugin {
!   proc add2 {n} {
!     return [expr {$n + 2}]
!   }
! }
His name: [getvar name]
! set age [getvar age]
His age: $age
In two years he will be: [add2 $age]
}
  set vars [dict create name Roger age 37]
  set cmds [dict create \
    getvar [list ::TestHelpers::CmdGetVar $vars] \
    plugin ::TestHelpers::CmdPlugin \
  ]
  set script [compile $tpl]
} -body {
  run $script $cmds
} -result {
His name: Roger
His age: 37
In two years he will be: 39
}


test run-8 {Returns correct result when an external var is used} \
-setup {
  set tpl {
His name: $name
! set ageNext [expr {$age+1}]
His age: $age
Next year he will be: $ageNext
}
  set vars [dict create name Roger age 37]
  set script [compile $tpl]
} -body {
  run $script {} $vars
} -result {
His name: Roger
His age: 37
Next year he will be: 38
}


test run-9 {Returns error when invalid command used} \
-setup {
  set tpl {
! bob
  }
  set script [compile $tpl]
} -body {
  run $script
} -returnCodes {error} -result {invalid command name "bob"}


test run-10 {Returns error when invalid variable used} \
-setup {
  set tpl {
    $bob
  }
  set script [compile $tpl]
} -body {
  run $script
} -returnCodes {error} -result {can't read "bob": no such variable}


test run-11 {Returns correct result when ornament command changed} \
-setup {
  set tpl {
Some facts:
!* commandChar %
% set name "Fred"
%%set age 37
$name is $age
%* commandChar @
@# this is now a comment
@* commandChar ~
~# now this is a comment
~* commandChar !
!# now we're back to ! as the commandChar for this comment
}
  set script [compile $tpl]
} -body {
  run $script {} $vars
} -result {
Some facts:
Fred is 37
}


cleanupTests
