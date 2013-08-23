![](http://www.haxeflixel.com/sites/haxeflixel.com/files/flixel-ui.png)
=
###Related:    [flixel](https://github.com/HaxeFlixel/flixel) | [flixel-addons](https://github.com/HaxeFlixel/flixel-addons) | [flixel-demos](https://github.com/HaxeFlixel/flixel-demos) | [flixel-tools](https://github.com/HaxeFlixel/flixel-tools)
______________________________________________________

FlxUI - GUI library for Haxe+Flixel

This project depends on the Haxe+Flixel project. 

#Documentation
(Work in progress)

##Demo Project!
 A [test project](https://github.com/HaxeFlixel/flixel-demos/tree/master/User%20Interface/RPG%20Interface) is available in [flixel-demos](http://github.com/HaxeFlixel/flixel-demos). You should really, really, check it out. It has a lot of inline documentation in the xml files and showcases some complex and subtle features.

Please note the test project in flixel-demos requires the localization library **[fireTongue](https://github.com/larsiusprime/firetongue)**, which can be installed thus:

    haxelib git firetongue https://github.com/larsiusprime/firetongue

(at least until I get around to submitting it to haxelibs officially)

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

FlxUI is basically a giant glorified FlxGroup, so using this method will set you up with one UI container and all of your UI widgets inside it.

_**NOTE:** The system is not currently set up to allow for easily loading UI widgets outside of this context, but I plan on adding that soon._

###Graphic assets for Widgets

Flixel-UI doesn't ship with any default assets yet, I'm working on that. If you want to use the default skins, make sure you get them from the [test project](https://github.com/HaxeFlixel/flixel-demos/tree/master/User%20Interface/RPG%20Interface) in [flixel-demos](https://github.com/HaxeFlixel/flixel-demos).

Install Flixel-demos:
````
haxelib git https://github.com/haxeflixel/flixel-demos
````

Then inside flixel-demos navigate to the _User Interface / RPG Interface /_ directory. Copy the contents of the "assets" folder into your own project's "assets" directory (you probably won't need the "locales" folder, FYI).

The default skins won't show up automatically - you'll have to feed them into your xml specifications like any other asset. You can follow the example in the RPG Interface demo, or keep reading here for basic documentation.

##XML layout basics
Everything in flixel-ui is done with xml layout files. Here's a very simple example:

````
<?xml version="1.0" encoding="utf-8" ?>
<data>	
	<sprite src="ui/title_back" x="0" y="0"/>
</data>
````

That will create a FlxUI object whose sole child is a single sprite. The "src" parameter specifies the path to the image - FlxUI will use this to internally load the object via OpenFL thus:

````
Assets.getBitmapData("assets/gfx/ui/title_back.png")
````

As you can see, all image source entries assume two things:
* The format is PNG (might add JPG/GIF/etc support later)
* The specified directory is inside "assets/gfx/"

###Types of tags
There are several basic types of xml tags in a Flixel-UI layout file.

--

####1. Widget
Any of the Flixel-UI widgets, such as \<sprite\>, \<button\>, \<checkbox\>, etc. We'll go into more detail on each one below, but all widget tags have a few things in common:

*Widget Attributes:*
* **id** - string, optional, should be unique. Lets you reference this widget throughout the layout, and also lets you fetch it by name with FlxUI's getAsset("some_id") function.
* **x/y** - integer, specifies position. If no anchor tag exists as a child node, the position is absolute. If an anchor tag exists, the position is relative to the anchor.
* **use_def** - string, optional, references a \<definition\> tag by id to use for this widget.
* **group** - string, optional, references a \<group\> tag by id. Will make this widget the child of that group instead of the FlxUI itself.

--

*Widget child nodes:*
* **\<locale id="xx-YY">** - optional, lets you specify a locale (like "en-US" or "nb-NO") for [fireTongue](https://github.com/larsiusprime/firetongue) integration. This lets you specify changes based on the current locale:
Example:

````
<button center_x="true" x="0" y="505" id="battle" use_def="text_button" group="top" label="$TITLE_BATTLES">
	<param type="string" value="battle"/>
	<locale id="nb-NO">
		<change width="96"/>
		<!--if norwegian, do 96 pixels wide instead of the default-->
	</locale>			
</button>
````
* **\<anchor\>** - optional, lets you position this widget relative to another object's position.

* **size tags** - optional, lets you dynamically size a widget according to some formula.

More info on Anchor and Size tags appears towards the bottom in the "Dynamic Position & Size" section.

--

####2. Definition
This lets you offload a lot of re-usable details into a separate tag with a unique id, and then call them in to another tag using the use_def="definition_id" attribute.

####3. Group
Creates a FlxGroup that you can assign widgets to. Note that you do NOT add things to a group by making widget tags as child xml nodes to the \<group\> tag, but by setting the "group" attribute in a widget tag to the group's id.

####4. Align
Dynamically aligns, centers, and/or spaces objects relative to one another.

####5. Layout
Creates a child FlxUI object inside your master FlxUI, and childs all the widgets inside to it. This is especially useful if you want to create multiple layouts for, say, different devices and screen sizes. Combined with **failure** tags, this will let you automatically calculate the best layout depending on screen size.

####6. Failure
Specifies "failure" conditions for a certain layout, so FlxUI can determine which of multiple layouts to choose from in the event that one works better than another. Useful for simultaneously targeting, say, PC's with variable resolutions and mobile devices.

####7. Mode
Specifies UI "modes" that you can switch between. Basically just a glorified way of quickly hiding and showing specific assets. For instance, in Defender's Quest we had four states for our save slots - blank, play, New Game+ eligible, and New Game+ started. This would determine what buttons were visible ("New Game", "Play", "Play+", "Import", "Export"). 

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

##Dynamic position & size

###1. Anchor Tags

Here's an example of a health bar from an RPG:
````
<9slicesprite id="health_bar" x="10" y="5" width="134" height="16" use_def="health">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
</9slicesprite>
````

There is presumably another sprite defined somewhere called "portrait" and we want our health bar to show up relative to wherever that is. In this case, the object's own x and y positions are now relative to the anchor - they will be added on *after* the object has been flushed to the anchor position.

The anchor's x and y specify a specific point, and x-flush and y-flush specify which corner of the object should be aligned to that point. 

Acceptable values for x/y:
* "left", "right", "top", or "bottom": edges of the flixel canvas.
* object properties (ie, "some_id.some_property"):
 * "left", "right", "top", "bottom": edges of that object
 * "center": center of that object (axis inferred from x or y attribute)

Acceptable values for x-flush/y-flush:
* "left"
* "right"
* "top"
* "bottom"
* "center"

--
###2. Size Tags

Let's add a size tag to our health bar:
````
<9slicesprite id="health_bar" x="10" y="5" width="134" height="16" use_def="health" group="mcguffin">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
	<exact_size width="stretch:portrait.right+10,right-10"/>
</9slicesprite>
````

There are three size tags: **\<min_size>**, **\<max_size>**, and **\<exact_size>**

This lets you either specify dynamic lower/upper bounds for an object's size, or force it to be an exact size. This lets you create a UI that can work in multiple resolutions, or just avoid having to do manual pixel calculations yourself. 

Size tags take only two attributes, **width** and **height**. If one is not specified, it is ignored.

There are several ways to formulate a width/height attribute:

* **number** (ie, width="100")
* **stretch** (ie, width="stretch:some_value,another_value")
* **reference** (ie, width="some_id.some_value")

A **stretch** formula will tell FlxUI to calculate the difference between two values separated by a comma. These values are formatted and calculated just like a **reference** formula. The axis is inferred from whether it's width or height. 

So, if you have a scoreboard at the top of the screen, and you want the playfield to stretch from the bottom of the scoreboard to the bottom of the screen:

````
<exact_size height="stretch:scoreboard.bottom,bottom"/>
````

Acceptable property values for reference formula, used alone or in a stretch:
* **naked reference** (ie, "some_id") - returns inferred x or y position of that thing.
* **property reference** (ie, "some_id.some_value") - returns a thing's property
 * "left", "right", "top", "bottom", "width", "height"
 * _NOTE: "center" not yet implemented for size formulas!_
* **arithmetic formula** (ie, "some_id.some_value+10") - do some math
 * You can tack on **one** operator and **one** _numeric_ operand to any of the above.
 * Legal operators = (+, -, *, \, ^)
 * Don't try to get too crazy here. If you need to do some super duper math, just add some code in your FlxState, call getAsset("some_id") to grab your assets, and do the craziness yourself.

--
###3. Alignment Tags

...

##Localization (FireTongue)
...