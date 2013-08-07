package flixel.addons.ui;
import flash.events.MouseEvent;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxSprite;

/**
 * An extension of Photonstorm's FlxButtonPlus, this adds more control over
 * the text labeling
 * @author Lars Doucet
 */

class FlxButtonPlusX extends FlxButtonPlus implements IResizable
{
	
	public var id:String; 
	
	//Get-Set the position of the main text field	
	public var textX(get_textX, set_textX):Float;
	public var textY(get_textY, set_textY):Float;
	
	//Get the internal text fields cast as a FlxTextX - "X" naming convention here is almost
	//certainly confusing and should probably be changed
	public var textNormalX(get_textNormalX, null):FlxTextX;
	public var textHighlightX(get_textHighlightX, null):FlxTextX;
	
	private var _textNormalX:FlxTextX;
	private var _textHighlightX:FlxTextX;
	
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
			_textNormalX = cast textNormal;
			add(textNormal);
		}
		
		if (textHighlight != null) {
			remove(textHighlight, true);
			textHighlight = null;
			textHighlight = new FlxTextX(X, Y + 3, Width, Label);
			textHighlight.setFormat(null, 8, 0xffffff, "center", 0x000000);					
			_textHighlightX = cast textHighlight;
			add(textHighlight);
		}
		
		centerLabelY();
	}
	
	//For IResizable
	public function get_width():Float { return width; }
	public function get_height():Float { return height; }
	
	public function resize(w:Float, h:Float):Void {
		
		if(_9sliceNormal != null && _9sliceHighlight != null) {
			_9sliceNormal.resize(w, h);
			_9sliceHighlight.resize(w, h);
			loadGraphic(_9sliceNormal, _9sliceHighlight);
		}		
		
		if(textNormalX != null){
			textNormalX.width = w;
			textNormalX.height = h;
		}
		if(textHighlightX != null){
			textHighlightX.width = w;
			textHighlightX.height = h;
		}
	}
	
	public override function destroy():Void {
		_textNormalX = null;
		_textHighlightX = null;
		if (_9sliceNormal != null) {
			_9sliceNormal.destroy();
		}
		if (_9sliceHighlight != null) {
			_9sliceHighlight.destroy();
		}
		_9sliceNormal = null;
		_9sliceHighlight = null;
		super.destroy();
	}
	
		/**** Getter/setter functionality: ****/
	
		public function get_textNormalX():FlxTextX{ return _textNormalX;}
		public function get_textHighlightX():FlxTextX{ return _textHighlightX;}
						
		public function get_textX():Float { return _textX; }
		public function get_textY():Float { return _textY; }
	
		public function set_textX(newX:Float) { _textX = newX; set_x(x); return newX; }
		public function set_textY(newY:Float) { _textY = newY; set_y(y); return newY; } 
	
		public override function set_x(newX:Float):Float{
			super.set_x(newX);
			
			if (textNormal != null) 
				textNormal.x = buttonNormal.x + _textX;
			if (textHighlight != null)
				textHighlight.x = buttonHighlight.x + _textX;
			
			return newX;
		}
		
		public override function set_y(newY:Float):Float{
			super.set_y(newY);
			
			if (textNormal != null)
				textNormal.y = buttonNormal.y + _textY;
			if (textHighlight != null)
				textHighlight.y = buttonHighlight.y + _textY;
				
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
		set_textY(Std.int((this.height - this.textNormal.frameHeight) / 2) + offsetY);
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
		
		// TODO - Get "Verdana" font to work? 
		//if(aa == 0 || aa != 1 && size < 16){
			ft.setFormat(U.font("verdana"), size, color, align_, shade);
		//}else {
			//ft.setFormat(U.font("Verdana"), size, color, align_, shade);				
		//}
			
		ft.bold = bold;
		if (outline) {
			ft.useOutline = true;
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
	 * Helper method to change the button position.
	 * @param	X
	 * @param	Y
	 */
	public function reset(X:Float, Y:Float)
	{
		set_textX(X);
		set_textY(Y);
	}
	
	/**
	 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
	 */
	public override function onMouseUp(MouseEvent):Void
	{
		var click_test:Bool = easy_click ? (_status == PRESSED|| _status == HIGHLIGHT) : (_status == PRESSED);
		
		if (exists && visible && active && click_test && (_onClick != null) && (pauseProof || !FlxG.paused))
		{
			Reflect.callMethod(this, Reflect.getProperty(this, "_onClick"),[_onClickParams]);
		}
	}
	
	public override function loadGraphic(Normal:FlxSprite, Highlight:FlxSprite):Void {
		if (Std.is(Normal, Flx9SliceSprite)){
			_9sliceNormal = cast Normal;
		}
		if (Std.is(Highlight, Flx9SliceSprite)) {
			_9sliceHighlight = cast Highlight;
		}
		super.loadGraphic(Normal, Highlight);
	}
	
	
	/******PRIVATE******/
		
	private var _9sliceNormal:Flx9SliceSprite;
	private var _9sliceHighlight:Flx9SliceSprite;
		
	private var _textX:Float = 0;
	private var _textY:Float = 0;
	
}