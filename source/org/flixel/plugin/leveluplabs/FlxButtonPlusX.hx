package org.flixel.plugin.leveluplabs;
import nme.events.MouseEvent;
import org.flixel.plugin.photonstorm.FlxButtonPlus;

/**
 * An extension of Photonstorm's FlxButtonPlus, this adds more control over
 * the text labeling
 * @author Lars Doucet
 */

class FlxButtonPlusX extends FlxButtonPlus
{
	
	public var id:String; 
	
	//Get-Set the position of the main text field	
	public var textX(getTextX, setTextX):Int;
	public var textY(getTextY, setTextY):Int;
	
	//Get the internal text fields cast as a FlxTextX - "X" naming convention here is almost
	//certainly confusing and should probably be changed
	public var textNormalX(get_textNormalX, null):FlxTextX;
	public var textHighlightX(get_textHighlightX, null):FlxTextX;
	
	//Simple flags to show/not-show the normal and hilight state
	public var showNormal:Bool = true;
	public var showHilight:Bool = true;
	
	//Set to true to allow clicking old-school flixel button style (ie, don't have to start
	//the click on the button)
	public var easy_click:Bool = true;
	
	static public inline var NORMAL:Int = 0;
	static public inline var HIGHLIGHT:Int = 1;
	static public inline var PRESSED:Int = 2;
	
	public function new(X:Int, Y:Int, Callback:Dynamic, Params:Array<Dynamic> = null, Label:String = "", Width:Int = 100, Height:Int = 20)
	{
		super(X, Y, Callback, Params, Label, Width, Height);		
		
		if (textNormal != null) {
			remove(textNormal, true);
			textNormal = null;
			textNormal = new FlxTextX(X, Y + 3, Width, Label);
			textNormal.setFormat(null, 8, 0xffffff, "center", 0x000000);	
			add(textNormal);
		}
		if (textHighlight != null) {
			remove(textHighlight, true);
			textHighlight = null;
			textHighlight = new FlxTextX(X, Y + 3, Width, Label);
			textHighlight.setFormat(null, 8, 0xffffff, "center", 0x000000);					
			add(textHighlight);
		}
		
		centerLabelY();
	}
	
		/**** Getter/setter functionality: ****/
	
		public function get_textNormalX():FlxTextX{ return cast(textNormal, FlxTextX);}
		public function get_textHighlightX():FlxTextX{ return cast(textHighlight, FlxTextX);}
						
		public function getTextX():Int { return _textX; }
		public function getTextY():Int { return _textY; }
	
		public function setTextX(newX:Int) { _textX = newX; set_x(_x); return newX; }
		public function setTextY(newY:Int) { _textY = newY; set_y(_y); return newY; } 
	
		public override function set_x(newX:Int):Int{
			super.set_x(newX);
			
			if (textNormal != null) 
				textNormal.x += _textX;
			if (textHighlight != null)
				textHighlight.x += _textX;
			
			return newX;
		}
		
		public override function set_y(newY:Int):Int{
			super.set_y(newY);
			
			if (textNormal != null)
				textNormal.y += _textY;
			if (textHighlight != null)
				textHighlight.y += _textY;
				
			return newY;
		}
		
	/****PUBLIC****/
	
	public override function draw():Void {
		var oN:Bool = buttonNormal.visible;
		var oH:Bool = buttonHighlight.visible;
		if (!showNormal) { buttonNormal.visible = false; }
		if (!showHilight) { buttonHighlight.visible = false; }				
		super.draw();
		buttonNormal.visible = oN;
		buttonHighlight.visible = oH;	
	}
	
	
	public function centerLabelY(offsetY:Int = 0)
	{
		setTextY(Std.int((this.height - this.textNormal.frameHeight) / 2) + offsetY);
	}
	
	public function updateLabel(str:String, autoFit:Bool = false) {
		var old_size:Float = textNormal.size;
		
		textNormal.text = str;
		textHighlight.text = str;
		
		if(autoFit){
			var failsafe:Int = 0;			
			while(textNormal.frameWidth > (textNormal.width*0.85) && (failsafe < 99)) {
				if (textNormal.size < 6) {
					failsafe = 99;
					break;
				}
				textNormal.size -= 1;
				textHighlight.size -= 1;
				textNormal.y += 1;
				textHighlight.y += 1;
				
				textY = Std.int(textNormal.y);
				failsafe++;								
			}
		}
	}

	public function updateLabels(str:String,str2:String) {
		textNormal.text = str;
		textHighlight.text = str2;
	}

		
	public function changeText(str:String = "",str2:String="") {
		var ontx:FlxTextX = cast(textHighlight, FlxTextX);
		var offtx:FlxTextX = cast(textNormal, FlxTextX);
		if(ontx != null){

			if (str2 != "") {
				textHighlight.text = str2;
			}else {
				textHighlight.text = str;
			}
		
		}
		
		if(offtx != null){

			if (str != "") {
				textNormal.text = str;
			}
		}
	}
		
