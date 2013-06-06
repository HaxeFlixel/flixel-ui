package org.flixel.plugin.leveluplabs;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.plugin.leveluplabs.FlxGroupX;
import org.flixel.plugin.leveluplabs.FlxTextX;
import org.flixel.plugin.leveluplabs.U;

/**
 * ...
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */

class BasicPopUp extends FlxGroupX
{
	// Change these variables to modify the popup options text.
	public var STR_YES:String;
	public var STR_NO:String;
	public var STR_OKAY:String;
	public var STR_OK:String;
	public var STR_CANCEL:String;
	public var STR_CONFIRM:String;
	public var STR_ARE_YOU_SURE:String;
	//
	
	var yes_btn:FlxButtonPlusX;
	var no_btn:FlxButtonPlusX;
	var cancel_btn:FlxButtonPlusX;
	
	var titleBox:FlxTextX;
	var descriptionBox:FlxTextX;
	
	var darkness:FlxSprite;
	var hitBox:FlxSprite;
	var hitBox2:FlxSprite;
	
	var _callback:String->Void;
	
	public var WIDTH:Float = 360;
	public var HEIGHT:Float = 175;
	
	var SPACE:Float = 7;
	
	var tabGroup:TabGroup;
	
	var isSetup:Bool = false;	
	
	private var wait_a_sec:Bool = false;
	private var wait_a_sec_time:Float = 0;
	private var WAIT_A_SEC_TIME:Float = 0.25;
		
	public function new(title:String="<confirm>",text:String="<are_you_sure>",Callback:String->Void=null) 
	{
		super();
		STR_YES				= "Yes";
		STR_NO				= "No";
		STR_OKAY			= "Okay";
		STR_OK				= "Ok";
		STR_CANCEL			= "Cancel";
		STR_CONFIRM			= "Confirm";
		STR_ARE_YOU_SURE	= "Are you sure?";
		//setup(title, text, callback);
	}
	
	function setup(title:String="<confirm>",text:String="<are_you_sure>",Callback:String->Void=null) {
		//define per subclass
	}
	
	public override function update() {
		super.update();
		if(active){
			if (wait_a_sec) {
				wait_a_sec_time += FlxG.elapsed;
				if (wait_a_sec_time > WAIT_A_SEC_TIME) {
					wait_a_sec = false;
				}
			}
		}
	}
	
	public override function destroy() {
		super.destroy();
		yes_btn = null;
		no_btn = null;
		cancel_btn = null;
		titleBox = null;
		descriptionBox = null;
		darkness = null;
		hitBox = null;
		hitBox2 = null;
		_callback = null;
	}
	
	public function setDarkAlpha(n:Float) {
		darkness.alpha = n;
	}
	
	public function position(X:Float, Y:Float) {
		//reset(X, Y); // TODO - Possible implement of reset() is needed.
		this.x = X;
		this.y = Y;
		darkness.reset( -X, -Y);
	}
	
	public function positionDark(X:Float, Y:Float) {
		darkness.x = X;
		darkness.y = Y;
	}
	
	public function showButtons(yes:Bool, no:Bool, cancel:Bool) {
		yes_btn.visible = yes;
		no_btn.visible = no;
		cancel_btn.visible = cancel;
		
		yes_btn.active = yes;
		no_btn.active = no;
		cancel_btn.active = cancel;
	}
	
	//override function updateMembers() {
		//if (visible) {
			//super.updateMembers();	//don't do update if I'm not shown!
		//}
	//}
	
	public function updateText(str:String) {
		descriptionBox.text = str;
	}
	
	function doSmallText(isSmall:Bool) {
		
	}
	
	function fixword(str:String):String {
		switch(str) {
			case "<yes>": 			return STR_YES;
			case "<no>": 			return STR_NO;
			case "<okay>": 			return STR_OKAY;
			case "<ok>": 			return STR_OK;
			case "<cancel>": 		return STR_CANCEL;
			case "<confirm>": 		return STR_CONFIRM;
			case "<are_you_sure>": 	return STR_ARE_YOU_SURE;
		}
		return str;
	}
	
	public function show(title:String="<confirm>",text:String="<are_you_sure>",Callback:String->Void=null,yes:Bool=true,no:Bool=true,cancel:Bool=true,yes_str:String="<yes>",no_str:String="<no>",cancel_str:String="<cancel>",bigBox:Bool=false,smallText:Bool=false) {
		title = fixword(title);
		text = fixword(text);			
		yes_str = fixword(yes_str);
		no_str = fixword(no_str);
		cancel_str = fixword(cancel_str);
		
		if (smallText) {
			doSmallText(true);
		}else {				
			doSmallText(false);
		}
		
		yes_btn.text = yes_str;
		no_btn.text = no_str;
		cancel_btn.text = cancel_str;
		titleBox.text = title;
		
		if (bigBox == true) {
			hitBox.visible = false;
		}else {
			hitBox.visible = true;
		}					
		
		if(hitBox2 != null){
			hitBox2.visible = !hitBox.visible;
		}
		
		showButtons(yes, no, cancel);
		
		updateText(text);
		descriptionBox.text = text;
		if(Callback != null){
			_callback = Callback;
		}
		visible = true;
	}
	
	public function hide() {
		visible = false;
		showButtons(false, false, false);
	}
	
	public function forcePush(str:String) {
		switch(str) {
			case "cancel": pressCancel(null);
			case "no": pressNo(null); 
			case "yes": pressYes(null);
		}
	}
	
	function waitASec(){
		wait_a_sec = true;
		wait_a_sec_time = 0;
	}
	
	function pressCancel(b:FlxButtonPlusX = null) {
		if (!active) return;
		if (wait_a_sec) return;
		
		hide();
		waitASec();
		if(_callback != null){
			_callback("cancel");
		}
	}
	
	function pressYes(b:FlxButtonPlusX=null)
	{
		if (!active) return;
		if (wait_a_sec) return;
		
		hide();			
		waitASec();
		_callback("yes");			
	}
	
	function pressNo(b:FlxButtonPlusX = null) {
		if (!active) return;
		if (wait_a_sec) return;
		
		hide();			
		waitASec();
		_callback("no");
	}
		
}