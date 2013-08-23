package flixel.addons.ui;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class FlxButtonToggle extends FlxGroupX implements IResizable
{
	public var btn_normal(get_btn_normal, null):FlxButtonX;
	public var btn_toggle(get_btn_toggle, null):FlxButtonX;
	
		public function get_btn_normal():FlxButtonX { return _btn_normal;}
		public function get_btn_toggle():FlxButtonX { return _btn_toggle;}
	
		public var Callback(null, set_Callback):Dynamic;
		
		public var id(get_id, set_id):String;
	
		public var toggle(get_toggle, set_toggle):Bool;
		
	public function new(X:Float,Y:Float, Callback:Dynamic, Params:Array<Dynamic>=null, btn_normal_:FlxButtonX, btn_toggle_:FlxButtonX, id_:String="") 
	{
		super();
		_callback = Callback;
		_params = Params;
		_btn_normal = btn_normal_;
		_btn_toggle = btn_toggle_;
		_btn_normal.setOnUpCallback(_onClickNormal, Params);
		_btn_toggle.setOnUpCallback(_onClickToggle, Params);
		add(_btn_normal);
		add(_btn_toggle);		
		instant_update = true;
		x = X;
		y = Y;
		_id = id_;
		_doToggle(false, null);
	}
	
	/**IResizable**/
	
	public function get_width():Float {
		if(_btn_normal != null){
			return _btn_normal.get_width();
		}
		return 0;
	}
	
	public function get_height():Float {
		if(_btn_normal != null){
			return _btn_normal.get_height();
		}
		return 0;
	}
	
	public function resize(W:Float, H:Float):Void {
		if (_btn_normal != null) {
			_btn_normal.resize(W, H);
		}
		if (_btn_toggle != null) {
			_btn_toggle.resize(W, H);
		}
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
	private var _btn_normal:FlxButtonX;
	private var _btn_toggle:FlxButtonX;
	
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