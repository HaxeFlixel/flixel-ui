package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;

class FlxUIPopup extends FlxUISubState implements IFlxUIWidget
{
	public var name:String;

	public var broadcastToFlxUI:Bool = true;

	/**STUBS TO MAKE THE INTERFACE HAPPY:**/
	public var immovable(default, set):Bool;

	private function set_immovable(Immovable:Bool):Bool
	{
		return immovable;
	}

	public var angle(default, set):Float;
	public var facing(default, set):FlxDirectionFlags;
	public var moves(default, set):Bool;
	public var offset(default, set):FlxPoint;
	public var origin(default, set):FlxPoint;
	public var scale(default, set):FlxPoint;
	public var velocity:FlxPoint;
	public var maxVelocity:FlxPoint;
	public var acceleration:FlxPoint;
	public var drag:FlxPoint;
	public var scrollFactor(default, set):FlxPoint;

	private function set_x(Value:Float):Float
	{
		return x = Value;
	}

	private function set_y(Value:Float):Float
	{
		return y = Value;
	}

	private function get_width():Float
	{
		return _width;
	}

	private function get_height():Float
	{
		return _height;
	}

	private function set_width(Value:Float):Float
	{
		return _width = Value;
	}

	private function set_height(Value:Float):Float
	{
		return _height = Value;
	}

	private function set_angle(Value:Float):Float
	{
		return angle = Value;
	}

	private function set_alpha(Value:Float):Float
	{
		return alpha = Value;
	}

	private function set_facing(Value:Int):Int
	{
		return facing = Value;
	}

	private function set_moves(Value:Bool):Bool
	{
		return moves = Value;
	}

	private function set_offset(Value:FlxPoint):FlxPoint
	{
		return offset = Value;
	}

	private function set_origin(Value:FlxPoint):FlxPoint
	{
		return origin = Value;
	}

	private function set_scale(Value:FlxPoint):FlxPoint
	{
		return scale = Value;
	}

	private function set_scrollFactor(Value:FlxPoint):FlxPoint
	{
		return scrollFactor = Value;
	}

	public function reset(X:Float, Y:Float):Void
	{
		setPosition(X, Y);
	}

	public function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	public var params:Array<Dynamic> = null;

	public var alpha(default, set):Float = 1;

	public var width(get, set):Float;
	public var height(get, set):Float;

	private var _width:Float = 0;
	private var _height:Float = 0;

	public static inline var CLICK_EVENT:String = "click_popup";

	/**************************************/
	public override function create():Void
	{
		if (_xml_id == "")
		{
			_xml_id = FlxUIAssets.XML_DEFAULT_POPUP_ID;
		}

		scrollFactor = FlxPoint.get(0, 0);
		getTextFallback = myGetTextFallback;

		super.create();

		if (_quickSetupParams != null)
		{
			_doQuickSetup();
		}

		scrollFactor.set(0, 0);
		_ui.setScrollFactor(0, 0);
	}

	/**
	 * Assuming you use the default format, puts this information in the popup.
	 * This function ONLY works if you are using the default_popup.xml, OR your
	 * custom xml contains the following assets:
	 		 * 2 texts, ids: "title","body"
	 		 * 3 buttons, ids: "btn0","btn1","btn2"
	 		 * 3 modes, ids: "1btn","2btn","3btn"
	 * @param	title title text
	 * @param	body body text
	 * @param	button_labels up to three button labels - if fewer, shows less buttons
	 */
	public function quickSetup(title:String, body:String, button_labels:Array<String>):Void
	{
		/* if this sub state isn't active yet, it just stores the params and then
		 * does the real work as soon as it's created.
		 * So call this, then activate it!
		 */

		_quickSetupParams = {title: title, body: body, button_labels: button_labels};
	}

