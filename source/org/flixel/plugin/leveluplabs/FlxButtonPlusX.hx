package org.flixel.plugin.leveluplabs;
import org.flixel.plugin.photonstorm.FlxButtonPlus;

/**
 * An extension of Photonstorm's FlxButtonPlus, this adds more control over
 * the text labeling
 * @author Lars Doucet
 */

class FlxButtonPlusX extends FlxButtonPlus
{
	//Get-Set the position of the main text field	
	public var textX(getTextX, setTextX):Int;
	public var textY(getTextY, setTextY):Int;
	
	//Get the internal text fields cast as a FlxTextX - "X" naming convention here is almost
	//certainly confusing and should probably be changed
	public var textNormalX(get_textNormalX, null):FlxTextX;
	public var textHighlightX(get_textHighlightX, null):FlxTextX;
	
	//Simple flags to show/not-show the normal and hilight state
	public var showNormal:Bool = true;
	public var showHilight:Bool = true;
	
	public function new(X:Int, Y:Int, Callback:Dynamic, Params:Array<Dynamic> = null, Label:String = null, Width:Int = 100, Height:Int = 20)
	{
		super(X, Y, Callback, Params, Label, Width, Height);		
		
		if (textNormal != null) {
			remove(textNormal, true);
			textNormal = null;
			textNormal = new FlxTextX(X, Y + 3, Width, Label);
			textNormal.setFormat(null, 8, 0xffffff, "center", 0x000000);	
			add(textNormal);
		}
		if (textHighlight != null) {
			remove(textHighlight, true);
			textHighlight = null;
			textHighlight = new FlxTextX(X, Y + 3, Width, Label);
			textHighlight.setFormat(null, 8, 0xffffff, "center", 0x000000);					
			add(textHighlight);
		}
	}
	
		/**** Getter/setter functionality: ****/
	
		public function get_textNormalX():FlxTextX{ return cast(textNormal, FlxTextX);}
		public function get_textHighlightX():FlxTextX{ return cast(textHighlight, FlxTextX);}
						
		public function getTextX():Int { return _textX; }
		public function getTextY():Int { return _textY; }
	
		public function setTextX(newX:Int) { _textX = newX; return setX(_x); }
		public function setTextY(newY:Int) { _textY = newY; return setY(_y); } 
	
		public override function setX(newX:Int):Int{
			super.setX(newX);
			textNormal.x += _textX;
			textHighlight.x += _textX;
			return newX;
		}
		
		public override function setY(newY:Int):Int{
			super.setY(newY);
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
	
	/******PRIVATE******/
		
	private var _textX:Int = 0;
	private var _textY:Int = 0;
	
}