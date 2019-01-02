ornament
========

[![Build Status](https://travis-ci.org/lawrencewoodman/ornament_tcl.svg?branch=master)](https://travis-ci.org/lawrencewoodman/ornament_tcl)

A Tcl template module

This module provides a simple way to define, parse and compile a template to produce a script which can then be run using a safe interpreter.  The idea came from the [Templates and subst](https://wiki.tcl.tk/18455) page of the [Tclers Wiki](https://wiki.tcl.tk).

Please see [Introducing Ornament a Tcl Template Module](https://techtinkering.com/articles/introducing-ornament-a-tcl-template-module/) for details on how to use it.

Requirements
------------
*  Tcl 8.6+

Installation
------------
To install the module you can use the [installmodule.tcl](https://github.com/LawrenceWoodman/installmodule_tcl) script or if you want to manually copy the file `ornament-*.tm` to a specific location that Tcl expects to find modules.

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
Copyright (C) 2018-2019 Lawrence Woodman <lwoodman@vlifesystems.com>

This software is licensed under an MIT Licence.  Please see the file, [LICENCE.md](https://github.com/lawrencewoodman/ornament_tcl/blob/master/LICENCE.md), for details.
