package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IResizable;

/**
 * @author Lars Doucet
 */
class FlxUIInputText extends FlxInputText implements IResizable implements IFlxUIWidget 
{
	public var id:String;
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
}