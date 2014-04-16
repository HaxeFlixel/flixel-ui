1.0.2
------------------------------
* Compatibility with flixel 3.3.0
* Added FlxUIList
    * A configurable, scrollable list that is an arbitrary collection of IFlxUIWidgets
* Added FlxUICursor
    * A configurable keyboard-controlled cursor that can click anything clickable
* Added FlxUISlider
    * As seen in FlxBunnyMark
    * Rudimentary for now, will be improved later
* Added FontDef, BorderDef, and ButtonLabelStyle style structure
* FlxUITypedButton:
    * Added "CLICK_EVENT" to forceStateHandler()
    * Exposed setCenterLabelOffset()
    * Added "round_labels" parameter for better bitmap font rendering, true by default
    * Fixed bug where non-toggling buttons still had toggling behavior
    * Fixed "first frame flutter" where label correctly positions only after first update()
    * Newly constructed unstyled instances use default flixel-ui assets immediately
* FlxUIButton
    * Resizing now updates label's width AND fieldWidth
* FlxInputText/FlxUIInputText:
    * Fixed bugs with caret positions
    * Minor cleanup / bugfixes
* FlxUIPopup
    * Fixed bug where events were sent to itself rather than parent state
* FlxUIColorSwatch / FlxUIColorSwatchSelecter
    * Cleanup
    * Fixed null errors on neko
* FlxUITabMenu
    * Make "back" parameter optional, creates default asset if null
* FlxUI
    * Fixes to _loadButton that solve weird neko crashes
    * XML Layout: Assigning a sprite AND a text label to a button will now add them both (uses a group)
    * XML Layout: You can now change "params" values via modes
* Lots of cleanup in various classes
* Improved internal pooling and safe destruction
* Added pretty-printed XML output to U.hx
* Updated documentation a little. Still need to catch up.

1.0.1
------------------------------
* Compatibility with flixel 3.2.0
* Refactored the event system
* FlxUIInputText:
  * fixed issue with RegExp error
  * fixed background not showing up on native targets
  * fixed the destruction logic
  * added workaround for missing getCharIndexAtPoint() / getCharBoundary() on non-flash targets
* FlxUIDropDownMenu:
  * content can now be changed after creation
  * fixed list destruction logic
* Added FlxUIColorSwatch / FlxUIColorSwatchSelector

1.0.0
------------------------------
* Initial haxelib release