	public override function getEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?eventParams:Array<Dynamic>):Void
	{
		if (eventParams == null)
		{
			if (params != null)
			{
				eventParams = [];
			}
		}
		if (params != null)
		{
			eventParams = eventParams.concat(params);
		}

		switch (id)
		{
			case FlxUITypedButton.CLICK_EVENT:
				var str = "";
				if (eventParams != null)
				{
					if ((eventParams[0] is String))
					{
						str = Std.string(eventParams[0]);
					}

					var buttonAmount:Int = Std.int(eventParams[0]);
					if (str == "affirm" || str == "cancel" || str == "alt")
					{
						if ((_parentState is IFlxUIState))
						{
							// This fixes a bug where the event was being sent to this popup rather than the state that created it
							castParent().getEvent(CLICK_EVENT, this, buttonAmount, eventParams);
						}
						else
						{
							// This is a generic fallback in case something goes wrong
							FlxUI.event(CLICK_EVENT, this, buttonAmount, eventParams);
						}
						close();
					}
				}
		}
		super.getEvent(id, sender, data, eventParams);
	}

	private function castParent():IFlxUIState
	{
		return cast _parentState;
	}

	private var _quickSetupParams:{title:String, body:String, button_labels:Array<String>} = null;

	// This function is passed into the UI object as a default in case the user is not using FireTongue

	private function myGetTextFallback(flag:String, context:String = "ui", safe:Bool = true):String
	{
		switch (flag)
		{
			case "$POPUP_YES":
				return "Yes";
			case "$POPUP_NO":
				return "No";
			case "$POPUP_OK":
				return "Ok";
			case "$POPUP_CANCEL":
				return "Cancel";
			case "$POPUP_TITLE_DEFAULT":
				return "Alert!";
			case "$POPUP_BODY_DEFAULT":
				return
					"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam consectetur vehicula pellentesque. Phasellus at blandit augue. Suspendisse vel leo ut elit imperdiet eleifend ut quis purus. Quisque imperdiet turpis vitae justo hendrerit molestie. Quisque tempor ante eget posuere viverra.";
		}
		return flag;
	}

	private function _doQuickSetup():Void
	{
		if (_ui.hasAsset("title"))
		{
			var text_title:FlxUIText = cast _ui.getAsset("title");
			text_title.text = _quickSetupParams.title;
		}
		if (_ui.hasAsset("body"))
		{
			var text_body:FlxUIText = cast _ui.getAsset("body");
			text_body.text = _quickSetupParams.body;
		}

		_doQuickSetupButtons();

		// cleanup
		_quickSetupParams.button_labels = null;
		_quickSetupParams = null;
	}

	private function _doQuickSetupButtons():Void
	{
		var arr:Array<String> = ["btn0", "btn1", "btn2"];
		var i:Int = 0;

		switch (_quickSetupParams.button_labels.length)
		{
			case 1:
				_ui.setMode("1btn");
			case 2:
				_ui.setMode("2btn");
			case 3:
				_ui.setMode("3btn");
		}

		for (btn in arr)
		{
			var the_btn:IFlxUIButton;
			if (_ui.hasAsset(btn))
			{
				the_btn = cast _ui.getAsset(btn);
				if (_quickSetupParams.button_labels.length > i)
				{
					var btnlabel:String = _quickSetupParams.button_labels[i];
					var newlabel:String = btnlabel;

					// localize common flags:
					switch (btnlabel)
					{
						case "<yes>", "<no>", "<cancel>":
							btnlabel = btnlabel.substr(1, btnlabel.length - 2).toUpperCase(); // carve off the "<>", so "yes", "no", etc
							newlabel = "$POPUP_" + btnlabel; // make it "$POPUP_YES", "$POPUP_NO", etc
							newlabel = _ui.getText(newlabel, "ui", false); // localize it
							if (newlabel == null || newlabel == "")
							{ // if failed
								newlabel = btnlabel;
							}
							btnlabel = newlabel;
					}

					U.setButtonLabel(the_btn, newlabel);
				}
			}
			i++;
		}
	}
}
