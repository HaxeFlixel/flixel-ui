package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;

/**
 * A scalable object with width and height that isn't used for display purposes
 */
class FlxUIRegion extends FlxSprite implements IFlxUIWidget implements IResizable
{
	public var broadcastToFlxUI:Bool=true;
	
	public var id:String;
	
	public function new(X:Float=0,Y:Float=0,W:Float=16,H:Float=16) {
		super(X, Y);
		
		resize(W, H);
	}
	
	public override function destroy():Void {
		super.destroy();
	}
	
	public function resize(w:Float, h:Float) : Void {
		width = w;
		height = h;
	}	 
}