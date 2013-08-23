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

##FlxUI public functions

most commonly used public functions:

````
//Initiate from XML Fast object:
//(This is handled automatically in the recommended setup)
load(data:Fast):Void

//Get some widget:
getAsset(key:String,recursive:Bool=true):FlxBasic

//Get some group:
getGroup(key:String,recursive:Bool=true):FlxGroupX

//Get a text object:
getFlxText(key:String,recursive:Bool=true):FlxText

//Get a mode definition (xml list of things to show/hide):
getMode(Key:String,recursive:Bool=true):Fast

//Get a widget definition:
getDefinition(key:String,recursive:Bool=true):Fast
````

less commonly used public functions:
````
//These implement the IEventGetter interface for lightweight events
getEvent(id:String, sender:Dynamic, data:Dynamic):Void
getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic
//Both empty - to be defined by the user in extended classes

//Get, Remove, and Replace assets:
removeAsset(key:String,destroy:Bool=true):FlxBasic
replaceAsset(key:String,replace:FlxBasic,center_x:Bool=true,center_y:Bool=true,destroy_old:Bool=true):FlxBasic

//Set a mode for the UI:
//  mode_id is the mode you want
//  target_id is the FlxUI object to target -
//            "" for this FlxUI, something else for a child
setMode(mode_id:String,target_id:String=""):Void
````

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

**Widget**, **\<definition>**, **\<group>**, **\<align>**, **\<layout>**, **\<failure>**, and **\<mode>**.

Let's go over these one by one.

--

####1. Widget
This is any of the many Flixel-UI widgets, such as **\<sprite\>**, **\<button\>**, **\<checkbox\>**, etc. We'll go into more detail on each one below, but all widget tags have a few things in common:

*Attributes:*
* **id** - string, optional, should be unique. Lets you reference this widget throughout the layout, and also lets you fetch it by name with FlxUI's getAsset("some_id") function.
* **x/y** - integer, specifies position. If no anchor tag exists as a child node, the position is absolute. If an anchor tag exists, the position is relative to the anchor.
* **use_def** - string, optional, references a \<definition\> tag by id to use for this widget.
* **group** - string, optional, references a \<group\> tag by id. Will make this widget the child of that group instead of the FlxUI itself.

--

*Child nodes:*
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

####2.\<definition>
This lets you offload a lot of re-usable details into a separate tag with a unique id, and then call them in to another tag using the use_def="definition_id" attribute. A definition tag is exactly like a regular widget tag, except the tag name is "definition."

If you provide details in the widget tag and also use a definition, it will override *some* of the information in the definition... I still need to stabilize how this works. Look at the RPG Interface demo for more details.

####3. \<group>
Creates a FlxGroup that you can assign widgets to. Note that you do NOT add things to a group by making widget tags as child xml nodes to the \<group\> tag, but by setting the "group" attribute in a widget tag to the group's id.

Groups are stacked in the order you define them, with those at the top of the file created first, and thus stacked "underneath" those that come later. 

A group tag takes one attribute - id. Just define your groups somewhere in the order you want them to stack, then add widgets to them by setting the group attribute to the ids you want.

####4. \<align>
Dynamically aligns, centers, and/or spaces objects relative to one another. 
This is complex enough to deserve its own section below.

####5. \<layout>
Creates a child FlxUI object inside your master FlxUI, and childs all the widgets inside to it. This is especially useful if you want to create multiple layouts for, say, different devices and screen sizes. Combined with **failure** tags, this will let you automatically calculate the best layout depending on screen size.

