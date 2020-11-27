---------------------------------------------------------------------
Automatic screen resolution switcher v201127
(c)2020, Anders Granlund
---------------------------------------------------------------------
These files are distributed under the GPL v2, or at your
option any later version. See LICENSE.TXT for details
---------------------------------------------------------------------

Allows you to start ST-Low resolution color games from:

* A mono desktop if you are using an ubeswitch
  (https://github.com/planeturban/ubeswitchmk6)

* A graphics card desktop if you have an ET4000 installed

* An overscan desktop if you have a LaceScan installed (experimental)

It is intended for fullscreen games & demos that are not using GEM.
The video mode switches automatically when specified applications
are launched and restores itself when you return to the desktop.

---------------------------------------------------------------------


---------------------------------------------------------------------
Usage:
---------------------------------------------------------------------
Put MODESW.PRG and MODESW.INF in the AUTO folder.

For ET4000 and Lacescan users it is important to have this program
run *before* the screen drivers.
(ET4000: At least before nvdi.prg, redirect.prg and slct_dev.prg)
(LaceScan: At least before lacescan.prg)

If you are not using any special graphics hardware then you can
put MODESW.PRG anywhere in the startup order.


---------------------------------------------------------------------
Specifying the effected programs
---------------------------------------------------------------------

Edit MODESW.INF to specify which files or folders that should
activate this program.

You can specify up to 256 rules, one per line.
Each line must start with 00, then a space, then the search string.
modesw will activates automatically for any program that matches
a rule in this file.

Some example rules:

Activate modesw for all programs launched from F:
00 F:\

Activate modesw for all programs launched from a GAMES directory
00 \GAMES\

Activate modesw on a program called MYGAME.PRG located anywhere
00 \MYGAME.PRG


