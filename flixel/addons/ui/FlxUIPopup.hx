package flixel.addons.ui;
import flixel.util.FlxPoint;

/**
 * ...
 * @author 
 */
class FlxUIPopup extends FlxUISubState implements IFlxUIWidget 
{	
	public var id:String;
	
	/**STUBS TO MAKE THE INTERFACE HAPPY:
	 * 
	 * Note from Sam:
	 * This is quite a lot of maintenance code, this class should probably inherit from FlxSpriteGroup somehow.
	 * Maybe need to create new FlxState class that derives from FlxSpriteGroup, maybe FlxUIState?
	 */
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var width(default, set):Float;
	public var height(default, set):Float;
	public var alpha(default, set):Float;
	public var angle(default, set):Float;
	public var facing(default, set):Int;
	public var moves(default, set):Bool;
	public var immovable(default, set):Bool;
	public var offset(default, set):IFlxPoint;
	public var origin(default, set):IFlxPoint;
	public var scale(default, set):IFlxPoint;
	public var velocity(default, set):IFlxPoint;
	public var maxVelocity(default, set):IFlxPoint;
	public var acceleration(default, set):IFlxPoint;
	public var drag(default, set):IFlxPoint;
	public var scrollFactor(default, set):IFlxPoint;
	public function set_x(Value:Float):Float { return x = Value; }
	public function set_y(Value:Float):Float { return y = Value; }
	public function set_width(Value:Float):Float { return width = Value; }
	public function set_height(Value:Float):Float { return height = Value; }
	public function set_angle(Value:Float):Float { return angle = Value; }
	public function set_alpha(Value:Float):Float { return alpha = Value; }
	public function set_facing(Value:Int):Int { return facing = Value; }
	public function set_moves(Value:Bool):Bool { return moves = Value; }
	public function set_immovable(Value:Bool):Bool { return immovable = Value; }
	private function set_offset(Value:IFlxPoint):IFlxPoint { return offset = Value; }
	private function set_origin(Value:IFlxPoint):IFlxPoint { return origin = Value; }
	private function set_scale(Value:IFlxPoint):IFlxPoint { return scale = Value; }
	private function set_velocity(Value:IFlxPoint):IFlxPoint { return velocity = Value; }
	private function set_acceleration(Value:IFlxPoint):IFlxPoint { return acceleration = Value; }
	private function set_drag(Value:IFlxPoint):IFlxPoint { return drag = Value; }
	private function set_maxVelocity(Value:IFlxPoint):IFlxPoint { return maxVelocity = Value; }
	private function set_scrollFactor(Value:IFlxPoint):IFlxPoint { return scrollFactor = Value; }
	public function reset(X:Float, Y:Float):Void { setPosition(X, Y); }
	public function setPosition(X:Float = 0, Y:Float = 0):Void { x = X; y = Y; }
	
	/**************************************/
	
	public override function create():Void {
		if(_xml_id == ""){
			_xml_id = FlxUIAssets.XML_DEFAULT_POPUP_ID;
		}
		
		getTextFallback = myGetTextFallback;
		
		super.create();
		_created = true;
	
		if (_quickSetupParams != null) {
			_quickSetup();
		}
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
	
	public function quickSetup(title:String, body:String, button_labels:Array<String>):Void {
		/* if this sub state isn't active yet, it just stores the params and then
		 * does the real work as soon as it's created.
		 */
		
		_quickSetupParams = { title:title, body:body, button_labels:button_labels };
		if (_created) {		//if it already is created it runs immediately
			_quickSetup();
		}
	}	
	 
	public override function eventResponse(id:String, sender:Dynamic, data:Array<Dynamic>):Void {
		switch(id) {
			case "click_button":
				var i:Int = cast data[0];
				var label:String = cast data[1];
				switch(i) {
					case 0, 1, 2:   castParent().getEvent("click_popup", this, data);
									close();
				}
		}
		super.eventResponse(id, sender, data);				
	}
	
	private var _quickSetupParams:{title:String, body:String, button_labels:Array<String>} = null;
	private var _created:Bool = false;
	
	//This function is passed into the UI object as a default in case the user is not using FireTongue
	
	private function myGetTextFallback(flag:String, context:String = "ui", safe:Bool = true):String {
		switch(flag) {
			case "$POPUP_YES": return "Yes";
			case "$POPUP_NO": return "No";
			case "$POPUP_OK": return "Ok";
			case "$POPUP_CANCEL": return "Cancel";
			case "$POPUP_TITLE_DEFAULT": return "Alert!";
			case "$POPUP_BODY_DEFAULT": return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam consectetur vehicula pellentesque. Phasellus at blandit augue. Suspendisse vel leo ut elit imperdiet eleifend ut quis purus. Quisque imperdiet turpis vitae justo hendrerit molestie. Quisque tempor ante eget posuere viverra.";
		}	
		return flag;
	}
	
	
	private function _quickSetup():Void {
		
		if (_ui.hasAsset("title")) {
			var text_title:FlxUIText = cast _ui.getAsset("title");
			text_title.text = _quickSetupParams.title;
		}
		if (_ui.hasAsset("body")) {
			var text_body:FlxUIText = cast _ui.getAsset("body");
			text_body.text = _quickSetupParams.body;
		}
		
		var arr:Array<String> = ["btn0", "btn1", "btn2"];
		var i:Int = 0;
		
		switch(_quickSetupParams.button_labels.length) {
			case 1: _ui.setMode("1btn");
			case 2: _ui.setMode("2btn");
			case 3: _ui.setMode("3btn");
		}
		
		for (btn in arr) {
			var the_btn:FlxUIButton;
			if (_ui.hasAsset(btn)) {
				the_btn = cast _ui.getAsset(btn);
				if (_quickSetupParams.button_labels.length > i) {
					var btnlabel:String = _quickSetupParams.button_labels[i];
					var newlabel:String = btnlabel;
					
					//localize common flags:
					switch(btnlabel) {
						case "<yes>", "<no>", "<cancel>": btnlabel = btnlabel.substr(1, btnlabel.length - 2).toUpperCase();	//carve off the "<>", so "yes", "no", etc
														  newlabel = "$POPUP_" + btnlabel;									//make it "$POPUP_YES", "$POPUP_NO", etc
														  newlabel = _ui.getText(newlabel, "ui", false);					//localize it														  
														  if (newlabel == null || newlabel == "") {		//if failed
															newlabel = btnlabel;
														  }
														  btnlabel = newlabel;
					}					
					
					the_btn.label.text = newlabel;
				}
			}
			i++;
		}
		
		//cleanup
		_quickSetupParams.button_labels = null;
		_quickSetupParams = null;
	}
	
	
}