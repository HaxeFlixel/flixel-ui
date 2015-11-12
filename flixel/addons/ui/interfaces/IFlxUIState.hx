package flixel.addons.ui.interfaces;

/**
 * ...
 * @author 
 */
interface IFlxUIState extends IEventGetter
{
	public function forceFocus(b:Bool, thing:IFlxUIWidget):Void;
	public var tooltips(default, null):FlxUITooltipManager;
	#if !FLX_NO_MOUSE
	public var cursor:FlxUICursor;
	#end
}