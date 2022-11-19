2.5.0 (November 19, 2022)
------------------------------ 
* Deprecate haxe 3
* Fix FlxUICursor camera scroll (#233) 

2.4.0 (September 12, 2021)
------------------------------ 
* Compatibility with flixel 4.10.0

2.3.3 (July 2, 2020)
------------------------------
* Fixed `Std.is()` deprecation warnings with Haxe 4.2

2.3.2 (February 4, 2019)
------------------------------
* Compatibility with Haxe 4.0.0-rc.1
* Fixed `<sprite>` path when `src` is `RAW:` (#212)

2.3.1 (August 10, 2018)
------------------------------
* Compatibility with latest Haxe dev
* Compatibility with Lime 7's HL target

2.3.0 (May 4, 2018)
------------------------------
* Compatibility with flixel 4.4.0
* `FlxUIDropDownMenu`: fixed menus dropping in the wrong direction sometimes (flixel-demos#256)
* `FlxUI`: disabled warnings for using flixel-ui elements outside of a `FlxUIState`

2.2.0 (October 11, 2016)
------------------------------
* Compatibility with flixel 4.2.0
* `FlxUICheckBox`: fixed alignment on HTML5 (#192)
* `FlxInputText`: added `focusGained` and `focusLost` (#176)
* `FlxUITooltipManager`:
  * fixed tooltips being off-screen sometimes (#181)
  * added support for tooltips on non-clickable elements (#182)
  * added `cameras` (#187)
* `FlxUIState` / `FlxUISubState`: finished `reload_ui_on_resize` (#188)
* `FlxUIButton` / `FlxUI9SliceSprite`: added `color` arguments to `new()` (#180)
* `FlxInputText`: fixed an issue with caret positions in empty textfields (#193)
* Assets are now included with `"embed=true"` (#198)

2.1.0 (July 10, 2016)
------------------------------
* Compatibility with flixel 4.1.0
* `FlxUI`:
  * added `tolerance_plus` / `tolerance_minus` attributes for `<load_if>`
  * added `fontStr()`, `fontSize()` and `font()`
  * added support for overriding the internal `"screen"` asset
  * fixed a spacing issue in alignments
* `FlxUIState`: added `onShowTooltip()` 
* `FlxUISubState`:
  * added `createUI()` (#169)
  * added `onShowTooltip()`
* `FlxUITooltip`:
  * added a `ShowArrow` argument to `show()`
  * fixed rendering artifacts by using integer rounding
* `FlxUITooltipManager`: added `fixedPosition`, `showTooltipArrow`, `isVisible()`, `stickyTooltipFor()` and `showTooltipFor()`
* `FlxUILine`: [Cpp] fixed `thickness`
* `FlxUIButton`: added support for `labelOffsets` in `addIcon()` (#175)
* `FlxMultiGamepadAnalogStick`: added null safety checks
* `FlxUICursor`:
  * added `getCurrentWidget()` and `clearWidgets()`
  * fixed several bugs
* `FlxUIList`: fixed a minor positioning issue
* `U`: added `setButtonLabel()`
* Added support for Firteongue font replacement rule integration

2.0.0 (February 16, 2016)
------------------------------
* Compatibility with flixel 4.0.0
* `FlxUI`:
   * added `getAllAssets()`
   * added `getAssetKeys()`
   * added support for auto-scaled images in xml
   * added `<position>`
   * added `liveFilePath` and support for live reloading
   * added support for different rounding modes in xml
   * added basic support for setting and comparing variables in xml
   * added `<load_if>`
   * the `spacing` attribute in `<align>` can now use formulas
   * added `to_height` attribute to `<scale>`
   * 9-slice sprites can now be scaled before 9-slice-scaling in xml
   * added `setVariable()`
   * added `sendToFront()` and `sendToBack()`
   * added `getAssetGroup()`
   * added `<inject>`
   * added support for an `alpha` attribute to all widget tags
* `IFlxUIWidget`:
   * renamed `id` to `name` 
* `FlxUITypedButton`:
   * can now have a separate toggle label
   * added `copyStyle()`
   * added `getCenterLabelOffset()`
   * added `clone()`
   * `active` can now be set in xml
   * added `autoResizeLabel`
   * `up` / `over` / `down` colors are now nullable
   * `loadGraphicSlice9()` and `loadGraphicsMultiple()` now take an array of `FlxGraphicAsset`s instead of `String`
* `FlxUIText`:
   * now implements `IHasParams`
   * `border="none"` / `border="false"` is now supported in xml
   * added `clone()`
   * added support for resizing
* `FlxUISprite`:
   * added support for resizing
   * now automatically scales if `width`, `height` or `resize_ratio` are specified in xml
* `FlxUIRadioGroup`:
   * added `getLabel()`
   * added `getId()`
   * added support for active / inactive states
* `FlxUIRadioButton`:
   * the box and dot can now be loaded as sprites (`<dot>` and `<box>`)
* `FlxUIInputText`:
   * `password_mode` can now be set in xml
* `FlxUIState`:
   * added `loadUIFromData()`
   * added `createUI()`
   * no longer sets `FlxG.mouse.visible` to `true` automatically
   * added `setUIVariable()`
   * added `tooltips`
* `FlxUISubState`:
   * added `BGColor` argument to `new()`
   * added `tooltips`
* `FlxUINumericStepper`:
   * addeds support for decimals
* `FlxUICursor`:
   * added gamepad support
* `FlxUIDropDownMenu`:
   * now drops upwards if height exceeds `FlxG.height`
   * added `dropDirection` and `FlxUIDropDownMenuDropDirection`
* `FlxUIColorSwatchSelecter`:
   * added support for custom swatch graphics
* `FlxUIGroup`:
   * added `setScrollFactor()` 
* `U`:
   * added `endline()`
   * added `loadImageScaleToHeight()`
   * added `unparentXML()`
* Added `FontDef`
* Added `BorderDef`
* Added `ButtonLabelStyle`
* Added `FlxUIBar`
* Added `FlxMultiGamepad`
* Added `FlxMultiGamepadAnalogStick`
* Renamed `MultiKey` to `FlxMultiKey`
* Added `FlxUITooltip` and `FlxUITooltipManager`
* Added `FlxUILine`

1.0.2 (April 24, 2014)
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

1.0.1 (February 21, 2014)
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

1.0.0 (February 6, 2014)
------------------------------
* Initial haxelib release
