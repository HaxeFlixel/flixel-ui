package flixel.addons.ui;

import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIPopup;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITypedButton.FlxUITypedButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxG;
import flixel.util.FlxTimer;

/**
 * A simple loading screen -- you must drive the churning of tasks externally
 *
 * @author larsiusprime
 */
class FlxUILoadingScreen extends FlxUIPopup
{
	public static inline var PROGRESS:String = "loading_screen_progress"; // whenever the bar updates
	public static inline var FINISHED:String = "loading_screen_finished"; // whenever the bar has reached 100%
	public static inline var CANCELLED:String = "loading_screen_cancelled"; // user clicks "cancel"
	public static inline var ACCEPTED:String = "loading_screen_accepted"; // user clicks "okay" after progress is complete

	public var invisibleTime:Float = 0; // if I have been alive less time than this, I am invisible

	public var body(get, set):String;

	private function get_body():String
	{
		if (_body != null)
		{
			return _body.text;
		}
		return _body_temp_txt;
	}

	private function set_body(str:String):String
	{
		if (_body != null)
		{
			_body.text = str;
		}
		_body_temp_txt = str;
		return _body_temp_txt;
	}

	public var title(get, set):String;

	private function get_title():String
	{
		if (_title != null)
		{
			return _title.text;
		}
		return _title_temp_txt;
	}

	private function set_title(str:String):String
	{
		if (_title != null)
		{
			_title.text = str;
		}
		_title_temp_txt = str;
		return _title_temp_txt;
	}

	public var canCancel(default, set):Bool;

	private function set_canCancel(b:Bool):Bool
	{
		canCancel = b;
		if (_ui != null)
		{
			if (canCancel)
			{
				_ui.setMode("can_cancel");
			}
			else
			{
				_ui.setMode("no_cancel");
			}
		}
		return canCancel;
	}

	public var progress(get, set):Float;

	private function get_progress():Float
	{
		return _progress;
	}

	private function set_progress(f:Float):Float
	{
		if (f < 0)
		{
			f = 0;
		}
		if (f > 1)
		{
			f = 1;
		}
		_progress = f;
		if (_bar != null && _bar_back != null)
		{
			var w:Int = Std.int(f * _bar_back.width);
			if (w < 3)
			{
				w = 3;
				_bar.visible = false;
			}
			else
			{
				_bar.visible = true;
			}
			_bar.resize(w, _bar.height);
			_bar.x = Std.int(_bar_back.x);
		}
		return _progress;
	}

	public function set(progress_:Float, ?body_:String, ?title_:String, ?canCancel_:Bool = false)
	{
		canCancel = canCancel_;
		progress = progress_;
		if (body_ != null)
		{
			body = body_;
		}
		if (title_ != null)
		{
			title = title_;
		}
	}

	public override function create():Void
	{
		if (_xml_id == "")
		{
			_xml_id = FlxUIAssets.XML_DEFAULT_LOADING_SCREEN_ID;
		}

		getTextFallback = myGetTextFallback;

		super.create();

		_bar = cast _ui.getAsset("bar");
		_bar_back = cast _ui.getAsset("bar_back");
		_title = cast _ui.getAsset("title");
		_body = cast _ui.getAsset("body");

		if (_quickSetupParams != null)
		{
			_doQuickSetup();
		}

		canCancel = canCancel; // refresh this
		progress = _progress;
		title = _title_temp_txt;
		body = _body_temp_txt;
	}

	public override function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		switch (name)
		{
			case FlxUITypedButton.CLICK_EVENT:
				var btnName:String = cast data;
				if (btnName == "ok")
				{
					castParent().getEvent(ACCEPTED, this, null);
					close();
				}
				else if (btnName == "cancel")
				{
					if (_currTimer != null)
					{
						_currTimer.cancel();
						_currTimer = null;
					}
					castParent().getEvent(CANCELLED, this, null);
					close();
				}
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (invisibleTime != 0)
		{
			_timeSpentAlive += FlxG.elapsed;
			if (_timeSpentAlive < invisibleTime)
			{
				visible = false;
			}
			else
			{
				visible = true;
			}
		}
	}

	private override function myGetTextFallback(flag:String, context:String = "ui", safe:Bool = true):String
	{
		switch (flag)
		{
			case "$LOADING_TITLE":
				return "Loading";
			case "$LOADING_BODY":
				return "Please Wait...";
		}
		return super.myGetTextFallback(flag, context, safe);
	}

	private override function _doQuickSetupButtons():Void
	{
		// override super behavior and do nothing
	}

	private var _timeSpentAlive:Float = 0;
	private var _currTimer:FlxTimer;
	private var _task:Void->Float = null;
	private var _sleepTime:Float = 0;
	private var _closeOnFinished:Bool = true;

	private var _progress:Float = 0;
	private var _bar:FlxUI9SliceSprite;
	private var _bar_back:FlxUI9SliceSprite;
	private var _title:FlxUIText;
	private var _body:FlxUIText;

	// used if "body" and "title" vars are set before create() is called
	private var _body_temp_txt:String = "$LOADING_BODY";
	private var _title_temp_txt:String = "$LOADING_TITLE";
}
