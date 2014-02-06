package flixel.addons.ui;
import flixel.addons.ui.FlxUI.NamedFloat;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxStringUtil;

/**
 * ...
 * @author 
 */
class FlxUINumericStepper extends FlxUIGroup implements IFlxUIWidget implements IHasParams
{

	private var button_plus:FlxUITypedButton<FlxSprite>;
	private var button_minus:FlxUITypedButton<FlxSprite>;
	private var text_field:FlxText;
	
	public var stepSize:Float=0;
	public var decimals(default, set):Int=0;			//Number of decimals
	public var min(default, set):Float=0;
	public var max(default, set):Float=10;
	public var value(default, set):Float=0;
	public var stack(default, set):Int = STACK_HORIZONTAL;
	
	public static inline var STACK_VERTICAL:Int = 0;
	public static inline var STACK_HORIZONTAL:Int = 1;
	
	public static inline var CLICK_EVENT:String = "click_numeric_stepper";		//click a numeric stepper button
	public static inline var EDIT_EVENT:String = "edit_numeric_stepper";		//edit the numeric stepper text field
	public static inline var CHANGE_EVENT:String = "change_numeric_stepper";	//do either of the above
	
	public var params(default, set):Array<Dynamic>;
	public function set_params(p:Array <Dynamic>):Array<Dynamic>{
		params = p;
		return params;
	}
	
	public function set_min(f:Float):Float {
		min = f; 
		if (value < min) { value = min; }
		return min;
	}
	
	public function set_max(f:Float):Float {
		max = f; 
		if (value > max) { value = max; }
		return max;
	}
	
	public function set_value(f:Float):Float {
		value = f;
		if (value < min) { value = min; }
		if (value > max) { value = max; }
		if (text_field != null) {
			text_field.text = decimalize(value, decimals);
		}
		return value;
	}
	
	public function set_decimals(i:Int):Int {
		decimals = i;
		if (i < 0) { decimals = 0;}
		value = value;
		return decimals;
	}
	
	public function set_stack(s:Int):Int {
		stack = s;
		var btnSize:Int = 10;
		var offsetX:Int = 0;
		var offsetY:Int = 0;
		if (Std.is(text_field, FlxUIInputText)) {
			offsetX = 1;
			offsetY = 1;	//border for input text
		}
		switch(stack) {
			case STACK_HORIZONTAL:
				btnSize = 2 + cast text_field.height;
				if (button_plus.height != btnSize) {
					button_plus.resize(btnSize, btnSize);
				}
				if (button_minus.height != btnSize) {
					button_minus.resize(btnSize, btnSize);
				}				
				button_plus.x =  offsetX + text_field.x + text_field.width;
				button_plus.y = -offsetY + text_field.y;
				button_minus.x = button_plus.x+button_plus.width;
				button_minus.y = button_plus.y;
			case STACK_VERTICAL:
				btnSize = 1 + cast text_field.height / 2;
				if (button_plus.height != btnSize) {
					button_plus.resize(btnSize, btnSize);
				}
				if (button_minus.height != btnSize) {
					button_minus.resize(btnSize, btnSize);
				}
				button_plus.x =  offsetX + text_field.x + text_field.width;
				button_plus.y = -offsetY + text_field.y;
				button_minus.x = offsetX + text_field.x + text_field.width;
				button_minus.y = offsetY + text_field.y + (text_field.height - button_minus.height);
		}
		return stack;
	}
	
	private inline function decimalize(f:Float,digits:Int):String {
		var tens:Float = Math.pow(10, digits);
		return Std.string(Math.round(f * tens) / tens);
	}
	
	/**
	 * This creates a new dropdown menu.
	 * 
	 * @param	X					x position of the dropdown menu
	 * @param	Y					y position of the dropdown menu
	 * @param	StepSize			How big is the step
	 * @param	DefaultValue		Optional default numerical value for the stepper to display
	 * @param	Min					Optional Minimum values for the stepper
	 * @param	Max					Optional Maximum and Minimum values for the stepper
	 * @param	Decimals			Optional # of decimal places
	 * @param	Stack				Stacking method
	 * @param	TextField			Optional text field
	 * @param	ButtonPlus			Optional button to use for plus
	 * @param	ButtonMinus			Optional button to use for minus
	 */
	public function new(X:Float = 0, Y:Float = 0, StepSize:Float=1, DefaultValue:Float=0, Min:Float=-999, Max:Float=999, Decimals:Int=0, Stack:Int=STACK_HORIZONTAL, ?TextField:FlxText, ?ButtonPlus:FlxUITypedButton<FlxSprite>, ?ButtonMinus:FlxUITypedButton<FlxSprite>) 
	{
		super(X, Y);
		
		if (TextField == null) {
			TextField = new FlxUIInputText(0, 0, 25);
		}
		TextField.x = 0;
		TextField.y = 0;
		text_field = TextField;
		text_field.text = Std.string(DefaultValue);
		if (Std.is(text_field,FlxUIInputText)) {
			var fuit:FlxUIInputText = cast text_field;
			fuit.lines = 1;
			fuit.uiEventCallback = _onInputTextEvent;
		}
		
		stepSize = StepSize;
		decimals = Decimals;
		min = Min;
		max = Max;
		value = DefaultValue;
		
		var btnSize:Int = 1 + cast TextField.height;
		
		if (ButtonPlus == null) {
			ButtonPlus = new FlxUITypedButton<FlxSprite>(0, 0);
			ButtonPlus.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], btnSize, btnSize, [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_THIN)], FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
			ButtonPlus.label = new FlxSprite(0, 0, FlxUIAssets.IMG_PLUS);
		}
		if (ButtonMinus == null) {
			ButtonMinus = new FlxUITypedButton<FlxSprite>(0, 0);
			ButtonMinus.loadGraphicSlice9([FlxUIAssets.IMG_BUTTON_THIN], btnSize, btnSize, [FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_BUTTON_THIN)], FlxUI9SliceSprite.TILE_NONE, -1, false, FlxUIAssets.IMG_BUTTON_SIZE, FlxUIAssets.IMG_BUTTON_SIZE);
			ButtonMinus.label = new FlxSprite(0, 0, FlxUIAssets.IMG_MINUS);
		}
		
		button_plus = ButtonPlus;
		button_minus = ButtonMinus;
		
		add(text_field);
		add(button_plus);
		add(button_minus);
		
		button_plus.onUp.callback = _onPlus;
		button_minus.onUp.callback = _onMinus; 
		
		stack = Stack;
	}
	
	private function _onInputTextEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void {
		var text:String = cast data;
		if (text == "") 
		{
			text = Std.string(min);
		}
		value = Std.parseInt(text);
		_doCallback(EDIT_EVENT);
		_doCallback(CHANGE_EVENT);
	}
	
	private function _onPlus():Void {
		value += stepSize; 
		_doCallback(CLICK_EVENT);
		_doCallback(CHANGE_EVENT);
	}
	
	private function _onMinus():Void {
		value -= stepSize;
		_doCallback(CLICK_EVENT);
		_doCallback(CHANGE_EVENT);
	}
	
	private function _doCallback(event:String):Void{
		if (uiEventCallback != null) {
			uiEventCallback(event, this, value, params);
		}
	}
}