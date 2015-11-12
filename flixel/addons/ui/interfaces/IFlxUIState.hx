package flixel.addons.ui.interfaces;

/**
 * ...
 * @author 
 */
interface IFlxUIState extends IEventGetter
{
	public function forceFocus(b:Bool, thing:IFlxUIWidget):Void;
	public var tooltips(default, null):FlxUITooltipManager;
	public var cursor:FlxUICursor;
}