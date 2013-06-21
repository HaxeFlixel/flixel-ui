package org.flixel.plugin.leveluplabs;
import flash.events.MouseEvent;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.util.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.util.FlxMath;

/**
 * @author Lars Doucet
 */

class FlxCheckBox extends FlxButtonPlusX
{
	//copy-pasted from FlxButtonPlus since we override the update loop:
	static public inline var NORMAL:Int = 0;
	static public inline var HIGHLIGHT:Int = 1;
	static public inline var PRESSED:Int = 2;
	
	public var checked(get_checked, set_checked):Bool;	
	
	//Set this to false if you just want the checkbox itself to be clickable
	public var textIsClickable:Bool = true;
	
	public function new(X:Int, Y:Int, Callback:Dynamic, Params:Array<Dynamic> = null, Label:String = null, Width:Int = 100, Height:Int = 20)
	{
		_externalCallback = Callback;
		_checkRect = new FlxRect();		
		super(X, Y, _clickCheck, Params, Label, Width, Height);
		buttonNormal.rect.copyTo(_checkRect);
	}
	
	public override function destroy():Void {
		super.destroy();
		_externalCallback = null;
		if (_checkMark != null) {
			_checkMark.destroy();
		}
		_checkRect = null;
		_checkMark = null;
	}
	
	public override function set_text(value:String):String
	{
		super.set_text(value);
		_updateRect();
		return value;
	}
	
	public override function loadGraphic(normal:FlxSprite, highlight:FlxSprite):Void {
		super.loadGraphic(normal, highlight);
		lineUpTextFields();
	}
	
	public function loadCheckGraphic(normal:FlxSprite):Void
	{
		if (_checkMark == null) {
			_checkMark = new FlxSprite();
		}
		_checkMark.pixels = normal.pixels;
	}
	
	public function lineUpTextFields():Void {
		if(textNormal != null){
			textNormal.x = Std.int(buttonNormal.x + buttonNormal.width + 3);
			textNormal.y = Std.int(buttonNormal.y + (buttonNormal.height - textNormal.height) / 2);
			textNormal.x += _textX;
			textNormal.y += _textY;
			if (textHighlight != null) {
				textHighlight.x = textNormal.x;
				textHighlight.y = textNormal.y;
			}
		}		
		_updateRect();
	}
		
	public override function draw():Void {
		super.draw();
		if(_checked){
			_checkMark.draw();
		}
	}
	
	public override function set_x(newX:Int):Int
	{
		_x = newX;
		
		buttonNormal.x = _x;
		buttonHighlight.x = _x;
		
		if (_checkMark != null) {
			_checkMark.x = buttonNormal.x;
		}
		
		lineUpTextFields();
		return newX;
	}
	
	public override function set_y(newY:Int):Int
	{
		_y = newY;
		
		buttonNormal.y = _y;
		buttonHighlight.y = _y;
				
		if (_checkMark != null) {
			_checkMark.y = buttonNormal.y;
		}
		
		lineUpTextFields();
		return newY;
	}
	
	/**
	 * Center this button (on the X axis) Uses FlxG.width / 2 - button width / 2 to achieve this.<br />
	 * Doesn't take into consideration scrolling
	 */
	public override function screenCenter():Void
	{
		buttonNormal.x = (FlxG.width / 2) - (width / 2);
		buttonHighlight.x = (FlxG.width / 2) - (width / 2);
		
		
		if (_checkMark != null) {
			_checkMark.x = buttonNormal.x;
			_checkMark.y = buttonNormal.y;
		}
		
		lineUpTextFields();
	}
	
	/**
	 * Override the basic button logic so we can use a custom bounding rectangle
	 */
	override function updateButton():Void
	{
		if (!textIsClickable) {
			super.updateButton();
		}
		
		var prevStatus:Int = _status;
		
		if (FlxG.mouse.visible)
		{
			if (buttonNormal.cameras == null)
			{
				buttonNormal.cameras = FlxG.cameras;
			}
			
			var c:FlxCamera;
			var i:Int = 0;
			var l:Int = buttonNormal.cameras.length;
			var offAll:Bool = true;
			
			while(i < l)
			{
				c = buttonNormal.cameras[i++];
				
				if (FlxMath.mouseInFlxRect(false, _checkRect))
				{
					offAll = false;
					
					if (FlxG.mouse.justPressed())
					{
						_status = PRESSED;
					}
					
					if (_status == NORMAL)
					{
						_status = HIGHLIGHT;
					}
				}
			}
			
			if (offAll)
			{
				_status = NORMAL;
			}
		}
		
		if (_status != prevStatus)
		{
			if (_status == NORMAL)
			{
				buttonNormal.visible = true;
				buttonHighlight.visible = false;
				
				if (textNormal != null)
				{
					textNormal.visible = true;
					textHighlight.visible = false;
				}
				
				if (leaveCallback != null)
				{
					//leaveCallback.apply(null, leaveCallbackParams);
					Reflect.callMethod(null, leaveCallback, leaveCallbackParams);
				}
			}
			else if (_status == HIGHLIGHT)
			{
				buttonNormal.visible = false;
				buttonHighlight.visible = true;
				
				if (textNormal != null)
				{
					textNormal.visible = false;
					textHighlight.visible = true;
				}
				
				if (enterCallback != null)
				{
					//enterCallback.apply(null, enterCallbackParams);
					Reflect.callMethod(null, enterCallback, enterCallbackParams);
				}
			}
		}
	}
	
	/*****GETTER/SETTER***/
	
	public function get_checked():Bool { return _checked; }
	public function set_checked(b:Bool):Bool { _checked = b; return b; }
	
	/*****PRIVATE******/
	private var _checkMark:FlxSprite;
	private var _checked:Bool;	
	private var _externalCallback:Dynamic;
	private var _checkRect:FlxRect;
	
	private function _updateRect():Void {
		//make the clickable region be the checkbox + the text area
		buttonNormal.rect.copyTo(_checkRect);
		_checkRect.width = textNormal.x + textNormalX.textWidth() - buttonNormal.x;
		var miny:Float = textNormal.y < buttonNormal.y ? textNormal.y : buttonNormal.y;
		var maxy_t:Float = textNormal.y + textNormalX.textHeight();
		var maxy_b:Float = buttonNormal.y + buttonNormal.height;
		var maxy:Float = maxy_t > maxy_b ? maxy_t : maxy_b;
		_checkRect.height = maxy - miny;		
	}
		
	private function _clickCheck(Params:Dynamic = null):Void {
		_checked = !_checked;
		if (_externalCallback == null) {
			return;
		}
		
		var arr:Array<Dynamic>;
		if (Std.is(Params, Array)) {
			arr = cast(Params, Array<Dynamic>);
		}else {
			arr = new Array<Dynamic>();
			arr.push(Params);			
		}
				
		if (_checked) {
			arr.push("checked:true");
		}else {
			arr.push("checked:false");
		}
		_externalCallback(arr);		
	}
	
}