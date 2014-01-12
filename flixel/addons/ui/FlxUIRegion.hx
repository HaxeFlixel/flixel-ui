package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

/**
 * A scalable object with width and height that isn't used for display purposes
 * @author 
 */
class FlxUIRegion extends FlxSprite implements IFlxUIWidget implements IResizable
{
	public var id:String;
	
	public function new(X:Float=0,Y:Float=0,W:Float=16,H:Float=16) {
		super(X, Y);
		
		#if debug
			color = FlxRandom.color();
		#end
				
		resize(W, H);
	}
	
	public function resize(w:Float, h:Float) : Void {
		width = w;
		height = h;
		#if debug
			makeGraphic(cast w,cast h);
		#end
	}	 
}