package org.flixel.plugin.leveluplabs;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFieldType;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.plugin.leveluplabs.FlxTextX;
import org.flixel.plugin.leveluplabs.U;

/**
 * ...
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
class FlxTextEdit extends FlxGroup
{
	private var _text:FlxTextX;
	public var text(get_text, set_text):String;
	private var _tf:TextField;
	private var butt:FlxButton;
	public var _focus:Bool = false;
	private var caret:FlxSprite;
	private var _flashrect:Rectangle;
	private var _blinkTime:Float;
	private static inline var _BLINK_TIME:Float = 0.75;
	private var _blink:Bool = false;
	private var _needsFocus:Bool = false;
	private var caret_index:Int;
	
	private var alpha:Array<String>;
	private var alphanum:Array<String>;
	
	public var bold(default, set_bold):Bool;
	
	private var letter_set:Array<String>;
	
	private var _maxChars:Int = -1;

	
	private var _callback:String->Void;
	
	public var forceUnderscore:Bool = false;
		
	public override function destroy() {			
		super.destroy();
		_text = null;
		_tf = null;
		butt = null;
		caret = null;
		_flashrect = null;
		U.clearArray(alpha);
		U.clearArray(alphanum);
		_callback = null;
	}
		
		
	public function new(X:Float, Y:Float, Width:Int, Text:String=null, EmbeddedFont:Bool=true, callback_:String->Void=null, needsFocus_:Bool=false)
	{
		alpha = ["SPACE","A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
		alphanum = ["SPACE", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "ZERO"];
		
		_text = new FlxTextX(X, Y, Width, Text, EmbeddedFont);
		butt = new FlxButton(X, Y, onClick);
		
		add(butt);
		add(_text);
		
		_tf = _text.getTextField();
		
		_tf.selectable = true;
		_tf.type = TextFieldType.INPUT;
		
		caret = new FlxSprite(0, 0);
		
		//caret.createGraphic(2, text.height * .8, text.color);
		caret.visible = false;
		add(caret);
		
		_callback = callback_;
		
		_needsFocus = needsFocus_;
		
		_focus = !_needsFocus;
		
		setAlpha();
		
		refresh();			
		
		super();
	}
	
	//public function get_rect():FlxRect {
		//return new FlxRect(x, y, width, height);
	//}
	
	public function setAlpha() {
		//letter_set_= alpha;
		// TODO - setApha()
	}
	
	public function setAlphaNumeric() {
		//letter_set_= alphanum;
		// TODO - setAlphaNum()
	}
	
	public function set_letters(v:Array<String>) {
		//letter_set_= v;
		// TODO - setLetters()
	}

	public function set_text(str:String) {
		_text.text = str;
		if(_focus){
			updateCaret( -2);
		}
		return str;
	}
	
	public function get_text():String {
		return _text.text;
	}
	
	public function set_needsFocus(b:Bool) {
		_needsFocus = b;
		_focus = !_needsFocus;
	}
	
	public function get_needsFocus():Bool{
		return _needsFocus;
	}
	
	public function setMaxChars(i:Int) {
		_maxChars = i;
	}
	
	public function refresh() {
		var fs:FlxSprite = new FlxSprite(0, 0);
		var fso:FlxSprite = new FlxSprite(0, 0);
	
		fs.makeGraphic(Std.int(_text.width), Std.int(_text.height), 0xff999999);
		fso.makeGraphic(Std.int(_text.width), Std.int(_text.height), 0xffffffff);
	
		butt.x = _text.x;
		butt.y = _text.y;
		//butt.loadGraphic(fs, fso);
		butt.loadGraphic(fs);
		
		var col:Int = 0xff000000 + _text.color;
		caret.makeGraphic(4, Std.int(_text.height * 0.65), 0xff000000);
		caret.pixels.fillRect(new Rectangle(1, 1, 2, caret.height - 2), col);
	}
		
	public function setFormat(Font:String=null,Size:Float=8,Color:Int=0xffffff,Alignment:String=null,ShadowColor:Int=0):FlxTextEdit{
		_text.setFormat(Font, Size, Color, Alignment, ShadowColor);
		refresh();
		return this;
	}
	
	public function set_bold(b:Bool) {
		_text.bold = b;
		bold = b;
		refresh();
		return b;
	}
	
	public function set_dropShadow(b:Bool) {
		_text.dropShadow = b;
		refresh();
	}
	
	public function set_outline(b:Bool) {
		_text.outline = b;
		refresh();
	}
		
	private function onClick() {
		_blink = false;
		_blinkTime = 0;
		var xx:Float = FlxG.mouse.x - _text.x;
		var yy:Float = FlxG.mouse.y - _text.y;
		var i:Int = _tf.getCharIndexAtPoint(xx, yy);
		var max_x :Float = 0;
		
		if(_text.text.length > 0){
			var last_rect:Rectangle= _tf.getCharBoundaries(_tf.length - 1);	
			max_x = last_rect.x + last_rect.width;
		}
		
		if (i == -1) {
			if (xx < max_x - 10) {
				i = -1;
			}else if (xx >= max_x) {
				i = -2;
			}
		}
		updateCaret(i);
	}
	
	private function updateCaret(i:Int) {
		_blinkTime = 0;
		_blink = false;
		if (i >= _tf.length) {
			i = -2;
		}
		caret_index = i;
		trace("char = [" + i + "]");
		_focus = true;
		refresh();
		caret.visible = true;
		var max_x:Float = 0;
		
		
		var last_rect:Rectangle= _tf.getCharBoundaries(_tf.length - 1);
		if(last_rect != null){
			max_x = last_rect.x + last_rect.width;
		}
		
		if (_text.text.length == 0) {
			_text.text = "*";
			last_rect = _tf.getCharBoundaries(0);
			caret.x = _text.x + last_rect.x;
			caret.y = _text.y + last_rect.y + last_rect.height - caret.height;
			_text.text = "";
			return;
		}
		
		
		_flashrect = _tf.getCharBoundaries(i);
		
		var _y:Float = caret.y;
		
		if(_flashrect != null){
			caret.x = _text.x + _flashrect.x;
			trace("rect = " + _flashrect);
			_y = _text.y + _flashrect.y + _flashrect.height - caret.height;
		}else {
			if (i == -1) {
				_flashrect = _tf.getCharBoundaries(0);
				if(_flashrect != null){
					caret.x = _text.x + _flashrect.x;
					_y = _text.y + _flashrect.y + _flashrect.height - caret.height;
				}else {
					
				}
			}else if (i == -2) {
				caret.x = _text.x + max_x;
				if(last_rect != null){
					_y = _text.y + last_rect.y + last_rect.height - caret.height;
				}
			}
		}
		caret.y = _y - 2;
		caret.x -= 1;
	}
		
	public override function update() {
		if (FlxG.mouse.justPressed()) {
			if(_needsFocus){
				_focus = false;
			}
		}
		
		_blinkTime += FlxG.elapsed;
		if (_blinkTime >= _BLINK_TIME) {
			_blinkTime -= _BLINK_TIME;
			_blink = !_blink;
		}
		
		if (_focus) {
			updateKeys();
		}
		
		super.update();
		
	}
		
	private function updateKeys() {
		var changed:Bool = false;
		var str_a:String;
		var str_b:String;
		var i:Int = 0;
		if (FlxG.keys.justPressed("BACKSPACE")) {
			if (caret_index > 0 || caret_index == -2) {
				if (caret_index == -2) {
					str_a = _text.text.substr(0, _text.text.length - 1);
					str_b = "";
				}else{
					str_a = _text.text.substr(0, caret_index-1);
					str_b = _text.text.substr(caret_index, _text.text.length - 1);
				}
				_text.text = str_a + str_b;
				changed = true;
				if (caret_index != -2) {
					caret_index--;
				}else {
					//caret_index = text.text.length - 1;
				}
				//trace("caret = " + caret_index + " text = " + _text.text);
				
			}
			updateCaret(caret_index);
		}else if (FlxG.keys.justPressed("DELETE")) {
			var ci:Int = caret_index;
			if (caret_index != -2) {
				if (ci == -1) {
					ci = 0;
				}
				str_a = _text.text.substr(0,ci);
				str_b = _text.text.substr(ci+1, _text.text.length - 1);
				_text.text = str_a + str_b;
				changed = true;

				trace("caret = " + caret_index + " text = " + _text.text);
			}
			updateCaret(caret_index);
		}else if (FlxG.keys.justPressed("LEFT")) {
			if (caret_index > 0) {
				caret_index--;
			}else if (caret_index == -2) {
				caret_index = _text.text.length - 1;
			}		
			updateCaret(caret_index);
			
		}else if (FlxG.keys.justPressed("RIGHT")) {
			if (caret_index != -2) {
				caret_index++;
			}
			
			if (caret_index >= _text.text.length) {
				caret_index = -2;
			}
			updateCaret(caret_index);
		}else {
			var letter:String = checkLetterKeys();
			var isCaps:Bool=true;
			/*if (FlxG.keys.CAPSLOCK) {
				if (FlxG.keys.SHIFT) { 
					isCaps = false; 
				}else { 
					isCaps = true 
				}
			}else {
				if (FlxG.keys.SHIFT) {
					isCaps = true;
				}else {
					isCaps = false;
				}
			}*/
			
			if (letter != "") {
				if (letter == "SPACE" || letter == "SP") {
					if (!forceUnderscore) {
						letter = " ";
					}else {
						letter = "_";
					}
				}
				if(_text.text.length < _maxChars){
					if (!isCaps) {
						letter = letter.toLowerCase();
					}
					if (caret_index == -2) {
						i = _text.text.length;
					}else{ 
						i = caret_index;
						
					}
					str_a = _text.text.substr(0, i);
					str_b = _text.text.substr(i, _text.text.length - i);
					_text.text = str_a + letter + str_b;
					changed = true;
					if (caret_index != -2) {
						caret_index ++;
					}
					updateCaret(caret_index);
				}
			}
		}
		
		if(changed){
			if(_callback != null){
				_callback(_text.text);
			}						
		}
	}
		
	private function checkLetterKeys():String {
		if(_text.text.length < _maxChars){
			for (s in letter_set) {
				if (FlxG.keys.justPressed(s)) {
					return U.getShortTextFromFlxKeyText(s);
				}
			}
		}
		return "";
	}
		
	// TODO - Possible need for method render();
	/*public override function render() {
		_text.render();
		if(!_blink && _focus){
			caret.render();
		}
		//don't render anything but the text!
	}*/
	
}