ornament
========

[![Build Status](https://travis-ci.org/lawrencewoodman/ornament_tcl.svg?branch=master)](https://travis-ci.org/lawrencewoodman/ornament_tcl)

A Tcl template module

This module provides a simple way to define, parse and compile a template to produce a script which can then be run using a safe interpreter.  The idea came from the [Templates and subst](https://wiki.tcl.tk/18455) page of the [Tclers Wiki](https://wiki.tcl.tk).

Requirements
------------
*  Tcl 8.6+

Module Usage
------------
The `compile` command takes a template and outputs a script which can then be used with the `run` command which will evaluate it using a safe interpreter to create its final output.

```tcl
package require ornament
namespace import ornament::*

# int is the safe interpreter that is running the script
proc CmdGreet {greeting int name} {
  return "$greeting $name"
}

# This is the template
set tpl {
This is some normal text
!# This is a comment and is ignored by `compile`
!# The following line will be executed as it begins with a `!` followed by a space
! for {set i 0} {$i < 5} {incr i} {
    Number: $i
! }
!# You can also use `!!` followed by a space instead of a `!`
!! set flow 152
flow: $flow
!# Creates a comment that will be ignored by `compile`
 ! Because the ! wasn't in the first column of the line, this line isn't executed
!# Below some variables are used that have been passed to the template:
Name: $name
Age: $age
!# Below a command is called that has been passed to the template:
I want to say: [greet $name]

!# You can change the command character to anyone of {! % @ ~}
!* commandChar %
% set nextAge [expr {$age + 2}]
nextAge: $nextAge
%* commandChar !

!# You can change whether variable substitution happens
!* variableSubst false
look at this: $nextAge
!* variableSubst true
and now: $nextAge

!# You can change whether command substitution happens
!* commandSubst false
look at this: [expr {5 + 6}]
!* commandSubst true
and now: [expr {5 + 6}]

!# You can change whether backslash substitution happens
!* backslashSubst false
look at this:\n
!* backslashSubst true
and now:\n
}

set expected {
This is some normal text
    Number: 0
    Number: 1
    Number: 2
    Number: 3
    Number: 4
flow: 152
 ! Because the ! wasn't in the first column of the line, this line isn't executed
Name: Brodie
Age: 37
I want to say: hello Brodie

nextAge: 39

look at this: $nextAge
and now: 39

look at this: [expr {5 + 6}]
and now: 11

look at this:\n
and now:

}

# You can pass commands to the template
set cmds [dict create greet [list CmdGreet "hello"]]

# You can pass variables to the template
set vars [dict create name Brodie age 37]

set script [compile $tpl]
set output [run $script $cmds $vars]

puts "\noutput\n======\n$output"

if {$output ne $expected} {
  puts stderr "\nError\n=====\n** Output isn't as expected **"
}
```


Installation
------------
To install the module you can use the [installmodule.tcl](https://github.com/LawrenceWoodman/installmodule_tcl) script or if you want to manually copy the file `configurator-*.tm` to a specific location that Tcl expects to find modules.  This would typically be something like:

    /usr/share/tcltk/tcl8.5/tcl8/

To find out what directories are searched for modules, start `tclsh` and enter:

    foreach dir [split [::tcl::tm::path list]] {puts $dir}

or from the command line:

    $ echo "foreach dir [split [::tcl::tm::path list]] {puts \$dir}" | tclsh

Testing
-------
There is a testsuite in `tests/`.  To run it:

    $ tclsh tests/ornament.test.tcl

Contributing
------------
I would love contributions to improve this project.  To do so easily I ask the following:

  * Please put your changes in a separate branch to ease integration.
  * For new code please add tests to prove that it works.
  * Update [CHANGELOG.md](https://github.com/lawrencewoodman/ornament_tcl/blob/master/CHANGELOG.md).
  * Make a pull request to the [repo](https://github.com/lawrencewoodman/ornament_tcl) on github.

If you find a bug, please report it at the project's [issues tracker](https://github.com/lawrencewoodman/ornament_tcl/issues) also on github.


Licence
-------
Copyright (C) 2018 Lawrence Woodman <lwoodman@vlifesystems.com>

This software is licensed under an MIT Licence.  Please see the file, [LICENSE.md](https://github.com/lawrencewoodman/ornament_tcl/blob/master/LICENSE.md), for details.
