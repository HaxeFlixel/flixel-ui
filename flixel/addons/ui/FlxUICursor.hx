package flixel.addons.ui;
import flash.events.MouseEvent;
import flixel.addons.ui.Anchor;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.interfaces.ICursorPointable;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * Cursor object that you can use to "click" on interface elements using a keyboard or gamepad
 * TODO: need to support gamepad and/or deal with absence of mouse
 * @author 
 */
class FlxUICursor extends FlxUISprite
{
	public var callback:String->IFlxUIWidget->Void;		//callback to notify whoever's listening that I did something(presumably a FlxUI object)
	
	public var location(default, set):Int = -1;			//which object the cursor is pointing to (-1 means nothing)
	private function set_location(i:Int):Int{
		if (i >= _widgets.length) {
			i = _widgets.length - 1;
		}
		location = i;
		_updateCursor();
		return location;
	}
	
	//Key configurations, you can set easily with setDefaultKeys(KEYS_DEFAULT_TAB), for instance.
	
	public var keysUp:Array<MultiKey>;		//List of keys (ie, tab) and/or key combinations (ie, shift+tab) that indicate intent to go "up"
	public var keysDown:Array<MultiKey>;	
	public var keysLeft:Array<MultiKey>;	
	public var keysRight:Array<MultiKey>;	
	public var keysClick:Array<MultiKey>;	//intent to "click" or select
	
	//Various default key configurations:
	
	public static inline var KEYS_DEFAULT_TAB:Int =        0x0001;	//tab to go "right", shift+tab to go "left", enter to click
	public static inline var KEYS_DEFAULT_WASD:Int =       0x0010;	//WASD to go up/left/down/right, enter to click
	public static inline var KEYS_DEFAULT_ARROWS:Int =     0x0100;	//Arrows to go up/left/down/right, enter to click
	public static inline var KEYS_DEFAULT_NUMPAD:Int =     0x1000;	//Numpad numbers to go up/left/down/right, enter to click
	
	//Determines how the cursor attaches itself to the widget it's pointing to
	public var anchor:Anchor;
	
	public var dispatchEvents:Bool = true;					//set to false if you just want to rely on callbacks rather than low-level events
	
	//TODO: make this work
	public var inputMethod:Int = 0x00;						//simple bitmask for storing what input methods can move the cursor
	
	public static inline var INPUT_NONE:Int = 0x00;			//No cursor input what
	public static inline var INPUT_KEYS:Int = 0x01;			//Use keyboard to control the cursor
	public static inline var INPUT_GAMEPAD:Int = 0x10;		//Use gamepad to control the cursor
	
	/*********************************/
	
	/**
	 * Creates a cursor that can be controlled with the keyboard or gamepad
	 * @param	Callback		callback to notify listener about when something happens
	 * @param	InputMethod		bit-flag, accepts INPUT_KEYS, INPUT_GAMEPAD, or both using "&" operator
	 * @param	DefaultKeys		default hotkey layouts, accepts KEYS_DEFAULT_TAB, ..._WASD, etc, combine using "&" operator
	 * @param	Asset			visual asset for the cursor. If not supplied, uses default
	 */
	
	public function new(Callback:String->IFlxUIWidget->Void,InputMethod:Int=INPUT_KEYS,DefaultKeys:Int=KEYS_DEFAULT_TAB,?Asset:Dynamic=null) 
	{
		if (Asset == null) {							//No asset detected? Guess based on game's resolution
			if(FlxG.height < 400){
				Asset = FlxUIAssets.IMG_FINGER_SMALL;	//16x16 pixel finger
			}else {
				Asset = FlxUIAssets.IMG_FINGER_BIG;		//32x32 pixel finger
			}
		}
		
		super(0, 0, Asset);
		
		inputMethod = InputMethod;
		_widgets = [];
		anchor = new Anchor( -5, 0, Anchor.LEFT, Anchor.CENTER, Anchor.RIGHT, Anchor.CENTER);
		setDefaultKeys(DefaultKeys);
		callback = Callback;
	}
	
	public override function update():Void {
		super.update();
		_checkKeys();
	}
	
	public function addWidget(widget:IFlxUIWidget):Void 
	{
		if (Std.is(widget, ICursorPointable))			//directly pointable? add it
		{
			_widgets.push(widget);
		}
		else if (Std.is(widget, FlxUIGroup))			//it's a group? 
		{			
			var g:FlxUIGroup = cast widget;
			for (member in g.members)
			{
				if (Std.is(member, IFlxUIWidget))
				{
					addWidget(cast member);					//add each member individually
				}
			}
		}
		_widgets.sort(_sortXY);
	}
	
