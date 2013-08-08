![](http://www.haxeflixel.com/sites/haxeflixel.com/files/flixel-ui.png)
=
###Related:    [flixel](https://github.com/HaxeFlixel/flixel) | [flixel-addons](https://github.com/HaxeFlixel/flixel-addons) | [flixel-demos](https://github.com/HaxeFlixel/flixel-demos) | [flixel-tools](https://github.com/HaxeFlixel/flixel-tools)
______________________________________________________

FlxUI - GUI library for Haxe+Flixel

This project depends on the Haxe+Flixel project. A [test project](https://github.com/HaxeFlixel/flixel-demos/tree/master/User%20Interface/RPG%20Interface) is available in [flixel-demos](https://github.com/HaxeFlixel/flixel-demos).

Please note the test project in flixel-demos requires the localization library **[fireTongue](https://github.com/larsiusprime/firetongue)**, which can be installed thus:

    haxelib git firetongue https://github.com/larsiusprime/firetongue

(at least until I get around to submitting it to haxelibs officially)

#Documentation
(Work in progress)

##Getting Started

###Install flixel-ui:

latest dev version:

    haxelib git https://github.com/haxeflixel/flixel-ui

when we finally upload it to haxelib:

    haxelib install flixel-ui

###Quick project setup

1. In your openfl assets folder, create an "xml" directory
2. Create an xml layout file for each state you want a UI for
3. Make your UI-driven states extend flixel.addons.ui.FlxStateX
4. In the create() function, set:

````
_xml_id = "state_battle"; //looks for "state_battle.xml"
````
Provided you've set up your XML layout correctly, flixel-ui will fetch that xml file and auto-generate a _ui:FlxUI member variable.

_**NOTE:** The system is not currently set up to allow for easily loading UI widgets outside of this context, but I plan on adding that soon._

###XML layout basics
...

##List of Widgets
* 9-slice sprites/chrome (Flx9SliceSprite)
* Buttons, vanilla (FlxButtonPlusX)
* Buttons, toggle (FlxButtonToggle)
* Check boxes, (FlxCheckBox)
* Text, vanilla (FlxTextX)
* Text, input (FlxInputText)
* Radio button groups, (FlxRadioGroup)
* Images, vanilla (FlxSpriteX)
* Tabbed menus (FlxTabMenu)

...

##Dynamic position & size
###Anchor tags
###Size tags
###Alignment
...

##Localization (FireTongue)
...