	public function changeSimpleLabel(color:Int = 0xffffff, size:Int = 14, str:String = "", bold:Bool = true, shadow:Int = 1,doOffsets:Bool=false,offset:Float=0,offx:Float=0,overColor:Int=0,outline:Bool=false,underline:Bool=false,onstr:String="",aa:Int=2) {
		var ontx:FlxTextX = cast(textHighlight, FlxTextX);
		var offtx:FlxTextX = cast(textNormal, FlxTextX);
		
		if(doOffsets){
			ontx.x = x + -2 + offx;
			ontx.y = y + offset;
			
			if (height > ontx.height) {
				ontx.y += (height - ontx.height) / 4;
			}else {
				ontx.y += (ontx.height - height) / 4;
			}
			
			offtx.x = ontx.x;
			offtx.y = ontx.y;
		}
		
		if (ontx != null) {
			if(aa == 0 || aa != 1 && size < 16){
				ontx.setFormat(U.font("verdana"), size, color, "center", shadow);
			}else {
				ontx.setFormat(U.font("verdana"), size, color, "center", shadow);					
			}
			ontx.bold = bold;
			ontx.dropShadow = (shadow != 0);
			if (onstr != "") {
				textHighlight.text = onstr;
			}else if (str != "") {
				textHighlight.text = str;
			}
		
		}
		
		if(offtx != null){
			if(aa == 0 || aa != 1 && size < 16){
				offtx.setFormat(U.font("verdana"), size, color, "center", shadow);
			}else {
				offtx.setFormat(U.font("Verdana"), size, color, "center", shadow);					
			}
			offtx.bold = bold;
			offtx.dropShadow = (shadow != 0);
			if (str != "") {
				textNormal.text = str;
			}
		}
	}
		
	public function setSimpleLabel(str:String,size:Int=14,color:Int=0xffffff,bold:Bool=true,shadow:Int=1,offset:Float=0,offx:Float=0,overColor:Int=0xffffff,outline:Bool=false,underline:Bool=false,shadow_which:Int=0,new_width:Int=0,align_:String="center",aa:Int=2) {
		
		if (new_width == 0) {
			new_width = width;
		}
		
		//var ft:FlxTextX = new FlxTextX(-2, 0, new_width, str);
		var ft:FlxTextX = cast(textNormal, FlxTextX);
		ft.x = -2;
		ft.y = 0;
		ft.width = new_width;
		ft.text = str;
		if(height > ft.height)
			ft.y += (height - ft.height) / 4;
		else
			ft.y += (ft.height - height) / 4;

		ft.y += offset;
		ft.x += offx;
		
		var shade:Int = shadow;
		if (shadow_which == 2) {
			shade = 0;
		}
		
		if(aa == 0 || aa != 1 && size < 16){
			ft.setFormat(U.font("verdana"), size, color, align_, shade);
		}else {
			ft.setFormat(U.font("Verdana"), size, color, align_, shade);				
		}
			
		ft.bold = bold;
		//ft.underline = underline;
		if (outline) {
			ft.outline = true;
		}else {
			if(shadow_which == 0 || shadow_which == 1){
				ft.dropShadow = (shadow != 0);
			}
		}

		var fto:FlxTextX = cast(textHighlight, FlxTextX);
		fto.x = ft.x;
		fto.y = ft.y;
		fto.width = new_width;
		fto.text = str;
		
		shade = shadow;
		if (shadow_which == 1) {
			shade = 0;
		}				
		
		if(aa == 0 || aa != 1 && size < 16){				
			fto.setFormat(U.font("verdana"), size, overColor, align_, shade);
		}else {
			fto.setFormat(U.font("verdana"), size, overColor, align_, shade);				
		}
		
		fto.bold = bold;
		//fto.underline = underline;
		if(shadow_which ==0 || shadow_which == 2){
			fto.dropShadow = (shadow != 0);
		}
		
		fto.visible = false;
		textX = Std.int(textHighlight.x);
		textY = Std.int(textHighlight.y);
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
	 */
	public override function onMouseUp(MouseEvent):Void
	{
		var click_test:Bool = easy_click ? (_status == PRESSED|| _status == HIGHLIGHT) : (_status == PRESSED);
		
		if (exists && visible && active && click_test && (_onClick != null) && (pauseProof || !FlxG.paused))
		{
			Reflect.callMethod(this, Reflect.getProperty(this, "_onClick"), onClickParams);
		}
	}
	
	/******PRIVATE******/
		
	private var _textX:Int = 0;
	private var _textY:Int = 0;
	
}