	public function removeWidget(widget:IFlxUIWidget):Bool{
		var value:Bool = false;
		if (_widgets != null) {
			if (_widgets.indexOf(widget) != -1) {
				value = _widgets.remove(widget);
				_widgets.sort(_sortXY);
			}
		}
		return value;
	}
	
	/**
	 * Set the default key layout quickly using a constant. 
	 * @param	code	KEYS_DEFAULT_TAB, ..._WASD, etc, combine with "&" operator
	 */
	
	public function setDefaultKeys(code:Int):Void {
		_clearKeys();
		_newKeys();
		if (code & KEYS_DEFAULT_TAB == KEYS_DEFAULT_TAB) {
			_addToKeys(keysRight, new MultiKey(FlxG.keys.getKeyCode("TAB"),null,[FlxG.keys.getKeyCode("SHIFT")]));	//Tab, (but NOT Shift+Tab!)
			_addToKeys(keysLeft, new MultiKey(FlxG.keys.getKeyCode("TAB"), [FlxG.keys.getKeyCode("SHIFT")]));		//Shift+Tab
			_addToKeys(keysClick, new MultiKey(FlxG.keys.getKeyCode("ENTER")));
		}
		if (code & KEYS_DEFAULT_ARROWS == KEYS_DEFAULT_ARROWS) {
			_addToKeys(keysRight, new MultiKey(FlxG.keys.getKeyCode("RIGHT")));
			_addToKeys(keysLeft, new MultiKey(FlxG.keys.getKeyCode("LEFT")));
			_addToKeys(keysDown, new MultiKey(FlxG.keys.getKeyCode("DOWN")));
			_addToKeys(keysUp, new MultiKey(FlxG.keys.getKeyCode("UP")));
			_addToKeys(keysClick, new MultiKey(FlxG.keys.getKeyCode("ENTER")));
		}
		if (code & KEYS_DEFAULT_WASD == KEYS_DEFAULT_WASD) {
			_addToKeys(keysRight, new MultiKey(FlxG.keys.getKeyCode("D")));
			_addToKeys(keysLeft, new MultiKey(FlxG.keys.getKeyCode("A")));
			_addToKeys(keysDown, new MultiKey(FlxG.keys.getKeyCode("W")));
			_addToKeys(keysUp, new MultiKey(FlxG.keys.getKeyCode("S")));
			_addToKeys(keysClick, new MultiKey(FlxG.keys.getKeyCode("ENTER")));
		}
		if (code & KEYS_DEFAULT_NUMPAD == KEYS_DEFAULT_NUMPAD) {
			_addToKeys(keysRight, new MultiKey(FlxG.keys.getKeyCode("NUMPADSIX")));
			_addToKeys(keysLeft, new MultiKey(FlxG.keys.getKeyCode("NUMPADFOUR")));
			_addToKeys(keysDown, new MultiKey(FlxG.keys.getKeyCode("NUMPADTWO")));
			_addToKeys(keysUp, new MultiKey(FlxG.keys.getKeyCode("NUMPADEIGHT")));
			_addToKeys(keysClick, new MultiKey(FlxG.keys.getKeyCode("ENTER")));
		}
	}
	
	/****PRIVATE****/
	
	private var _widgets:Array<IFlxUIWidget>;			//master list of widgets under cursor's control
	
	private function _sortXY(a:IFlxUIWidget, b:IFlxUIWidget):Int {
		if (a.y < b.y) return -1;
		if (a.y > b.y) return 1;
		if (a.x < b.x) return -1;
		if (a.x > b.x) return 1;
		return 0;
	}
	
	private function _addToKeys(keys:Array<MultiKey>, m:MultiKey) {
		var mk:MultiKey;
		var exists:Bool = false;
		for (mk in keys) {
			if (m.equals(mk)) {
				exists = true;
				break;
			}
		}
		if (!exists) {
			keys.push(m);
		}
	}
	
	private function _clearKeys():Void {
		U.clearArray(keysUp); keysUp = null;
		U.clearArray(keysDown); keysDown = null;
		U.clearArray(keysLeft); keysLeft = null;
		U.clearArray(keysRight); keysRight = null;
		U.clearArray(keysClick); keysClick = null;
	}
	
	private function _newKeys():Void {
		keysUp = [];
		keysDown = [];
		keysLeft = [];
		keysRight = [];
		keysClick = [];
	}
	
