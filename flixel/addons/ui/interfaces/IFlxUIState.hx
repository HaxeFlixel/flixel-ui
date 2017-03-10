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
	public function setUIVariable(key:String, value:String):Void;
	
	private var _tongue:IFireTongue;
	private var _ui:FlxUI;
	private var _ui_vars:Map<String, String>;
}