package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;
import flixel.text.FlxText;

/**
 * Simple extension to the basic text field class.
 * @author Lars Doucet
 */
class FlxUIText extends FlxText implements IResizable implements IFlxUIWidget 
{
	public var id:String; 
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
}
