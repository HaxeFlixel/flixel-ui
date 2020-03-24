package flixel.addons.ui.interfaces;

interface IFlxUIState extends IEventGetter
{
	public function forceFocus(b:Bool, thing:IFlxUIWidget):Void;
	public var tooltips(default, null):FlxUITooltipManager;
	#if FLX_MOUSE
	public var cursor:FlxUICursor;
	#end
	private var _tongue:IFireTongue;
}
