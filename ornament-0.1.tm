# A template module
#
# Copyright (C) 2018 Lawrence Woodman <lwoodman@vlifesystems.com>
#
# Licensed under an MIT licence.  Please see LICENCE.md for details.
#

package require Tcl 8.6

namespace eval ornament {
  namespace export {[a-z]*}
  namespace ensemble create
}

# Inspired by: http://wiki.tcl.tk/18455
# Compiles the template into a script
proc ornament::compile {tpl {var _OUT}} {
  set cfg [dict create commandChar "!"]
  set script ""
  set lines [split $tpl "\n"]
  set lineNum 1
  set lastLineNum [expr {[llength $lines]}]

  foreach line $lines {
    set commandChar [dict get $cfg commandChar]
    # A template command consists of $commandChar followed by another character
    # or is the only character on a line
    if {[string index $line 0] eq $commandChar} {
      switch -regexp [string range $line 1 end] [list \
        {^#.*$}  - \
        "^$commandChar\\s*$" - \
        {^\s*$}  {} \
        "^$commandChar.*$"  - \
        {^ .*$}  {append script "[string range $line 2 end]\n"} \
        {^\*.*$} {set cfg [ProcessCfg $cfg [string range $line 2 end]]} \
        default {
          return -code error \
            "unrecognized template command '[string range $line 0 1]' at start of line number: $lineNum"
        } \
      ]
    } elseif {$lineNum != $lastLineNum} {
      append script "append $var \"\[" [list subst $line] "]\n\"\n"
    } else {
      # This stops you from getting an extra newline at the end
      append script "append $var \"\[" [list subst $line] "]\"\n"
    }
    incr lineNum
  }
  return $script
}


# Runs the compiled template script with the supplied cmds and vars in dicts
proc ornament::run {script {cmds {}} {vars {}}} {
  set safeInterp [interp create -safe]
  try {
    $safeInterp eval {unset {*}[info vars]}
    dict for {templateCmdName cmdInvokation} $cmds {
      $safeInterp alias $templateCmdName {*}$cmdInvokation $safeInterp
    }
    dict for {varName value} $vars {
      $safeInterp eval "set $varName $value"
    }
    return [$safeInterp eval $script]
  } on error {result options} {
    return -code error $result
  } finally {
    interp delete $safeInterp
  }
}

proc ornament::ProcessCfg {cfg newCfgString} {
  if {[llength $newCfgString] % 2 != 0} {
    return -code error "invalid config string"
  }
  dict for {f v} $newCfgString {
    switch $f {
      commandChar {
        set validCommandChars {! % @ ~}
        if {[lsearch $validCommandChars $v] == -1} {
          return -code error -level 2 "invalid config commandChar: $v"
        }
      }
      default {
        return -code error -level 2 "invalid config field: $f"
      }
    }
    dict set cfg $f $v
  }
  return $cfg
}
