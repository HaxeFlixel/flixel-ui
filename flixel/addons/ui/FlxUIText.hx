package flixel.addons.ui;

import flixel.addons.ui.FlxUI.UIEventCallback;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;
import flixel.text.FlxText;

/**
 * Simple extension to the basic text field class.
 * @author Lars Doucet
 */
class FlxUIText extends FlxText implements IResizable implements IFlxUIWidget implements IHasParams
{
	public var broadcastToFlxUI:Bool = true;
	
	public var id:String; 
	
	public var params(default, set):Array<Dynamic>;
	
	public function resize(w:Float, h:Float):Void {
		width = w;
		height = h;
		calcFrame();
	}
	
	public function set_params(p:Array<Dynamic>):Array<Dynamic>
	{
		params = p;
		return params;
	}
}
