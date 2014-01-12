package flixel.addons.ui;

import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;

/**
 * @author Lars Doucet
 */
class FlxUICheckBox extends FlxUIGroup implements ILabeled implements IFlxUIButton
{
	public var box:FlxSprite;
	public var mark:FlxSprite;
	public var button:FlxUIButton;
	public var max_width:Float = -1;
	
	public var checked(get_checked, set_checked):Bool;
	
	//Set this to false if you just want the checkbox itself to be clickable
	public var textIsClickable:Bool = true;
		
	public var checkbox_dirty:Bool = false;
	
	public var textX(default, set):Float;
	public var textY(default, set):Float;
	
	public var box_space:Float = 2;
	
	public var skipButtonUpdate(default,set):Bool = false;
	
	public function set_skipButtonUpdate(b:Bool):Bool {
		skipButtonUpdate = b;
		button.skipButtonUpdate = skipButtonUpdate;
		return skipButtonUpdate;
	}
	
	public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, LabelW:Int=100, ?OnClick:Dynamic, ?params:Array<Dynamic>)
	{
		super();
		
		box = new FlxSprite();
		if (Box == null) {
			//if null create a simple checkbox outline
			Box = FlxUIAssets.IMG_CHECK_BOX;
		}
		
		box.loadGraphic(Box, true, false);
		
		button = new FlxUIButton(0, 0, Label, _clickCheck);
		
		//set default checkbox label format
		button.label.setFormat(null, 8, 0xffffff, "left", FlxText.BORDER_OUTLINE);
		button.up_color = 0xffffff;
		button.down_color = 0xffffff;
		button.over_color = 0xffffff;
		button.up_toggle_color = 0xffffff;
		button.down_toggle_color = 0xffffff;
		button.over_toggle_color = 0xffffff;
		
		//TODO:
		//the +2 is a magic number, possibly should be a user-set parameter
		button.loadGraphicSlice9(["", "", ""], Std.int(box.width + 2 + LabelW), cast box.height);
		
		max_width = Std.int(box.width + box_space + LabelW);
		
		setExternalCallback(OnClick);
		button.onUp.setCallback(_clickCheck, [params]);    //for internal use, check/uncheck box, bubbles up to _externalCallback
				
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
		
		checked = false;
		
		//set all these to 0
		button.labelOffsets[FlxButton.NORMAL].x = 0;
		button.labelOffsets[FlxButton.NORMAL].y = 0;
		button.labelOffsets[FlxButton.PRESSED].x = 0;
		button.labelOffsets[FlxButton.PRESSED].y = 0;
		button.labelOffsets[FlxButton.HIGHLIGHT].x = 0;
		button.labelOffsets[FlxButton.HIGHLIGHT].y = 0;
		
		x = X;
		y = Y;
		
		textX = 0;
		textY = 0;	//forces anchorLabel() to be called and upate correctly
	}
	
	/**For ILabeled:**/
	
	public function set_label(t:FlxUIText):FlxUIText { if (button == null) { return null;} button.label = t; return button.label; }
	public function get_label():FlxUIText { if (button == null) { return null;} return button.label; }
	
	/**/
	
	private override function set_visible(Value:Bool):Bool
	{
		//don't cascade to my members
		visible = Value;
		return visible;
	}
	
	private function anchorTime(f:FlxTimer):Void {
		anchorLabelY();
	}
	
	public function set_textX(n:Float):Float {
		textX = n;
		anchorLabelX();
		return textX;
	}
	
	public function set_textY(n:Float):Float {
		textY = n;
		anchorLabelY();
		return textY;
	}
	
	public function setExternalCallback(callBack:Dynamic):Void {
		_externalCallback = callBack;
	}
	
	public function anchorLabelX():Void {
		if (button != null) {
			button.allLabelOffset.x = (box.width + box_space) + textX;
		}
	}
	
	public function anchorLabelY():Void{
		if (button != null) {
			button.y = box.y + (box.height - button.height) / 2 + textY;
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
		checkbox_dirty = true;
		return value;
	}
	
	public override function update():Void{
		super.update();
		
		if (checkbox_dirty) {
			if (button.label != null) {
				if (Std.is(button.label, FlxUIText)) {
					var ftu:FlxUIText = cast button.label;
					ftu.drawFrame(); //force update
				}
				anchorLabelX();
				anchorLabelY();
				button.width = box.frameWidth + button.label.textField.textWidth + (button.label.x - (button.x + box.frameWidth));
				checkbox_dirty = false;
			}
		}
	}
		
	/*****GETTER/SETTER***/
	
	public function get_checked():Bool { 
		return _checked; 
	}
	
	public function set_checked(b:Bool):Bool { 
		_checked = b; 
		mark.visible = b; 
		return b; 
	}
	
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
			arr = U.copy_shallow_arr(arr);
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