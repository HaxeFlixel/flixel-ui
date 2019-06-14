package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.interfaces.IHasParams;
import flixel.addons.ui.interfaces.IResizable;

/**
 * @author Lars Doucet
 */
class FlxUIInputText extends FlxInputText implements IResizable implements IFlxUIWidget implements IHasParams
{
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	public static inline var CHANGE_EVENT:String = "change_input_text"; // change in any way
	public static inline var ENTER_EVENT:String = "enter_input_text"; // hit enter in this text field
	public static inline var DELETE_EVENT:String = "delete_input_text"; // delete text in this text field
	public static inline var INPUT_EVENT:String = "input_input_text"; // input text in this text field

	public function resize(w:Float, h:Float):Void
	{
		width = w;
		height = h;
		calcFrame();
	}

	private override function onChange(action:String):Void
	{
		super.onChange(action);
		if (broadcastToFlxUI)
		{
			switch (action)
			{
				case FlxInputText.ENTER_ACTION: // press enter
					FlxUI.event(ENTER_EVENT, this, text, params);
				case FlxInputText.DELETE_ACTION, FlxInputText.BACKSPACE_ACTION: // deleted some text
					FlxUI.event(DELETE_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
				case FlxInputText.INPUT_ACTION: // text was input
					FlxUI.event(INPUT_EVENT, this, text, params);
					FlxUI.event(CHANGE_EVENT, this, text, params);
			}
		}
	}
}
