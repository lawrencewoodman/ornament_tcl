# Helper functions for the tests

namespace eval TestHelpers {
}

proc TestHelpers::CmdGetVar {vars int args} {
  if {[dict exists $vars {*}$args]} {
    return [dict get $vars {*}$args]
  }
  return ""
}

proc TestHelpers::CmdPlugin {int script} {
  return [$int eval $script]
}

