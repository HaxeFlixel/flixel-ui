package flixel.addons.ui;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class FlxButtonToggle extends FlxGroupX
{
	public var btn_normal(get_btn_normal, null):FlxButtonPlusX;
	public var btn_toggle(get_btn_toggle, null):FlxButtonPlusX;
	
		public function get_btn_normal():FlxButtonPlusX { return _btn_normal;}
		public function get_btn_toggle():FlxButtonPlusX { return _btn_toggle;}
	
		public var Callback(null, set_Callback):Dynamic;
		
		public var id(get_id, set_id):String;
	
		public var toggle(get_toggle, set_toggle):Bool;
		
	public function new(X:Float,Y:Float, Callback:Dynamic, Params:Array<Dynamic>=null, btn_normal_:FlxButtonPlusX, btn_toggle_:FlxButtonPlusX, id_:String="") 
	{
		super();
		_callback = Callback;
		_params = Params;
		_btn_normal = btn_normal_;
		_btn_toggle = btn_toggle_;
		_btn_normal.setOnClickCallback(_onClickNormal, Params);
		_btn_toggle.setOnClickCallback(_onClickToggle, Params);
		add(_btn_normal);
		add(_btn_toggle);		
		instant_update = true;
		x = X;
		y = Y;
		_id = id_;
		_doToggle(false, null);
	}
	
	public override function destroy():Void {
		super.destroy();
		_btn_normal = null;
		_btn_toggle = null;
		_callback = null;
		U.clearArray(_params);
	}
		
	public override function update():Void {
		super.update();
		_ignore_clicks_this_frame = false;
	}
	
	public function set_toggle(value:Bool):Bool {
		return forceToggle(value);
	}
	
	public function forceToggle(value:Bool):Bool{
		_toggle = value;
		_btn_normal.visible = !_toggle;
		_btn_toggle.visible = _toggle;
		return _toggle;
	}
		
	/***GETTERS/SETTERS***/
	
	public function set_Callback(d:Dynamic):Dynamic {
		_callback = d;
		return _callback;
	}
	
	public function get_id():String { return _id; }
	public function set_id(str:String):String { _id = str; return _id;}
	
	public function get_toggle():Bool { return _toggle; }
	
	/***PRIVATE***/
	private var _btn_normal:FlxButtonPlusX;
	private var _btn_toggle:FlxButtonPlusX;
	
	private var _callback:Dynamic;
	private var _params:Array<Dynamic>;
	
	private var _toggle:Bool = false;
	private var _ignore_clicks_this_frame:Bool = false;
		
	private var _id:String = "";
	
	private function _onClickNormal(Params:Dynamic = null):Void {
		if(_btn_normal.visible){
			_doToggle(true, Params);
		}
	}
	
	private function _onClickToggle(Params:Dynamic = null):Void {
		if(_btn_toggle.visible){
			_doToggle(false, Params);
		}
	}
	
	private function _doToggle(value:Bool, Params:Dynamic = null):Void {
		if (_ignore_clicks_this_frame) {			
			FlxG.log.add("...ignore clicks");
			return;
		}
		
		_toggle = value;
		
		_btn_normal.visible = !_toggle;
		_btn_toggle.visible = _toggle;
				
		if (_callback == null) {
			FlxG.log.add("...null callback");
			return;
		}
		
		var arr;
		if (Params != null) { 
			arr = [].concat(Params);
		}else { 
			arr = new Array<Dynamic>(); 
		}
				
		if (_id != "") {
			arr.push(_id);
		}
		
		if (_toggle) {
			arr.push("toggle:true");
		}else {
			arr.push("toggle:false");
		}
		
		FlxG.log.add("...arr=" + arr);
		
		_callback(arr);
		_ignore_clicks_this_frame = true;
	}
}