A layout has only one attribute, id, and then its child nodes. Think of a <layout> as its own sub-section of your xml file. It can have its own versions of anything you can put in the regular file since it is a full-fledged FlxUI - ie, definitions, groups, widgets, modes, presumably even other layout tags (haven't tested this). 

Note that in a layout, scope comes into play when referencing ids. Definitions and object references will first look in the scope of the layout (ie, that FlxUI object), and if none is found, will try to find them in the parent FlxUI. 

####6. \<failure>
Specifies "failure" conditions for a certain layout, so FlxUI can determine which of multiple layouts to choose from in the event that one works better than another. Useful for simultaneously targeting, say, PC's with variable resolutions and mobile devices.

Here's an example:
````
<failure target ="wave_bar" property="height" compare=">" value="15%"/>		
````

"Fail if wave_bar.height is greater than 15% of total flixel canvas height."

Legal values for attributes:

* value - restricted to a percentage (inferring a % of total width/height) or an absolute number. 
* property - **"width"** and **"height"**
* compare - **< , > , <= , >= , = , ==** (= and == are synonymous in this context)

After your FlxUI has loaded, you can fetch your individual layouts using getAsset(), and then check these public properties, which give you the result of the failure checks:

* **failed:Bool** - has this FlxUI "failed" according to the specified rules?
* **failed_by:Float** - if so, by how much?

Sometimes multiple layouts have "failed" according to your rules, and you want to pick the one that failed by the least. If the failure condition was "some_thing's width is greater than 100 pixels", than if some_thing.width = 176, failed_by is 76.

To *respond* to failure conditions, you need to write your own code. In the RPG Interface demo, there are two battle layouts, one that is more appropriate for 4:3 resolutions, and another that works better in 16:9. The custom FlxStateX for that state will check failure conditions on load, and set the mode depending on which layout works best. Speaking of modes...

####7. \<mode>
Specifies UI "modes" that you can switch between. Basically just a glorified way of quickly hiding and showing specific assets. For instance, in Defender's Quest we had four states for our save slots - empty, play, new_game+ (New Game+ eligible), and play+ (New Game+ started). This would determine what buttons were visible ("New Game", "Play", "Play+", "Import", "Export"). 

The "empty" and "play" modes might look like this:

````
<mode id="empty">
	<show id="new_game"/>
	<show id="import"/>
			
	<hide id="space_icon"/>
	<hide id="play_big"/>
	<hide id="play_small"/>
	<hide id="play+"/>
	<hide id="export"/>
	<hide id="delete"/>
	<hide id="name"/>
	<hide id="time"/>
	<hide id="date"/>
	<hide id="icon"/>
	<hide id="new_game+"/>
</mode>
		
<mode id="play">
	<show id="play_big"/>
	<show id="export"/>
	<show id="delete"/>
	<show id="name"/>
	<show id="time"/>
	<show id="date"/>
	<show id="icon"/>			
			
	<hide id="play_small"/>
	<hide id="play+"/>
	<hide id="import"/>
	<hide id="new_game"/>
	<hide id="new_game+"/>
</mode>
````

The only tags available in a **\<mode>** element are <hide> and <show>, which each only take id as an attribute. They just toggle the "visible" property on and off. 

##List of Widgets

* **Image, vanilla** (FlxSpriteX) - \<sprite>
* **9-slice sprite/chrome** (Flx9SliceSprite) - \<9slicesprite> or \<chrome>
* **Button, vanilla** (FlxButtonX) - \<button>
* **Button, toggle** (FlxButtonX) - \<button_toggle>
* **Check box** (FlxCheckBox) - \<checkbox>
* **Text, vanilla** (FlxTextX) - \<text>
* **Text, input** (FlxInputText) - \<text>
* **Radio button group** (FlxRadioGroup) - \<radio_group>
* **Tabbed menu** (FlxTabMenu) - \<tab_menu>

Lets go over these one by one.

###1. Image (FlxSpriteX)

**\<sprite>**

Just a regular sprite, with a fixed size.

Attributes:
* x/y
* src (path to source, no extension, appended to "assets/gfx/")
* use_def (definition id)
* group (group id)

###2. 9-slice sprite/chrome (Flx9SliceSprite)

**\<9slicesprite> or \<chrome>**

A 9-slice sprite can be scaled in a more pleasing way than just stretching it directly. It divides the object up into a user-defined grid of 9 cells, (4 corners, 4 edges, 1 interior), and then repositions and scales those individually to construct a resized image. Works best for stuff like chrome and buttons.

Attributes:
* x/y, use_def, group
* src
* width/height
* slice9 - string, two points that define the slice9 grid, format "x1,y1,x2,y2". For example, "6,6,12,12" works well for the 12x12 chrome images in the demo project.
* tile - bool, optional (assumes false if not exist). If true, uses tiling rather than scaling for stretching 9-slice cells.

###3. Button (FlxButtonX)
**\<button>**

Just a regular clicky button, optionally with a label.

Attributes:
* x/y, use_def, group
* width/height - optional, only needed if you're using a 9-slice sprite as source
* text_x/text_y - label offsets
* label - text to show

Child tags:
* \<text> - just like a regular \<text> node
* \<param> - parameter to pass to the callback/event system (details below)
* \<graphic> - graphic source (details below)

#####3.1 Button Parameters

A **\<param>** tag takes two attributes: **type** and **value**. 

**type**: "string", "int", "float", and "color" or "hex" for e.g: "0xFF00FF"

**value**: the value, as a string. The type attribute will ensure it typecasts correctly.

````
<button id="new_game" use_def="big_button_gold" x="594" y="11" group="top" label="New Game">
	<param type="string" value="new"/>
</button>
````

You can add as many <param> tags as you want. When you click this button, it will by default call FlxUI's internal button callback:

````
_onClickButton(params:Array<Dynamic>=null):Void
````

This, in turn, will call getEvent() on whatever IEventGetter "owns" this FlxUI object. In the default setup, this is your FlxStateX. So extend this function in your FlxStateX:

````
getEvent(id:String,sender:Dynamic,data:Dynamic):Void
````
The sender will always be this FlxUI instance. On a FlxButton click, the other parameters will be:

* **event id**: "click_button"
* **data**: an **Array\<Dynamic>** containing all the parameters you've defined.

Some other interactive widgets can take parameters, and they work in basically the same way.

#####3.2 Button Graphics

Graphics for buttons can be kinda complex. You can put in multiple graphic tags, one for each button state you want to specify, or just one with the id "all" that combines all the states into one vertically stacked image. 

Static, individual frames:
````
<definition id="button_blue" width="96" height="32">
	<graphic id="up" image="ui/buttons/static_button_blue_up"/>
	<graphic id="over" image="ui/buttons/static_button_blue_over"/>
	<graphic id="down" image="ui/buttons/static_button_blue_down"/>
</definition>
````

9-slice scaling, individual frames:
````
<definition id="button_blue" width="96" height="32">
	<graphic id="up" image="ui/buttons/9slice_button_blue_up" slice9="6,6,12,12"/>
	<graphic id="over" image="ui/buttons/9slice_button_blue_over slice9="6,6,12,12""/>
	<graphic id="down" image="ui/buttons/9slice_button_blue_down slice9="6,6,12,12""/>
</definition>
````

9-slice scaling, all-in-one frame:
````
<definition id="button_blue" width="96" height="32">
	<graphic id="all" image="ui/buttons/button_blue_all" slice9="6,6,12,12"/>
<definition>
````

I'm not 100% sure what will happen if you do individual frames and omit one, but I think I set it up to copy one of the other ones in some kind of "smart" way. It's best to be explicit about what you want rather than have the system guess.




###4. Button, Toggle (FlxButtonX)
**\<button_toggle>**

###5. Check box (FlxCheckBox)
**\<checkbox>**

###6. Text (FlxTextX)
**\<text>**

###7. Text, input (FlxInputText)
**\<text>**

###8. Radio button group (FlxRadioGroup)
**\<radio_group>**

###9. Tabbed menu (FlxTabMenu)
**\<tab_menu>**


##Dynamic position & size

###1. Anchor Tags

Here's an example of a health bar from an RPG:
````
<9slicesprite id="health_bar" x="10" y="5" width="134" height="16" use_def="health">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
</9slicesprite>
````

There is presumably another sprite defined somewhere called "portrait" and we want our health bar to show up relative to wherever that is. 

The anchor's x and y specify a specific point, and x-flush and y-flush specify which corner of the object should be aligned to that point. The main object's x / y will be added on as offsets after the object is flushed to the anchor.

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

**Note to non-native speakers of English:** "flush" is a carpentry term, so if the left side of one object is parallel to and touching another object's side with no air between them, the objects are "flush." This has nothing to do with toilets :)

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