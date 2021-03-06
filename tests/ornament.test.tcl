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
  set tpl {!* commandChar <}
} -body {
  compile $tpl
} -returnCodes {error} -result {invalid config commandChar value: <}

test compile-4 {Returns error when invalid config field used} \
-setup {
  set tpl {
!* ommandChar <
  }
} -body {
  compile $tpl
} -returnCodes {error} -result {invalid config field: ommandChar}

test compile-5 {Returns error when odd number of config entries} \
-setup {
  set tpl {
!* commandChar
  }
} -body {
  compile $tpl
} -returnCodes {error} -result {invalid config string}

test compile-6 {Returns error when invalid commandChar used specifically * as slipping through} \
-setup {
  set tpl {!* commandChar *}
} -body {
  compile $tpl
} -returnCodes {error} -result {invalid config commandChar value: *}


test run-1 {Returns correct result for template with no newline at end} \
-setup {
  set tpl {
!* commandSubst true
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
!* commandSubst true
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
!* commandSubst true variableSubst true
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
!* commandSubst true variableSubst true
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
!* commandSubst true variableSubst true
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
!* commandSubst true variableSubst true
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
!* commandSubst true variableSubst true
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
!* variableSubst true
    $bob
  }
  set script [compile $tpl]
} -body {
  run $script
} -returnCodes {error} -result {can't read "bob": no such variable}


test run-11 {Returns correct result when ornament command changed} \
-setup {
  set tpl {
!* variableSubst true
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
  run $script
} -result {
Some facts:
Fred is 37
}


test run-12 {Returns correct result when config variableSubst changed} \
-setup {
  set tpl {
A person called: $name
!* variableSubst true
A person called: $name
!* variableSubst false
A person called: $name
}
  set vars {name Harry}
  set script [compile $tpl]
} -body {
  run $script {} $vars
} -result {
A person called: $name
A person called: Harry
A person called: $name
}


test run-13 {Returns correct result when config commandSubst changed} \
-setup {
  set tpl {
1 + 2 == [expr {1+2}]
!* commandSubst true
1 + 2 == [expr {1+2}]
!* commandSubst false
1 + 2 == [expr {1+2}]
}
  set script [compile $tpl]
} -body {
  run $script
} -result {
1 + 2 == [expr {1+2}]
1 + 2 == 3
1 + 2 == [expr {1+2}]
}


test run-14 {Returns correct result when config backslashSubst changed} \
-setup {
  set tpl {
hello\n
!* backslashSubst true
hello\n
!* backslashSubst false
hello\n
}
  set script [compile $tpl]
} -body {
  run $script
} -result {
hello\n
hello

hello\n
}

test run-15 {Returns correct result when \ used at end of a ! or !! line} \
-setup {
  set tpl {
!* variableSubst true
! set nums [list 1 2 \
                3 4]
!! set letters [list a b \
                     c d]
! foreach n $nums {
    $n
! }
! foreach l $letters {
    $l
! }
}
  set script [compile $tpl]
} -body {
  run $script
} -result {
    1
    2
    3
    4
    a
    b
    c
    d
}


test run-16 {Returns correct result when !\ used instead of a continued ! line} \
-setup {
  set tpl {
!* variableSubst true
!\ for {set i 0}
!\     {$i < 5}
!      {incr i} {
      $i
!   }
}
  set script [compile $tpl]
} -body {
  run $script
} -result {
      0
      1
      2
      3
      4
}


test run-17 {Ensure safe predefined aliases work properly and are not removed when interp reset} \
-setup {
  set tpl {
!* variableSubst true
! set x [clock scan 2018-12-29 -format %Y-%m-%d]
$x
}
  set script [compile $tpl]
} -body {
  for {set i 0} {$i < 3} {incr i} {
    lappend output [string trim [run $script]]
  }
  return $output
} -result {1546041600 1546041600 1546041600}


test run-18 {Ensure can process multiple subtemplates without corruption} \
-setup {
  set tpl {
!* commandSubst true variableSubst true
!  set someNum 78
!  set vars [dict create tpl2 $tpl2 num 25]
[list {*}[ornament $tpl2 $vars] $someNum]
}
set tpl2 {
!* commandSubst true variableSubst true
! set someNum $num
! if {$num > 0} {
!   set vars [dict create tpl2 $tpl2 num [expr {$num-1}]]
    [ornament $tpl2 $vars]
! }
$someNum
}
  set script [compile $tpl]
  set cmds [dict create ornament [list ::TestHelpers::CmdOrnament]]
  set vars [dict create tpl2 $tpl2]
} -body {
  run $script $cmds $vars
} -result {
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 78
}

cleanupTests