	private function _checkKeys():Void {
		var key:MultiKey;
		
		var upPressed:Bool = false;
		
		for (key in keysUp) {
			if (key.justPressed()) {
				_doInput(0, -1);
				break;
			}
		}
		for (key in keysDown) {
			if (key.justPressed()) {
				_doInput(0, 1);
				break;
			}
		}
		for (key in keysLeft) {
			if (key.justPressed()) {
				_doInput( -1, 0);
				break;
			}
		}
		for (key in keysRight) {
			if (key.justPressed()) {
				_doInput(1, 0);
				break;
			}
		}
		for (key in keysClick) {
			if (key.justPressed()) {
				_doClick();
				break;
			}
		}
	}
	
	private function _doClick():Void {
		//get the widget;
		var currWidget:IFlxUIWidget = _widgets[location];
		if (currWidget == null) {
			return;
		}
		
		var fo:FlxObject;
		var widgetPoint:FlxPoint;
		
		//Try to convert to FlxObject if possible
		if (Std.is(currWidget, FlxObject)) {
			fo = cast currWidget;
			//success! Get ScreenXY, to deal with any possible scrolling/camera craziness
			widgetPoint = fo.getScreenXY(FlxPoint.weak(fo.x, fo.y));
		}else {
			//otherwise just make your best guess from current raw position
			widgetPoint = FlxPoint.get(currWidget.x, currWidget.y);
		}
		
		//get center point of object
		widgetPoint.x += currWidget.width / 2;
		widgetPoint.y += currWidget.height / 2;
		
		if(dispatchEvents){
			//dispatch a low-level mouse event to the FlxG.stage object itself
			
			//Force the mouse to this location
			FlxG.mouse.x = widgetPoint.x;
			FlxG.mouse.y = widgetPoint.y;
			
			//REALLY force it to this location
			FlxG.mouse.setGlobalScreenPositionUnsafe(widgetPoint.x, widgetPoint.y);
			
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, widgetPoint.x, widgetPoint.y, FlxG.stage, FlxG.keys.pressed.CONTROL, FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, widgetPoint.x, widgetPoint.y, FlxG.stage, FlxG.keys.pressed.CONTROL, FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, widgetPoint.x, widgetPoint.y, FlxG.stage, FlxG.keys.pressed.CONTROL, FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
			FlxG.stage.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, widgetPoint.x, widgetPoint.y, FlxG.stage, FlxG.keys.pressed.CONTROL, FlxG.keys.pressed.ALT, FlxG.keys.pressed.SHIFT));
		}
		
		if (callback != null) {
			//notify the listener that we just "clicked" the widget
			callback("cursor_click", currWidget);
		}
	}
	
	private function _doInput(X:Int, Y:Int):Void {
		var currWidget:IFlxUIWidget=null;
		
		if (Y == 0) {											//just move back/forth
			//Easy: go to the next index in the array, loop around if needed
			if (location + X < 0) {	
				location = (location + X) + _widgets.length;
			}else if (location + X >= _widgets.length){
				location = (location + X) - _widgets.length;
			}else{
				location = location + X;
			}
			currWidget = _widgets[location];
		}else {													//move UP/DOWN
			//Harder: iterate through array, looking for widget with higher or lower y value
			
			currWidget = _widgets[location];
			var nextWidget:IFlxUIWidget = currWidget;
			
			var done:Bool = false;
			var failsafe:Int = _widgets.length;
			
			//This assumes that the widgets are properly sorted according to X and Y location
			while(!done && failsafe > 0){
				
				//Use local variable because we don't want to hard-set location yet
				var loc:Int = location;
				
				//Loop around if needed
				if (loc + Y < 0) {
					loc = (loc + Y) + _widgets.length;
				}else if (loc + Y >= _widgets.length){
					loc = (loc + Y) - _widgets.length;
				}else {
					loc = loc + Y;
				}
				
				//If y's don't match, this means it's properly higher or lower, because it's sorted that way
				if (nextWidget.y != currWidget.y) {
					location = loc;
					done = true;
				}
				
				//never trust while loops
				failsafe--;
			}
		}
		
		if (callback != null) {
			//notify the listener that the cursor has moved
			callback("cursor_move", currWidget);
		}
	}
	
	private function _updateCursor():Void {
		if (location < 0)
		{
			visible = false;
			return;
		}
		
		visible = true;
		
		var currWidget:IFlxUIWidget = _widgets[location];
		if (currWidget != null) {
			anchor.anchorThing(this, cast currWidget);
		}
	}
}