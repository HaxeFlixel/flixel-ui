package org.flixel.plugin.leveluplabs;
import flash.events.MouseEvent;
import org.flixel.plugin.photonstorm.FlxButtonPlus;

/**
 * An extension of Photonstorm's FlxButtonPlus, this adds more control over
 * the text labeling
 * @author Lars Doucet
 */

class FlxButtonPlusX extends FlxButtonPlus
{
	//Get-Set the position of the main text field	
	public var textX(get_textX, set_textX):Int;
	public var textY(get_textY, set_textY):Int;
	
	//Get the internal text fields cast as a FlxTextX - "X" naming convention here is almost
	//certainly confusing and should probably be changed
	public var textNormalX(get_textNormalX, null):FlxTextX;
	public var textHighlightX(get_textHighlightX, null):FlxTextX;
	
	private var _textNormalX:FlxTextX;
	private var _textHighlightX:FlxTextX;
	
	//Simple flags to show/not-show the normal and hilight state
	public var showNormal:Bool = true;
	public var showHilight:Bool = true;
	
	//Set to true to allow clicking old-school flixel button style (ie, don't have to start
	//the click on the button)
	public var easy_click:Bool = true;
	
	static public inline var NORMAL:Int = 0;
	static public inline var HIGHLIGHT:Int = 1;
	static public inline var PRESSED:Int = 2;
	
	public function new(X:Int, Y:Int, Callback:Dynamic, Params:Array<Dynamic> = null, Label:String = null, Width:Int = 100, Height:Int = 20)
	{
		super(X, Y, Callback, Params, Label, Width, Height);		
		
		if (textNormal != null) {
			remove(textNormal, true);
			textNormal = null;
			textNormal = new FlxTextX(X, Y + 3, Width, Label);
			textNormal.setFormat(null, 8, 0xffffff, "center", 0x000000);	
			_textNormalX = cast textNormal;
			add(textNormal);
		}
		if (textHighlight != null) {
			remove(textHighlight, true);
			textHighlight = null;
			textHighlight = new FlxTextX(X, Y + 3, Width, Label);
			textHighlight.setFormat(null, 8, 0xffffff, "center", 0x000000);					
			_textHighlightX = cast textHighlight;
			add(textHighlight);
		}
	}
	
	public override function destroy():Void {
		_textNormalX = null;
		_textHighlightX = null;
		super.destroy();
	}
	
		/**** Getter/setter functionality: ****/
	
		public function get_textNormalX():FlxTextX{ return _textNormalX;}
		public function get_textHighlightX():FlxTextX{ return _textHighlightX;}
						
		public function get_textX():Int { return _textX; }
		public function get_textY():Int { return _textY; }
	
		public function set_textX(newX:Int) { _textX = newX; set_x(_x); return newX; }
		public function set_textY(newY:Int) { _textY = newY; set_y(_y); return newY; } 
	
		public override function set_x(newX:Int):Int{
			super.set_x(newX);
			textNormal.x += _textX;
			textHighlight.x += _textX;
			return newX;
		}
		
		public override function set_y(newY:Int):Int{
			super.set_y(newY);
			textNormal.y += _textY;
			textHighlight.y += _textY;
			return newY;
		}
		
	/****PUBLIC****/
	
	public override function draw():Void {
		var oN:Bool = buttonNormal.visible;
		var oH:Bool = buttonHighlight.visible;
		if (!showNormal) { buttonNormal.visible = false; }
		if (!showHilight) { buttonHighlight.visible = false; }				
		super.draw();
		buttonNormal.visible = oN;
		buttonHighlight.visible = oH;	
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
	 */
	public override function onMouseUp(MouseEvent):Void
	{
		var click_test:Bool = easy_click ? (_status == PRESSED|| _status == HIGHLIGHT) : (_status == PRESSED);
		
		if (exists && visible && active && click_test && (_onClick != null) && (pauseProof || !FlxG.paused))
		{
			Reflect.callMethod(this, Reflect.getProperty(this, "_onClick"),onClickParams);
		}
	}
	
	/******PRIVATE******/
		
	private var _textX:Int = 0;
	private var _textY:Int = 0;
	
}