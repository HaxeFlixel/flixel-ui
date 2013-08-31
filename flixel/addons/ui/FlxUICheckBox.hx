package flixel.addons.ui;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxRect;
import flixel.util.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import openfl.Assets;

/**
 * @author Lars Doucet
 */

class FlxUICheckBox extends FlxUIGroup implements ILabeled
{
	public var box:FlxSprite;
	public var mark:FlxSprite;
	public var button:FlxUIButton;	
	public var max_width:Float = -1;
	
	public var checked(get_checked, set_checked):Bool;	
	
	//Set this to false if you just want the checkbox itself to be clickable
	public var textIsClickable:Bool = true;
		
	public var dirty:Bool = false;
	
	public var textX(get, set):Float;
	public var textY(get, set):Float;
	
	public var box_space:Float = 2;
	
	private var _textX:Float = 0;
	private var _textY:Float = 0;	
	
	public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, LabelW:Int=100, ?OnClick:Dynamic, ?params:Array<Dynamic>)
	{		
		x = 0;
		y = 0;
		super();
		
		box = new FlxSprite();
		if (Box == null) {
			//if null create a simple checkbox outline
			Box = FlxUIAssets.IMG_CHECK_BOX;
		}
		
		box.loadGraphic(Box, true, false);
		
		button = new FlxUIButton(0, 0, Label, _clickCheck);
		
		//set default checkbox label format
		button.label.setFormat(null, 8, 0xffffff, "left", 1, true);
		
		//TODO:
		//the +2 is a magic number, possibly should be a user-set parameter
		button.loadGraphicSlice9(["", "", ""], Std.int(box.width + 2 + LabelW), cast box.height);
		
		max_width = Std.int(box.width + box_space + LabelW);
		
		setExternalCallback(OnClick);
		button.setOnUpCallback(_clickCheck, [params]);    //for internal use, check/uncheck box, bubbles up to _externalCallback
				
		mark = new FlxSprite();		
		if (Check == null) {
			//if null load from default assets:
			Check = FlxUIAssets.IMG_CHECK_MARK;
		}		
		
		mark.loadGraphic(Check);				
		
		add(box);
		add(mark);
		add(button);
		
		anchorLabelX();
		anchorLabelY();
		
		//FlxTimer.start(0.001, anchorTime);
		
		checked = false; 		
		button.depressOnClick = false;
		
		x = X;
		y = Y;
	}
	
	/**For ILabeled:**/
	
	public function set_label(t:FlxUIText):FlxUIText { if (button == null) { return null;} button.label = t; return button.label; }
	public function get_label():FlxUIText { if (button == null) { return null;} return button.label; }
	
	/**/
	
	private function anchorTime(f:FlxTimer):Void {
		trace("ANCHOR TIME");
		anchorLabelY();
	}
	
	public function get_textX():Float { return _textX;}
	public function set_textX(n:Float):Float {
		_textX = n;
		anchorLabelX();
		return _textX;
	}
	
	public function get_textY():Float { return _textY;}
	public function set_textY(n:Float):Float {
		_textY = n;
		anchorLabelY();					
		return _textY;
	}	
	
	public function setExternalCallback(callBack:Dynamic):Void {
		_externalCallback = callBack;
	}
	
	public function anchorLabelX():Void {
		if (button != null) {
			button.labelOffset.x = (box.width + box_space) + _textX;		
		}			
	}
	
	public function anchorLabelY():Void{
		if (button != null) {			
			button.y = box.y + (box.height - button.height) / 2;
			button.labelOffset.y = (button.height-button.label.textHeight())/2 + _textY;
		}
	}
	
	public override function destroy():Void 
	{
		super.destroy();
		_externalCallback = null;
		if (mark != null) {
			mark.destroy();
			mark= null;
		}
		if (box != null) {
			box.destroy();
			box = null;
		}
		if (button != null) {
			button.destroy();
			button = null;
		}
	}
	
	public var text(get, set):String;
	public function get_text():String { return button.label.text;}
	public function set_text(value:String):String
	{
		button.label.text = value;
		dirty = true;
		return value;
	}
			
	public override function update():Void{
		super.update();
		
		if (dirty) {			
			if (button.label != null) {
				anchorLabelX();
				anchorLabelY();
				button.mouse_width = button.label.textWidth() + button.labelOffset.x;
				dirty = false;
			}
		}
	}
		
	/*****GETTER/SETTER***/
	
	public function get_checked():Bool { return _checked; }
	public function set_checked(b:Bool):Bool { _checked = b; mark.visible = b; return b; }
	
	/*****PRIVATE******/
	
	private var _checked:Bool;	
	private var _externalCallback:Dynamic;
			
	private function _clickCheck(Params:Dynamic = null):Void 
	{
		checked = !checked;
		if (_externalCallback == null) {
			return;
		}
		
		var arr:Array<Dynamic>;
		if (Std.is(Params, Array)) {
			arr = cast(Params, Array<Dynamic>);
		}else {
			arr = new Array<Dynamic>();
			arr.push(Params);						
		}
				
		if (_checked) {
			arr.push("checked:true");
		}else {
			arr.push("checked:false");
		}
		_externalCallback(arr);		
	}
	
}