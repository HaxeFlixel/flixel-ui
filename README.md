![](https://raw.github.com/HaxeFlixel/haxeflixel.com/master/src/files/images/flixel-logos/flixel-ui.png)

[flixel](https://github.com/HaxeFlixel/flixel) | [addons](https://github.com/HaxeFlixel/flixel-addons) | [ui](https://github.com/HaxeFlixel/flixel-ui) | [demos](https://github.com/HaxeFlixel/flixel-demos) | [tools](https://github.com/HaxeFlixel/flixel-tools) | [templates](https://github.com/HaxeFlixel/flixel-templates) | [docs](https://github.com/HaxeFlixel/flixel-docs) | [haxeflixel.com](https://github.com/HaxeFlixel/haxeflixel.com)

[![CI](https://img.shields.io/github/workflow/status/HaxeFlixel/flixel-ui/CI.svg?logo=github)](https://github.com/HaxeFlixel/flixel-ui/actions?query=workflow%3ACI)
[![Haxelib Version](https://badgen.net/haxelib/v/flixel-ui)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib Downloads](https://badgen.net/haxelib/d/flixel-ui?color=blue)](https://lib.haxe.org/p/flixel-ui)
[![Haxelib License](https://badgen.net/haxelib/license/flixel-ui)](LICENSE.md)

----

# Getting Started

## Install flixel-ui:

get latest stable release from haxelib:

    haxelib install flixel-ui

get latest bleeding-edge dev version from github:

    haxelib git flixel-ui https://github.com/HaxeFlixel/flixel-ui
    
## Demo Project!
 A [test project](https://haxeflixel.com/demos/RPGInterface/) is available in [flixel-demos](http://github.com/HaxeFlixel/flixel-demos). You should really, really, check it out. It has a lot of inline documentation in the xml files and showcases some complex and subtle features.

Please note the test project in flixel-demos requires the localization library **[fireTongue](https://github.com/larsiusprime/firetongue)**, which can be installed thus:

    haxelib install firetongue

Or this for the latest dev version from github:

    haxelib git firetongue https://github.com/larsiusprime/firetongue

## Quick project setup

1. In your openfl assets folder, create an "xml" directory
2. Create an xml layout file for each state you want a UI for
3. Make your UI-driven states extend flixel.addons.ui.FlxUIState
4. In the create() function, set:

````
_xml_id = "state_battle"; //looks for "state_battle.xml"
````
Provided you've set up your XML layout correctly, flixel-ui will fetch that xml file and auto-generate a _ui:FlxUI member variable.

FlxUI is basically a giant glorified FlxGroup, so using this method will set you up with one UI container and all of your UI widgets inside it.

## Manually creating widgets

You can also create FlxUI widgets directly with Haxe code rather than using the XML setup. 

To see this in action, look at the [demo project](https://github.com/HaxeFlixel/flixel-demos/tree/master/UserInterface/RPGInterface), specifically [State_CodeTest](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/source/State_CodeTest.hx)  (in the compiled demo, just click "Code Test" to see it in action.)

You can compare this to [State_DefaultTest](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/source/State_DefaultTest.hx), which creates virtually the same UI output, but uses [this xml layout](https://github.com/HaxeFlixel/flixel-demos/blob/master/UserInterface/RPGInterface/assets/xml/state_default.xml) to achieve those results.

## Graphic assets for Widgets

### Default Assets

Flixel-UI has a default set of assets (see [FlxUIAssets](https://github.com/HaxeFlixel/flixel-ui/blob/master/flixel/addons/ui/FlxUIAssets.hx) and the [assets folder](https://github.com/HaxeFlixel/flixel-ui/tree/master/assets)) for basic skinning. If you provide incomplete data and/or definitions for your widgets, FlxUI will automatically attempt to fall back on the default assets. 

### Custom Assets

If you want to provide your own assets, you should put them in your project's "assets" folder, using the same structure you see in the [demo project](https://github.com/HaxeFlixel/flixel-demos/tree/master/UserInterface/RPGInterface).

----

# FlxUI public functions

Most commonly used public functions in class FlxUI:

```haxe
//Initiate from XML Fast object:
//(This is handled automatically in the recommended setup)
load(data:Fast):Void

//Get some widget:
getAsset(key:String,recursive:Bool=true):FlxBasic

//Get some group:
getGroup(key:String,recursive:Bool=true):FlxUIGroup

//Get a text object:
getFlxText(key:String,recursive:Bool=true):FlxText

//Get a mode definition (xml list of things to show/hide):
getMode(Key:String,recursive:Bool=true):Fast

//Get a widget definition:
getDefinition(key:String,recursive:Bool=true):Fast
```

Note that `recursive` refers to an upward recursion, not drilling down into layouts.  If you use a layout tag, you must `cast getAsset("mylayoutname")` and then call `getAsset()` on that to achieve downward recursion.

less commonly used public functions:
```haxe
//These implement the IEventGetter interface for lightweight events
getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
getRequest(name:String, sender:Dynamic, data:Dynamic):Dynamic
//Both are empty - to be defined by the user in extended classes

//Get, Remove, and Replace assets:
removeAsset(key:String,destroy:Bool=true):FlxBasic
replaceAsset(key:String,replace:FlxBasic,center_x:Bool=true,center_y:Bool=true,destroy_old:Bool=true):FlxBasic

//Set a mode for the UI:
//  mode_id is the mode you want
//  target_id is the FlxUI object to target -
//            "" for this FlxUI, something else for a child
setMode(mode_id:String,target_id:String=""):Void
```

----

# XML layout basics
Everything in flixel-ui is done with xml layout files. Here's a very simple example:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<data>	
	<sprite src="ui/title_back" x="0" y="0"/>
</data>
```

That will create a FlxUI object whose sole child is a single sprite. The "src" parameter specifies the path to the image - FlxUI will use this to internally load the object via OpenFL thus:

```haxe
Assets.getBitmapData("assets/gfx/ui/title_back.png")
```

As you can see, all image source entries assume two things:
* The format is PNG (might add JPG/GIF/etc support later)
* The specified directory is inside "assets/gfx/"
  * If you want a different directory, prepend it with "RAW:" like this:
  * ````"RAW:path/to/my/assets/image"```` will resolve as ````"path/to/my/assets/image.png"```` instead of ```"assets/gfx/path/to/my/assets/image.png"```

## Types of tags
There are several basic types of xml tags in a Flixel-UI layout file.

**Widget**, ```<definition>```, ```<include>```, ```<group>```, ```<align>```, ```<position>```, ```<layout>```, ```<failure>```, ```<mode>```, and ```<change>```.

Let's go over these one by one.

--

### 1. Widget
This is any of the many Flixel-UI widgets, such as ```<sprite>```, ```<button>```, ```<checkbox>```, etc. We'll go into more detail on each one below, but all widget tags have a few things in common:

*Attributes:*
* **name** - string, optional, should be unique. Lets you reference this widget throughout the layout, and also lets you fetch it by name with FlxUI's ```getAsset("some_id")``` function.
* **x** and **y** - integer, specifies position. If no anchor tag exists as a child node, the position is absolute. If an anchor tag exists, the position is relative to the anchor.*
* **use_def** - string, optional, references a ```<definition>``` tag by name to use for this widget.
* **group** - string, optional, references a ```<group>``` tag by name. Will make this widget the child of that group instead of the FlxUI itself.
* **visible** - boolean, optional, sets the visibility of the widget when the layout is loaded
* **active** - boolean, optional, controls whether a widget responds to any updates
* **round** - if x/y (and/or width/height for a sizeable object) are calculated from formulas/anchors, specifies how rounding works. Legal values are:
  * **down**: round down
  * **up**: round up
  * **round** or **true**: round up if decimal is >= 0.5, round down otherwise.
  * **false** (or attribute absent): do not round 
  
--

*Child nodes:*
* **\<anchor>** - optional, lets you position this widget relative to another object's position.*
* **\<param>** - optional, lets you specify parameters**
* **\<tooltip>** - optional, lets you specify a tooltip.***
* **size tags** - optional, lets you dynamically size a widget according to some formula.*
* **\<locale name="xx-YY">** - optional, lets you specify a locale (like "en-US" or "nb-NO") for [fireTongue](https://github.com/larsiusprime/firetongue) integration. This lets you specify changes based on the current locale:
Example:

```xml
<button center_x="true" x="0" y="505" name="battle" use_def="text_button" group="top" label="$TITLE_BATTLES">
	<param type="string" value="battle"/>
	<locale name="nb-NO">
		<change width="96"/>
		<!--if norwegian, do 96 pixels wide instead of the default-->
	</locale>			
</button>
```

\* More info on Anchor and Size tags appears towards the bottom in the "Dynamic Position & Size" section. 

\*\* More info on Parameters can be found under the Button entry in "List of Widgets". Only some widgets use parameters. 

\*\*\* More info on Tooltips appears towards the bottom in the "Tooltips" section.

--

### 2. ```<definition>```
This lets you offload a lot of re-usable details into a separate tag with a unique name, and then call them in to another tag using the use_def="definition_id" attribute. A definition tag is exactly like a regular widget tag, except the tag name is "definition."

If you provide details in the widget tag and also use a definition, it will override the information in the definition wherever they conflict. Look at the RPG Interface demo for more details.

**Example:**

A very common usage is font definitions for text widgets. Instead of typing this:

```xml
<text name="text1" x="50" y="50" text="Text 1" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<text name="text2" x="50" y="50" text="Text 2" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
```

You can do this instead:

```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<text name="text1" use_def="sans10" x="50" y="50" text="Text 1"/>
<text name="text2" use_def="sans10" x="50" y="50" text="Text 2"/>
```

Notice that in this case we've created a text definition that is always bold and white with a black outline. Let's say we want some italic text instead, but we don't want to create a new definition:

```xml
<text name="italic_text" use_def="sans10" style="italic" x="50" y="50" text="My Italic Text"/>
```

This is the same as writing

```xml
<text name="italic_text" x="50" y="50" text="My Italic Text" font="verdana" size="10" style="italic" color="0xffffff" outline="0x000000"/>
```

All of the values from the "sans10" definition are inherited, and then all the local settings of the "italic_text" tag are applied, overriding style="bold" with style="italic."

### 3. ```<default>```
A default tag is just like a definition, with a few exceptions:

1. You can only have one for each type of widget
2. The "name" property must be the name of the widget this default definition is for
3. You don't use these definitions with "use_def" tags

Whenever a widget is loaded, it will check to see if there is a default definition set for that type of widget. If so, it will automatically apply any properties from the default definition. This is done BEFORE and in ultimately IN ADDITION TO setting any properties of a user-supplied definition tag from "use_def".

Default tags can be accessed like any other tag via the ```FlxUI.getDefinition``` function, they are stored under the key "default:X" where X is the name of the widget they define. So "default:text" or "default:button", etc.

You define a default like this:

```xml
<default name="text" color="red"/>
```

Which will make all of your ```<text>``` objects red, unless local settings or a use_def overrides that.

### 4. ```<include>```
Include tags let you reference definitions stored in another xml file. This is a convenience feature to cut down on file bloat, and aid organization:

This invocation will include all the definitions found in "some_other_file.xml":

```xml
<include name="some_other_file"/>
```

*Only* definition and default tags will be included. It also adds a bit of scoping to your project - in the case that an included definition has the same name as one defined locally, the local definition will be used. Only in the case that FlxUI can't find your definition locally will it check for included ones. 

This recursion is only one level deep. If you put \<include> tags in your included file, they'll be ignored. 

### 5. ```<inject>```
Inject tags are a more direct solution than ```<include>``` tags. You just specify the name of the other xml file like you would with ```<include>```, but instead of including only the definitions, it literally replaces the ```<inject>``` tag with the contents of the other file, minus the ```<?xml>``` and ```<data>``` wrapper tags, of course. This step happens before any processing is done.

This invocation will inject all the contents found in "some_other_file.xml":

```xml
<inject name="some_other_file"/>
```

### 6. ```<group>```
Creates a FlxGroup (specifically a FlxUIGroup) that you can assign widgets to. Note that you do NOT add things to a group by making widget tags as child xml nodes to the \<group\> tag, but by setting the "group" attribute in a widget tag to the group's name.

Groups are stacked in the order you define them, with those at the top of the file created first, and thus stacked "underneath" those that come later. 

A group tag takes one attribute - name. Just define your groups somewhere in the order you want them to stack, then add widgets to them by setting the group attribute to the ids you want.

### 7. ```<align>```
Dynamically aligns, centers, and/or spaces objects relative to one another. 
This is complex enough to deserve its own section below, see "Alignment Tags" under "Dynamic Position & Size" later in the document.

### 8. ```<position>```
This allows you to re-position an existing asset later in the document. This is useful for complex relative positioning and other uses, and is complex enough to deserve its own section below, see "Position Tags" under "Dynamic Position & Size" later in the document.

### 9. ```<layout>```
Creates a child FlxUI object inside your master FlxUI, and childs all the widgets inside to it. This is especially useful if you want to create multiple layouts for, say, different devices and screen sizes. Combined with **failure** tags, this will let you automatically calculate the best layout depending on screen size.

A layout has only one attribute, name, and then its child nodes. Think of a \<layout> as its own sub-section of your xml file. It can have its own versions of anything you can put in the regular file since it is a full-fledged FlxUI - ie, definitions, groups, widgets, modes, presumably even other layout tags (haven't tested this). 

Note that in a layout, scope comes into play when referencing ids. Definitions and object references will first look in the scope of the layout (ie, that FlxUI object), and if none is found, will try to find them in the parent FlxUI. 

### 10. ```<failure>```
Specifies "failure" conditions for a certain layout, so FlxUI can determine which of multiple layouts to choose from in the event that one works better than another. Useful for simultaneously targeting, say, PC's with variable resolutions and mobile devices.

Here's an example:
```xml
<failure target ="wave_bar" property="height" compare=">" value="15%"/>		
```

"Fail if wave_bar.height is greater than 15% of total flixel canvas height."

Legal values for attributes:

* value - restricted to a percentage (inferring a % of total width/height) or an absolute number. 
* property - ```"width"``` and ```"height"```
* compare - ```<```,```>```,```<=```,```>=```,```=```,```==``` (```=``` and ```==``` are synonymous in this context)

After your FlxUI has loaded, you can fetch your individual layouts using getAsset(), and then check these public properties, which give you the result of the failure checks:

* **failed:Bool** - has this FlxUI "failed" according to the specified rules?
* **failed_by:Float** - if so, by how much?

Sometimes multiple layouts have "failed" according to your rules, and you want to pick the one that failed by the least. If the failure condition was "some_thing's width is greater than 100 pixels", than if some_thing.width = 176, failed_by is 76.

To *respond* to failure conditions, you need to write your own code. In the RPG Interface demo, there are two battle layouts, one that is more appropriate for 4:3 resolutions, and another that works better in 16:9. The custom FlxUIState for that state will check failure conditions on load, and set the mode depending on which layout works best. Speaking of modes...

### 11. ```<mode>```
Specifies UI "modes" that you can switch between. For instance, in Defender's Quest we had four states for our save slots - empty, play, new_game+ (New Game+ eligible), and play+ (New Game+ started). This would determine what buttons were visible ("New Game", "Play", "Play+", "Import", "Export").

The "empty" and "play" modes might look like this:

```xml
<mode name="empty">
	<show name="new_game"/>
	<show name="import"/>
			
	<hide name="space_icon"/>
	<hide name="play_big"/>
	<hide name="play_small"/>
	<hide name="play+"/>
	<hide name="export"/>
	<hide name="delete"/>
	<hide name="name"/>
	<hide name="time"/>
	<hide name="date"/>
	<hide name="icon"/>
	<hide name="new_game+"/>
</mode>
		
<mode name="play">
	<show name="play_big"/>
	<show name="export"/>
	<show name="delete"/>
	<show name="name"/>
	<show name="time"/>
	<show name="date"/>
	<show name="icon"/>			
			
	<hide name="play_small"/>
	<hide name="play+"/>
	<hide name="import"/>
	<hide name="new_game"/>
	<hide name="new_game+"/>
</mode>
```

Several tags are available in a **\<mode>** element. The most basic ones are ```<hide>``` and ```<show>```, which each only take name as an attribute. They just toggle the "visible" property on and off for the widget matching the "name" attribute. The full list is:

* **show** -- turns element visible
* **hide** -- turns element invisible
* **align** -- lets you align the placement of a list of widgets, see "Alignment Tags" later in the document.
* **change** -- lets you change the property of a widget, see "Change Tags" later in the document.
* **position** -- lets you re-position a widget, see "Position Tags" later in the document.

### 12. ```<change>```

The change tag lets you modify various properties of a widget after it has already been created. The widget matching the attribute "name" will be targeted. The following attributes may be used:

* **text** -- Change ```text``` property of the widget (FlxUIText or FlxUIInputText). Can also set "context" and "code" attributes for objects with text and/or labels. \*
* **label** -- Change ```label``` property of the widget (For buttons or anything else with a text label). Can also set "context" and "code" attributes.
* **width** -- Change width, same as using it in the original widget tag
* **height** -- Change height, same as using it in the original widget tag
* **<params>** (child node) -- Change ```params``` property to this list.\*\*

\* See "Button" entry under "List of Widgets" for more on "context" and "code" properties.

----

# List of Widgets

| Name | Class | Tag |
|------|-------|-----|
|**Image**, vanilla|FlxUISprite|```<sprite>```|
|**Image**, 9-slice/chrome|FlxUI9SliceSprite|```<9slicesprite>``` or ```<chrome>```|
|**Region**|FlxUIRegion|```<region>```|
|**Button**, vanilla|FlxUIButton|```<button>```|
|**Button**, toggle|FlxUIButton|```<button_toggle>```|
|**Check box**|FlxUICheckBox|```<checkbox>```|
|**Text**, vanilla|FlxUIText|```<text>```|
|**Text**, input|FlxUIInputText|```<input_text>```|
|**Radio button group**|FlxUIRadioGroup|```<radio_group>```|
|**Tabbed menu**|FlxUITabMenu|```<tab_menu>```|
|**Line**|FlxUISprite|```<line>```|
|**Numeric Stepper**|FlxUINumericStepper|```<numeric_stepper>```|
|**Dropdown/Pulldown Menu**|FlxUIDropDownMenu|```<dropdown_menu>```|
|**Tile Grid**|FlxUITileTest|```<tile_test>```|

Lets go over these one by one. Many of them share common attributes so I will only explain specific attributes in full detail the first time they appear.

## 1. Image (FlxUISprite) ```<sprite>```

Just a regular sprite. Can be scaled or fixed size.

Attributes:
* ```x``` and ```y```
* ```src``` (path to source, no extension, appended to "assets/gfx/". If not present will look for "color" instead)
* ```color``` (color of the rectangle. "color" attribute should be hexadecimal format ```0xAARRGGBB```, or ```0xRRGGBB```, or a standard color string name like "white" from ```flixel.util.FlxColor```)
* ```use_def``` (definition name)
* ```group``` (group name)
* ```width``` and ```height``` (optional, use exact pixel values or formulas -- will scale the image if they differ from the source image's native width/height)
* `smooth` (optional, defaults to true -- specifies how to scale the image if it's not 1:1 with the source. False for jaggies, True for smooth. Synonymous with `antialias`) 
* ```resize_ratio``` (optional, if you specify width or height, you can also define this to force a scaling aspect ratio)
* ```resize_ratio_x``` / ```resize_ratio_y``` (optional, does the same thing are resize_ratio, but only affects one axis)
* ```resize_point``` - (optional, string) specify anchor for resizing
    *  "nw" / "ul" -- Upper-left
    *  "n"  / "u"  -- Top
    *  "ne" / "ur" -- Upper-right
    *  "sw" / "ll" -- Lower-left
    *  "s"         -- Bottom
    *  "se" / "lr" -- Lower-right
    *  "m" / "c" / "mid" / "center" -- Center

## 2. 9-slice sprite/chrome (FlxUI9SliceSprite) ```<nineslicesprite>``` or ```<chrome>```

A 9-slice sprite can be scaled in a more pleasing way than just stretching it directly. It divides the object up into a user-defined grid of 9 cells, (4 corners, 4 edges, 1 interior), and then repositions and scales those individually to construct a resized image. Works best for stuff like chrome and buttons.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```src```
* ```width```/```height``` **NOT OPTIONAL**: the size of your 9-slice scaled image (not the size of the source image)
* ```slice9``` - string, two points that define the slice9 grid, format "x1,y1,x2,y2". For example, "6,6,12,12" works well for the 12x12 chrome images in the demo project.
* ```tile``` - bool, optional (assumes false if not exist). If true, uses tiling rather than scaling for stretching 9-slice cells. Boolean true == "true", not "True" or "TRUE", or "T".
* ```smooth``` - bool, optional (assumes false if not exist). If true, ensures the scaling uses smooth interpolation rather than nearest-neighbor (stretched blocky pixels).
* ```color``` - color, optional, to tint the chrome to (e.g. white does nothing.)  "color" attribute should be hexadecimal format ```0xAARRGGBB```, or ```0xRRGGBB```, or a standard color string name like "green" from ```flixel.util.FlxColor```)

## 3. Region (FlxUIRegion) ```<region>```

Regions are lightweight, invisible rectangles that can only be seen in Flixel's Debug "show outlines" mode. 

Despite being invisible, Regions are full-fledged IFlxUIWidget objects and are most useful as placeholders and as intermediate objects for setting up complex layouts. Basically, anytime you feel the urge to create a ```<sprite>``` or ```<chrome>``` tag where you don't really need to see that object, but just want to use it to position something else, or generate a targetable widget you can use in a subsequent formula, use a Region instead.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height```

## 4. Button (FlxUIButton) ```<button>```

Just a regular clicky button, optionally with a label.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height``` - optional, only needed if you're using a 9-slice sprite as source
* ```text_x```/```text_y``` - label x & y offsets
* ```label``` - text to show
* ```context``` - (optional) context value if label is a [firetongue](http://www.github.com/larsiusprime/firetongue) flag
* ```code``` - (optional) firetongue formatting code. Applies a formatting rule to the text:
    * "u" - all uppercase
    * "l" - all lowercase
    * "fu" - first letter uppercase
    * "fu_" - first letter in each word uppercase
* ```resize_ratio```, ```resize_point``` (see Image)
* ```resize_label``` - (optional, boolean) whether or not to let the label scale when the button is resized
* ```color``` - color, optional, to tint the chrome to (e.g. white does nothing.)  "color" attribute should be hexadecimal format ```0xAARRGGBB```, or ```0xRRGGBB```, or a standard color string name like "green" from ```flixel.util.FlxColor```)

Child tags:
* ```<text>``` - just like a regular \<text> node
* ```<param>``` - parameter to pass to the callback/event system (see "Button Parameters")
* ```<graphic>``` - graphic source (details below)

### 4.1 Working With Parameters

Parameters can be attached to buttons and many other types of interactive objects to give context to UI events. You do this by adding ```<param>``` child tags to the appropriate widget.

A ```<param>``` tag takes two attributes: ```type``` and ```value```. 

* ```type```: "string", "int", "float", and "color" or "hex" for a value like ```"0xFF00FF"```
* ```value```: the value, as a string. The type attribute will ensure it typecasts correctly.

```xml
<button name="new_game" use_def="big_button_gold" x="594" y="11" group="top" label="New Game">
	<param type="string" value="new"/>
</button>
```

You can add as many ```<param>``` tags as you want. When you click this button, it will by default call FlxUI's internal public static event callback:

```haxe
FlxUI.event(CLICK_EVENT, this, null, params);
```

This, in turn, will call ```getEvent()``` on whatever ```IEventGetter``` "owns" this ```FlxUI``` object. In the default setup, this is your ```FlxUIState```. So extend this function in your ```FlxUIState```:

```haxe
getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
```

The "sender" parameter will be the widget that originated the event -- in this case, the button. On a ```FlxUIButton``` click, the other parameters will be:

* **event name**: "click\_button" (ie, ```FlxUITypedButton.CLICK_EVENT```)
* **data**: ```null```
* **params**: an ```Array<Dynamic>``` containing all the parameters you've defined.

Some other interactive widgets can take parameters, and they work in basically the same way.

### 4.2 Button Graphics

Graphics for buttons can be kinda complex. You can put in multiple graphic tags, one for each button state you want to specify, or just one with the name "all" that combines all the states into one vertically stacked image, and asks the FlxUIButton to sort the individual frames out itself.

The system can sometimes infer what the frame size should be based on the image and width/height are not set, but it helps to be explicit with width/height if they are statically sized and you're not using 9-slice scaling.

Static, individual frames:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="up" image="ui/buttons/static_button_blue_up"/>
	<graphic name="over" image="ui/buttons/static_button_blue_over"/>
	<graphic name="down" image="ui/buttons/static_button_blue_down"/>
</definition>
```

9-slice scaling, individual frames:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="up" image="ui/buttons/9slice_button_blue_up" slice9="6,6,12,12"/>
	<graphic name="over" image="ui/buttons/9slice_button_blue_over slice9="6,6,12,12""/>
	<graphic name="down" image="ui/buttons/9slice_button_blue_down slice9="6,6,12,12""/>
</definition>
```

9-slice scaling, all-in-one frame:

```xml
<definition name="button_blue" width="96" height="32">
	<graphic name="all" image="ui/buttons/button_blue_all" slice9="6,6,12,12"/>
<definition>
```

I'm not 100% sure what will happen if you do individual frames and omit one, but I think I set it up to copy one of the other ones in some kind of "smart" way. Again, it's always best to be explicit about what you want rather than be ambiguous and have the system guess.

### 4.3 Button Text
To specify what the text in a button looks like, you create a ```<text>``` child node.
You can specify all the properties right here, or use a definition. There's a few special considerations for ```<text>``` nodes inside of a button.

The main "color" attribute (hexadecimal format, "0xffffff") is the main label color

If you want to specify colors for other states, you add ```<color>``` tags inside the ```<text>``` tag for each state:

```xml
<button x="200" y="505" name="some_button" use_def="text_button" label="Click Me">
	<text use_def="vera10" color="0xffffff">
		<color name="over" value="0xffff00"/>
	</text>
</button>	
````


## 5. Button, Toggle (FlxUIButton) ```<button_toggle>```

Toggle buttons are made from the same class as regular buttons, ```FlxUIButton```.

Toggle buttons are different in that they have 6 states, 3 for up/over/down when toggled, and 3 for up/over/down when not toggled. By default, a freshly loaded toggle button's "toggle" value is false.

Toggle buttons need more graphics than a regular button. To do this, you need to provide graphic tags for both the regular and untoggled states. The toggled ```<graphic>``` tags are the same, they just need an additional toggle="true" attribute:

```xml
<definition name="tab_button_toggle" width="50" height="20" text_x="-2" text_y="0">			
	<text use_def="sans10c" color="0xcccccc">
		<color name="over" value="0xccaa00"/>
		<color name="up" toggle="true" value="0xffffff"/>
		<color name="over" toggle="true" value="0xffff00"/>
	</text>
		
	<graphic name="up" image="ui/buttons/tab_grey_back" slice9="6,6,12,12"/>
	<graphic name="over" image="ui/buttons/tab_grey_back_over" slice9="6,6,12,12"/>
	<graphic name="down" image="ui/buttons/tab_grey_back_over" slice9="6,6,12,12"/>
		
	<graphic name="up" toggle="true" image="ui/buttons/tab_grey" slice9="6,6,12,12"/>
	<graphic name="over" toggle="true" image="ui/buttons/tab_grey_over" slice9="6,6,12,12"/>				
	<graphic name="down" toggle="true" image="ui/buttons/tab_grey_over" slice9="6,6,12,12"/>				
</definition>
```

Of course, if you create a single asset with 6 images stacked vertically, you can save yourself some room:

```xml
<definition name="button_toggle" width="50" height="20">		
	<text use_def="sans10c" color="0xffffff">
		<color name="over" value="0xffff00"/>
	</text>
	
	<graphic name="all" image="ui/buttons/button_blue_toggle" slice9="6,6,12,12"/>		
</definition>
```

Note that you can create a vertical stack of 9-slice assets, or regular statically-sized assets, the system can use either one. 

## 6. Check box (FlxUICheckBox) ```<checkbox>```

A Check Box is a FlxUIGroup which contains three objects: a "box" image, a "check" image, and a label.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```check_src``` - source image for box (not 9-sliceable, not scaleable)
* ```box_src``` - source image for check mark (not 9-sliceable, not scaleable)
* ```text_x``` / ```text_y``` - label offsets
* ```label``` - text to show
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)
* ```checked``` - (boolean) is it checked or not?
* ```label_width``` - width of the label

Child tags:
* ```<text>``` - same as ```<button>```
* ```<param>``` - same as ```<button>```
* ```<check>``` - alternate to check_src, more powerful*
* ```<box>``` - alternate to box_src, more powerful*

*If you supply ```<check>``` or ```<box>``` child tags instead of their attribute equivalents, FlxUI will treat them as full-fledged ```<sprite>``` or ```<chrome>``` tags to load for the checkmark and box assets. You'll want to use this method if you want to do something complicated, like load a scaled sprite, or a 9-slice-scaled sprite, that you can't normally accomplish with the src attributes, which just load a static image as-is.

Event:
* name - "click_checkbox"
* params - as defined by user, but with this one automatically added to the list at the end: "checked:true" or "checked:false"

## 7. Text (FlxUIText) ```<text>```

A regular text field. 

Attributes:
* ```text``` - the actual text in the textfield
* ```x```/```y```, ```use_def```, ```group```
* ```font``` - string, something like "vera" or "verdana"
* ```size``` - integer, size of font
* ```style``` - string, "regular", "bold", "italic", or "bold-italic"
* ```color``` - hex string, ie, "0xffffff" is white
* ```align``` - "left", "center", or "right". Haven't tested "justify"
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)

Text fields can also have borders. You can do this by specifying these four values:

* ```border``` - string, border style:
  * ```false```/```none``` - no border
  * ```shadow``` - drop shadow
  * ```outline``` - border (higher quality)
  * ```outline_fast``` - border (lower quality)
* ```border_color``` - color of the border
* ```border_size``` - thickness in pixels
* ```border_quality``` - number between 0.0 (lowest) and 1.0 (highest)

You can also use a shortcut for border value to save space by just using "shadow", "outline", or "outline_fast" directly as attributes and assigning them a color.

```xml
<text name="my_text" text="My Text" outline="0xFF0000"/>
```

As for fonts, FlxUI will look for a font file in your ```assets/fonts/``` directory, formatted like this:

|Filename|Family|Style|
|---|---|---|
vera.ttf|Vera|Regular
verab.ttf|Vera|Bold
verai.ttf|Vera|Italic
veraz.ttf|Vera|Bold-Italic

So far just .ttf fonts are supported, and you MUST name them according to this scheme (for now at least).

FlxUI does not yet support FlxBitmapFonts, but we'll be adding it eventually.

### 8. Text, input (FlxUIInputText) ```<input_text>```

This has not been thoroughly tested, but it exists.

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```font```, ```size```, ```style```, ```color```, ```align```
* (border attributes)
* ```password_mode``` - bool, hides text if true
* ```background``` - (optional, FlxColor) the background color
* ```force_case``` - (string) force text to appear in a specific case
    * "upper" / "upper_case" / "uppercase"
    * "lower" / "lower_case" / "lowercase"
* ```filter``` - (string) allow only certain kinds of text (not thoroughly tested with non-english locales)
    * "alpha" / "onlyalpha" - only standard alphabet characters
    * "num" / "numeric" - only standard number characters
    * "alphanum" / "alphanumeric", "onlyalphanumeric" -- only standard alphabet & number characters
* ```context``` - FireTongue context (see Button)
* ```code``` - Formatting code (see Button)

## 9. Radio button group (FlxUIRadioGroup) ```<radio_group>```

Radio groups are a set of buttons where only one can be clicked at a time. We implement these as a ```FlxUIGroup``` of ```FlxUICheckBox```'es, and then internal logic makes only one clickable at a time. 

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```radio_src``` - image src for radio button back (ie, checkbox "box")
* ```dot_src``` - image src for radio dot (ie, checkbox "check mark")

You construct a radio group by providing as many ```<radio>``` child tags as you want radio buttons. Give each of them an name and a label.

Child Nodes:
* ```<param>``` - same as ```<button>```, 
* ```<radio>``` - two attributes, name (string) and label (string)
* ```<dot>``` - alternate to dot_src, more powerful*
* ```<box>``` - alternate to radio_src, more powerful*

*If you supply ```<dot>``` or ```<box>``` child tags instead of their attribute equivalents, FlxUI will treat them as full-fledged ```<sprite>``` or ```<chrome>``` tags to load for the dot and radio-box assets. You'll want to use this method if you want to do something complicated, like load a scaled sprite, or a 9-slice-scaled sprite, that you can't normally accomplish with the src attributes, which just load a static image as-is.

Event:
* ```name``` - "click_radio_group"
* ```params``` - same as Button

## 10. Tabbed menu (FlxUITabMenu) ```<tab_menu>```

Tab menus are the most complex ```FlxUI``` widget. ```FlxUITabMenu``` extends ```FlxUI``` and is thus a full-fledged ```FlxUI``` in and of itself, just like the ```<layout>``` tag.

This provides a menu with various tabbed buttons on top. When you click on one tab, it will show the content for that tab and hide the rest. 

Attributes:
* ```x```/```y```, ```use_def```, ```group```
* ```width```/```height```
* ```back_def``` - name for a 9-slice chrome definition (MUST be 9-sliceable!)
* ```slice9```

Child Nodes:
* ```<tab>``` - attributes are "name" and "label", much like in ```<radio_group>```
* ```<group>``` - attributes are only "name"
 * Put regular FlxUI content tags here, within the ```<group></group>``` node.

## 11. Line (FlxUISprite) ```<line>```

TODO

## 12. NumStepper (FlxUINumericStepper) ```<numeric_stepper>```

TODO

## 13. Dropdown/Pulldown (FlxUIDropDownMenu) ```<dropdown>```

TODO

## 14. Bar ([FlxUIBar](https://api.haxeflixel.com/flixel/addons/ui/FlxUIBar.html)) ```<bar>```

Provides a Bar that can be used for displaying health or progress.

Attributes:
* ```x```/```y``` - position of the bar
* ```width```/```height``` - dimensions of the bar
* ```fill_direction``` - the fill direction. `left_to_right` is the default. See below for a list of possible values.
* ```parent_ref``` - A reference to an object in your game that you wish the bar to track (the value of)
* ```variable``` - The variable of the object that is used to determine the bar position. For example if the parent was an FlxSprite this could be "health" to track the health value
* ```min``` - The minimum value. I.e. for a progress bar this would be zero (nothing loaded yet)
* ```max``` - The maximum value the bar can reach. I.e. for a progress bar this would typically be 100.
* ```value``` - The value that the bar is at initially. Default is `max`
* ```border_color``` - Color of the border. If omitted there is no border at all.
* ```filled_color``` or ```color``` - The color of the bar when full in hexformat. Default is red.
* ```empty_color``` - The color of the bar when empty in hexformat. Default is red.
* ```filled_colors``` or ```colors``` and ```empty_colors``` - Creates a gradient filled health bar using the given colour ranges.
* ```chunk_size``` - If you want a more old-skool looking chunky gradient, increase this value!
* ```rotation``` - Angle of the gradient in degrees. 90 = top to bottom, 180 = left to right. Any angle is valid
* ```src_filled```/```src_empty``` - Use an image for the filled/empty bar.

Possible `fill_direction` values:
* "left_to_right"
* "right_to_left"
* "top_to_bottom"
* "bottom_to_top"
* "horizontal_inside_out"
* "horizontal_outside_in"
* "vertical_inside_out"
* "vertical_outside_in"


## 15. TileTest (FlxUITileTest) ```<tile_test>```

TODO


----

# Tooltips

Tooltips can be added to button and button-like widgets, including ```<button>```, ```<button_toggle>```, ```<checkbox>```, the ```<radio>``` child tags of a ```FlxUIRadioGroup```, and the ```<tab>``` child tags of a ```FlxUITabMenu```.

(Note that there is a full-featured "Tooltips" demo in [flixel-demos](https://github.com/haxeflixel/flixel-demos), underneath the "User Interface" category.)

Attributes:
* ```x```/```y``` - x/y offset for the tooltip's anchor
* ```use_def``` - you can specify a definition for a tooltip just like anything else
* ```width```/```height```
* ```text``` - string, set this if you only want one text field, not two (a title and a body text)
* ```background``` - the color of the background
* ```border``` - the size of the outline border, in pixels
* ```border_color``` - the color of the outline border
* ```arrow``` - string, sprite asset source for the arrow
* ```auto_size_horizontal``` - bool, whether to crop the width of the tooltip to bounds of the visible text + padding (default true)
* ```auto_size_vertical``` - bool, whether to crop the height of the tooltip to bounds of the visible text + padding (default true)
* ```pad_left``` - left-side padding, in pixels
* ```pad_right``` - right-side padding, in pixels
* ```pad_top``` - top-side padding, in pixels
* ```pad_bottom``` - bottom-side padding, in pixels
* ```pad_all``` - shortcut, set all 4 padding values in one attribute
 
Child Nodes:
* ```title``` - a FlxUIText node, specifies the title text content and sty
  * ```x```/```y``` - you can specify an x/y offset for the title text itself
  * if you specified the tooltip text via the "text" shortcut attribute, it uses the "title" textfield and hides the body
  * in this case you can still set a style via the "title" node
* ```body``` - a FlxUIText node, specifies the body text content and style
  * ```x```/```y``` - you can specify an x/y offset for the body text itself
  * note that the default position of the ```body``` text field is directly underneath the title textfield
* ```anchor``` - this specifies how your tooltip attaches to its parent object. 
  * You do this the same way you would use anchor tags elsewhere, with ```x```/```y``` and ```x-flush```/```y-flush```. 
  * Note that the ```x```/```y``` *attributes* set in the ```<tooltip>``` node itself serve as the x/y *offsets* for the anchor, just as they do with every other widget.

A very basic tooltip is added like this:

```xml
<button name="basic" x="160" y="120" label="Basic">
    <tooltip text="Basic tooltip"/>
</button>
```

This tooltip uses both text fields:

```xml
<button name="fancier" x="basic.x" y="basic.bottom+10" label="Fancier">
	<tooltip>
		<title text="Fancier tooltip!" width="100"/>
		<body text="This tooltip has a title AND a body." width="100" />
	</tooltip>
</button>
```

This tooltip sets just about everything:

```xml
<button name="fanciest" x="basic.x" y="even_fancier.bottom+10" label="Fanciest">
	<tooltip pad_all="5" background="red" border="1" border_color="white">
		<title use_def="sans12" text="Fanciest tooltip!" width="125"/>
		<body use_def="sans10" text="This tooltip has a title and a body, custom padding and offsets, as well as custom text formatting" width="120" x="5" y="5"/>
		<anchor x="center" x-flush="center" y="bottom" y-flush="top"/>
	</tooltip>
</button>
```

----

# Dynamic position & size

## 1. Anchor Tags

Here's an example of a health bar from an RPG:

```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
</nineslicesprite>
```

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

You can also specify a **round** attribute (up/down/round/true/false) in the anchor tag itself to round the final calculated position.

**Note to non-native speakers of English:** "flush" is a carpentry term, so if one side of one object is parallel to and touching another object's side with no air between them, the objects are "flush." This has nothing to do with toilets :)

--
## 2. Position Tags

Sometimes you want to be able to change the position of a widget later in the xml markup. Position tags work much like the original creation tag for the object, except you ONLY include the attribute name of the object you want to move, and any relevant position information.

```xml
<position name="thing" x="12" y="240"/>
```

You can use anchor tags, formulas, etc inside a position tag:
```xml
<position name="thing" x="other_thing.right" y="other_thing.bottom">
  <anchor name="other_thing" x-flush="left" y-flush="top"/>
</position>
```

--
## 3. Size Tags

Let's add a size tag to our health bar:
```xml
<nineslicesprite name="health_bar" x="10" y="5" width="134" height="16" use_def="health" group="mcguffin">
	<anchor x="portrait.right" y="portrait.top" x-flush="left" y-flush="top"/>
	<exact_size width="stretch:portrait.right+10,right-10"/>
</nineslicesprite>
```

There are three size tags: ```<min_size>```, ```<max_size>```, and ```<exact_size>```

This lets you either specify dynamic lower/upper bounds for an object's size, or force it to be an exact size. This lets you create a UI that can work in multiple resolutions, or just avoid having to do manual pixel calculations yourself. 

Size tags take only three attributes, **width**, **height**, and **round**. If either width or height is not specified, that part of the size is ignored and remains the same size.

There are several ways to formulate a width/height attribute:

* **number** (ie, width="100")
* **stretch** (ie, width="stretch:some_value,another_value")
* **reference** (ie, width="some_id.some_value")

A **stretch** formula will tell FlxUI to calculate the difference between two values separated by a comma. These values are formatted and calculated just like a **reference** formula. The axis is inferred from whether it's width or height. 

So, if you have a scoreboard at the top of the screen, and you want the playfield to stretch from the bottom of the scoreboard to the bottom of the screen:

```xml
<exact_size height="stretch:scoreboard.bottom,bottom"/>
```

Acceptable property values for reference formula, used alone or in a stretch:
* **naked reference** (ie, "some_id") - returns inferred x or y position of that thing.
* **property reference** (ie, "some_id.some_value") - returns a thing's property
 * "left", "right", "top", "bottom", "width", "height", "halfwidth", "halfheight", "centerx", "centery"
 * "center" (infers centerx or centery)
* **arithmetic formula** (ie, "some_id.some_value+10") - do some math
 * You can tack on **one** operator and **one** operand (numeric value or widget property) to any of the above.
 * Legal operators = (+, -, *, \, ^)
 * Don't try to get too crazy here. If you need to do some super duper math, just add some code in your FlxUIState, call getAsset("some_id") to grab your assets, and do the craziness yourself.

--
## 4. Alignment Tags

An ```<align>``` tag lets you automatically align and space various objects together.

```xml
<align axis="horizontal" spacing="2" resize="true">
	<bounds left="options.left" right="options.right"/>
	<objects value="spell_0,spell_1,spell_2,spell_3,spell_4,spell_5"/>
</align>
```

Attributes:
* axis - "horizontal" or "vertical"
* spacing - number
* resize - bool, optional, "true" or "false" (if not exist, assumes false)

Child tags:
* ```<bounds>``` - string, reference formula, specify left & right for horizontal, or top & bottom for vertical
* ```<objects>``` - string, comma separated list of object name's

If you specify more than one "objects" tag, you can align several groups of objects at once according to the same rules. For instance, if you have obj_0 through obj_9 (10 in total), and you want two rows spaced evenly in five columns, this would do the trick:

```xml
<align axis="horizontal" spacing="2" resize="true">
	<bounds left="options.left" right="options.right"/>
	<objects value="obj_0,obj_1,obj_2,obj_3,obj_4"/>
	<objects value="obj_5,obj_6,obj_7,obj_8,obj_9"/>
</align>
```

Whereas putting all 10 objects in one ```<objects>``` tag would instead get you one row with 10 columns.

----

# Localization (FireTongue)
First, Firetongue has some [documentation](https://github.com/larsiusprime/firetongue) on its Github page. Read that. 

In your local project, follow these steps:

**1. Create a FireTongue wrapper class**

 It just needs to:
 1. Extend **firetongue.FireTongue**
 2. Implement **flixel.addons.ui.IFireTongue** 
 3. Source is below, "FireTongueEx" [1]

**2. Create a FireTongue instance somewhere**

Add this variable declaration in Main, for instance:

```haxe
public static var tongue:FireTongueEx;
```
Note that it's type is ```FireTongueEx```, not ```FireTongue```. (This way the instance implements ```IFireTongue```, which ```FlxUI``` needs).

**3. Initialize your FireTongue instance**

Add this initialization block anywhere in your early setup code (either in ```Main``` or in the ```create()``` block of your first ```FlxUIState```, for instance):

```haxe
if (Main.tongue == null) {
	Main.tongue = new FireTongueEx();
	Main.tongue.init("en-US");
	FlxUIState.static_tongue = Main.tongue;
}
```

Setting ```FlxUIState.static_tongue``` will make every ```FlxUIState``` instance automatically use this ```FireTongue``` instance without any additional setup. If you don't want to use a static reference, you can just do this on a per-state basis:

```haxe
//In the create() function of some FlxUIState object:
_tongue = someFireTongueInstance;	
```

**4. Start using FireTongue flags**

Once a ```FlxUIState``` is hooked up to a ```FireTongue``` instance, it will automatically attempt to translate any raw text information as if it were a ```FireTongue``` flag -- see ```FireTongue```'s [documentation](https://github.com/larsiusprime/firetongue).

Here's an example, where the word "Back" is translated via the localization flag "$MISC_BACK":
```haxe
<button center_x="true" x="0" y="535" name="start" label="$MISC_BACK">		
	<param type="string" value="back"/>
</button>
```
In English (en-US) this will be "Back," in Norwegian (nb-NO) this will be "Tilbake."

...

[1] Here's the source code snippet for ```FireTongueEx.hx```:
```haxe
import firetongue.FireTongue;
import flixel.addons.ui.interfaces.IFireTongue;

/**
 * This is a simple wrapper class to solve a dilemma:
 * 
 * I don't want flixel-ui to depend on firetongue
 * I don't want firetongue to depend on flixel-ui
 * 
 * I can solve this by using an interface, IFireTongue, in flixel-ui
 * However, that interface has to go in one namespace or the other and if I put
 * it in firetongue, then there's a dependency. And vice-versa.
 * 
 * This is solved by making a simple wrapper class in the actual project
 * code that includes both libraries. 
 * 
 * The wrapper extends FireTongue, and implements IFireTongue
 * 
 * The actual extended class does nothing, it just falls through to FireTongue.
 */
class FireTongueEx extends FireTongue implements IFireTongue
{
	public function new() 
	{
		super();
	}	
}
````

----------

# Advanced Tip & Tricks

There's a lot of clever things you can do with flixel-ui once you know what you're doing.

## 1. "screen" widget always represents the flixel canvas

There is always a FlxUIRegion defined by the system in any root-level FlxUI objects with the reserved named "screen". So you can always use "screen.width", "screen.top", "screen.right", etc, in any of your formulas.

## 2. Resolution independent text

It's common for beginners to define their fonts in absolute terms like this:
```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="12" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="16" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="20" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans12" font="verdana" size="30" style="bold" color="0xffffff" outline="0x000000"/>
```

Size 10 font might look just fine if your game is 800x600, but what if you let the user choose the window/screen size, and they're viewing the game in 1920x1080? What if you're targetting multiple different devices? At 800x600, Size 10 font is 1.67% of the total screen height. At 1920x1080, it's 0.93%, almost half the size! So we should use a bigger font. But it might be a huge pain to use code to inspect every text field and update it. Here's a better way to do things:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_small"    font="verdana" size="screen.height*0.02000" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_medium"   font="verdana" size="screen.height*0.02667" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_large"    font="verdana" size="screen.height*0.03334" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_huge"     font="verdana" size="screen.height*0.04167" style="bold" color="0xffffff" outline="0x000000"/>
<definition name="sans_enormous" font="verdana" size="screen.height*0.05000" style="bold" color="0xffffff" outline="0x000000"/>
```

By defining the font size in terms of the screen height, we can achieve the same results at 800x600, but make the text grow dynamically with the size of the screen. "sans_tiny" will be 10 points high in 800x600, but 18 points high in 1920x1080, representing the same proportion of the screen.

# 3. Conditional scaling

Let's say you want to load a different asset in a 16x9 screen mode than a 4x3 mode, and fit it to the screen.

```xml
<sprite name="thing" src="ui/asset">
	<scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" width="100%" height="100%"/>
	<scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" width="100%" height="100%"/>
</sprite>
```

```screen_ratio``` and ```tolerance``` are optional -- they let you filter whether the ```<scale>``` node is activated. If not supplied, the given <scale> node is immediately applied. The ratio is width/height and tolerance is the wiggle room.

```suffix``` is the suffix to apply to your src parameter, "ui/asset". ```width```/```height```, of course, are treated as they are throughout Flixel-UI markup.

So in the above example, if the screen is within 0.25 of a 16:9 ratio, it will load "ui/asset_16x9.png", if it's within 0.25 of a 4:3 ratio, it will load "ui/asset_4x3.png", and in both cases will scale them to fit the screen.

But sometimes you don't want to scale both ```width```/```height``` separately, the most common use case is to scale based on the vertical axis alone and then automatically scale width proportionately. Use "to_height" for this:

```xml
<sprite name="thing" src="ui/asset">
	<scale screen_ratio="1.77" tolerance="0.25" suffix="_16x9" to_height="100%"/>
	<scale screen_ratio="1.33" tolerance="0.25" suffix="_4x3" to_height="100%"/>
</sprite>
```

Note that these `<scale>` tags accept the "smooth" attribute to turn antialiasing off/on when scaling, just like a sprite can.

# 4. Scaling 9-slice-sprite source BEFORE 9-slice-scaling

Let's say you've got a 9-slice-sprite, but for whatever reason you want to scale the *source* image first, *before* you then subject it to the 9-slice matrix. You can do that like this:

```xml
<chrome name="chrome" width="600" height="50" src="ui/asset" slice9="4,4,395,95">
	<scale_src to_height="10%"/>
	<anchor y="bottom" y-flush="bottom"/>
</chrome>
```

Here's what's happening. Let's say "ui/asset.png" is 400x50 pixels. In this case I scale it down first using the ```<scale_src>``` tag, which is unique to 9-slice-sprites. The "to_height" property scales the asset to a target height (10% of the screen height in this case), and also scales the width proportionately. (You can also use "width" and "height" parameters instead). Whenever you scale an asset like this in a 9-slice sprite, the slice9 coordinates will be automatically be scaled to match the new scaled source material. Then, your final asset will be 9-slice scaled.

# 5. Defining "points"

So previously we had this:

```xml
<definition name="sans10" font="verdana" size="10" style="bold" color="0xffffff" outline="0x000000"/>
```

Which we changed to this:

```xml
<definition name="sans_tiny"     font="verdana" size="screen.height*0.01667" style="bold" color="0xffffff" outline="0x000000"/>
```

Now you can just do this!
```xml
<point_size x="screen.height*0.001667" y="screen.width*0.001667"/>
<definition name="sans10" font="verdana" size="10pt" style="bold" color="0xffffff" outline="0x000000"/>
```

Whenever you use the ```<point_size/>``` tag, you are defining the horizontal and vertical size of a "point", which is referenced whenever you enter a numerical value and add the letters "pt" to the end. Basically whenever it sees "10pt" it will multiply 10 by the size of the point. For font sizes this is the vertical size of the point, in other places it infers from the context (x="15pt" is horizontal pt size, y="25pt" is vertical pt size).

If you do this:
```xml
<point_size value="screen.height*0.001667"/>
```
It uses the same value for both vertical and horizontal point size. In case you were wondering, 0.001667 is the value of 1/600. So if you have a game where you do the base layout at say 800x600, then you can define this point value to make it easily scale to other resolutions.

Only one ```<point_size/>``` tag is active at a time, the last one that the parse finds in the document. You can, however, put one in an included file and it will be loaded (so long as your current file doesn't have one that overrides it).

You can use a point-number anywhere (at least, I think) you can use a normal numerical value.
