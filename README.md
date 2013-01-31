RuneItAll
=========
[WoWAce](http://www.wowace.com/addons/runeitall/) | [WoWInterface](http://www.wowinterface.com/downloads/info10157-Rune-It-All.html)

Customizable Death Knight rune interface for World of Warcraft

Description
-----------

Rune-It-All adds more features and functionality to the default rune frame while still using the Blizzard code.
The goal of Rune-It-All is to be simple yet rich. I hope Rune-It-All provides you with the features you are looking for while maintaining a simple, unobtrusive, and painless feel.

Rune-It-All does the following:

* Allows you to scale the size of the runes
* Allows you to change the transparency in and out of combat
* Allows you to unlock and lock the runes so that you can move them around
* Layouts to choose from: Vertical, Horizontal, Up Curved, Down Curved, Vertical Block, Horizontal Block
* Art to choose from: Default, DKI, Beta, Letter, Beta-Enhanced, Orb, Japanese, Runica
* Allows you to move the runes individually
* Has custom cooldown text (includes several options along with it)
* Has option to show runes (when OOC - and useful when OOC alpha is less than 1) when you use a rune (e.g. Death and Decay OOC)
* Allows you to increase or decrease the spacing between runes ("padding") Note: only works for Vertical and Horizontal layouts
* Allows you to configure how the rune bar acts when you enter a Vehicle

Notes
-----

Options can be accessed by typing `/ria`, `/runeitall`, or `/rune-it-all`<br />
If you are using Pitbull:<br />
Config. > Modules > Hide Blizzard frames > UNCHECK "Rune bar"<br />
Config. > Modules > Runes > UNCHECK "Enable"

If you are using Shadowed UF:<br />
/suf > General > Hide Blizzard Frames > UNCHECK "Hide Rune bar"<br />
/suf > Units > Player > Bars > UNCHECK "Enable Rune bar"<br />
/console reloadui

If you are using X-Perl:<br />
/xperl > Player > UNCHECK "Show Runes"<br />

EDIT line 68-69 in XPerl_Player.lua file to this:

`--XPerl_Player_InitDK(self)`<br />
`--XPerl_Player_SetupDK(self)`

Credits
-------

Thank you to these people who gave me knowledge and insight to keep me going on the right track:
_Chloe, slakah, zeksie, KarlKFI, Akryn, arnath2, kollektiv, Parnic, Yivry
