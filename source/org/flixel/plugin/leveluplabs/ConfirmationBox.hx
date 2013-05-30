package org.flixel.plugin.leveluplabs;

/**
 * ...
 * @author TiagoLr (~~~ ProG4mr ~~~)
 */
/**
* This object handles the confirmation box for generic cases
* @author Lars Doucet
* 
* Usage : create one of these, and then add it at the top of your depth stack.
* 
* In the New ConfirmationBox() call, pass in a callback
* call show() with the the parameters you want to customize it
* When a selection is made it will call callback with "yes" "no" or "cancel"
*/
class ConfirmationBox extends BasicPopUp
{
	private var textEntry:FlxTextEdit;
	private var radioChoices:FlxRadioGroup;
		
	public function new(title:String="<confirm>",text:String="<are_you_sure>",Callback:String->Void=null)
	{
		super(title, text, Callback);
		setup(title, text, Callback);				
	}
		
	public function showRadioChoices(arr:Array<String>,title:String = "<confirm>", text:String = "<are_you_sure>", Callback:String->Void = null, yes:Bool = true, no:Bool = true, cancel:Bool = true, yes_str:String = "<yes>", no_str:String = "<no>", cancel_str:String = "<cancel>") {
		title = fixword(title);
		text = fixword(text);
		yes_str = fixword(yes_str);
		no_str = fixword(no_str);
		cancel_str = fixword(cancel_str);
		
		show(title, text, Callback, yes, no, cancel, yes_str, no_str, cancel_str);
		if (radioChoices == null) {
			radioChoices = new FlxRadioGroup(hitBox2.x + (hitBox2.width-200)/2, hitBox2.y + 70, arr, null, 20, 200);
			radioChoices.selectedIndex = 0;
			add(radioChoices);
		}else {
			radioChoices.updateRadios(arr,arr);
		}
		
		// TODO - possible need to fix radioChoices position.
		/*if (arr.length <= 2) {
			radioChoices.reset(radioChoices.x, hitBox2.y + 80);
		}else if (arr.length == 3) {
			radioChoices.reset(radioChoices.x, hitBox2.y + 70);
		}else if (arr.length == 4) {
			radioChoices.reset(radioChoices.x, hitBox2.y + 60);
		}*/
		
		radioChoices.active = true;
		radioChoices.visible = true;
	}
	
	override function doSmallText(isSmall:Bool){
		if(isSmall){
			descriptionBox.setFormat(U.font("verdana"), 11, 0x000000, "center");
			descriptionBox.bold = false;
		}else {
			descriptionBox.setFormat(U.font("verdana"), 14, 0x000000, "center");
			descriptionBox.bold = true;
		}			
	}		
	
	
	public function showTextEntry(title:String="<confirm>",text:String="<are_you_sure>", Callback:String->Void=null,yes:Bool=true,no:Bool=true,cancel:Bool=true,yes_str:String="<yes>",no_str:String="<no>",cancel_str:String="<cancel>",default_txt:String="",numbers:Bool=false)  {
		
		title = fixword(title);
		text = fixword(text);
		yes_str = fixword(yes_str);
		no_str = fixword(no_str);
		cancel_str = fixword(cancel_str);
		
		show(title, text, Callback, yes, no, cancel, yes_str, no_str, cancel_str);
		
		if (textEntry == null) {
			textEntry = new FlxTextEdit(hitBox2.x + 20, hitBox2.y + 90, Std.int(hitBox2.width - 40), null, true, onTextEdit, false);
			textEntry.setFormat(U.font("verdana"), 20, 0x000000, "center");
			textEntry.bold = true;
			textEntry.setMaxChars(20);				
			if(numbers){
				textEntry.setAlphaNumeric();
			}
			textEntry.forceUnderscore = true;
			textEntry.text = "TEST";
			add(textEntry);
		}
		
		textEntry.active = true;
		textEntry.visible = true;
		textEntry.text = default_txt;
		//textEntry.
	}
		
	override function pressYes(b:FlxButtonPlusX=null)
	{
		if (!active) return;
		
		var text:String;
		
		if (textEntry != null && textEntry.active && textEntry.visible) {
			text = textEntry.text;
			hide();
			//_callback("yes", text);	
			_callback("yes"); // TODO - possible need implement callback second argument.
			return;
		}
		
		if (radioChoices != null && radioChoices.active && radioChoices.visible) {
			//text = radioChoices.selected_code; // TODO
			hide();
			//_callback("yes", text);
			_callback("yes"); // TODO - possible need implement callback second argument.
			return;
		}
		
		hide();			
		_callback("yes"); // TODO
	}
	
	private function onTextEdit(text:String) {
		//trace("text = " + text);
	}
	
	override function showButtons(yes:Bool, no:Bool, cancel:Bool):Void {
		if (textEntry != null) {
			textEntry.visible = false;
			textEntry.active = false;
		}
		
		if (radioChoices != null) {
			radioChoices.visible = false;
			radioChoices.active = false;
		}
		
		yes_btn.visible = yes;
		no_btn.visible = no;
		cancel_btn.visible = cancel;
		
		yes_btn.active = yes;
		no_btn.active = no;
		cancel_btn.active = cancel;
		
		
			//yes_btn.reset(x + 10, y + 147); 
		if (yes_btn.visible && cancel_btn.visible && no_btn.visible) {
			yes_btn.x = Std.int(x + 10);
			yes_btn.y = Std.int(y + 10);
			//cancel_btn.reset(x + 225, y + 147);
			cancel_btn.x = Std.int(x + 225);
			cancel_btn.y = Std.int(y + 147);
		}else if (yes_btn.visible && cancel_btn.visible && !no_btn.visible) {
			//yes_btn.reset(x + 10, y + 147);
			yes_btn.x = Std.int(x + 10);
			yes_btn.y = Std.int(y + 147);
			
			//cancel_btn.reset(x + 225, y + 147);
			cancel_btn.x = Std.int(x + 225);
			cancel_btn.y = Std.int(y + 147);
		}
		
		if (hitBox2.visible) {
			//yes_btn.reset(yes_btn.x, y + 274);
			yes_btn.y = Std.int(y + 274);
			
			//no_btn.reset(no_btn.x, y + 274);
			no_btn.y = Std.int(y + 274);
			
			//cancel_btn.reset(cancel_btn.x, y + 274);
			cancel_btn.y = Std.int(y + 274);
		}
		
		if(hitBox.visible){			
			descriptionBox.y = (y + 35) + (90 - descriptionBox.textHeight()) / 2;		
		}else if (hitBox2.visible) {
			descriptionBox.y = (y + 35) + (230 - descriptionBox.textHeight()) / 2;
		}
	}
	
	public override function updateText(str:String) {
		descriptionBox.text = str;
		
		var textHeight:Float = descriptionBox.textHeight();
		
		if(hitBox.visible){			
			descriptionBox.y = (y + 35) + (90 - textHeight) / 2;		
		}else if (hitBox2.visible) {
			descriptionBox.y = (y + 35) + (230 - textHeight) / 2;
		}
	}
	
	override function setup(title:String="<confirm>",text:String="<are_you_sure>", Callback:String->Void=null) {
		
		WIDTH = 360;
		HEIGHT = 175;
		SPACE = 7;
		
		_callback = Callback;			
		
		title = fixword(title);
		text = fixword(text);
		
		yes_btn = new FlxButtonPlusX(35, 147, pressYes);
		yes_btn.loadGraphic(new FlxSprite(0, 0, U.gfx("button_confirmation_up", "ui", "buttons")), new FlxSprite(0, 0, U.gfx("button_confirmation_over", "ui", "buttons")));
		yes_btn.setSimpleLabel(STR_YES);
		//yes_btn.text = STR_YES;
		//fb.textNormalX.setFormat(the_font, size, color, align, shadow);
		//fb.textNormalX.dropShadow = true;
		
		no_btn = new FlxButtonPlusX(118, 147, pressNo);
		no_btn.loadGraphic(new FlxSprite(0, 0, U.gfx("button_confirmation_red_up", "ui", "buttons")), new FlxSprite(0, 0, U.gfx("button_confirmation_red_over", "ui", "buttons")));
		no_btn.setSimpleLabel(STR_NO);
		//no_btn.text = STR_NO;

		cancel_btn = new FlxButtonPlusX(200, 147, pressCancel);
		cancel_btn.loadGraphic(new FlxSprite(0, 0, U.gfx("button_confirmation_red_up", "ui", "buttons")), new FlxSprite(0, 0, U.gfx("button_confirmation_red_over", "ui", "buttons")));
		cancel_btn.setSimpleLabel(STR_CANCEL);
		//cancel_btn.text = STR_CANCEL;
		
		titleBox = new FlxTextX(0, 10, 350, title);
		titleBox.setFormat(U.font("verdana"), 18, 0xffffff, "center");
		titleBox.bold = true;
		//titleBox.aa = false;
		titleBox.shadow = 1;
		titleBox.dropShadow = true;
		
		descriptionBox = new FlxTextX(25, 35, 315, text);
		descriptionBox.setFormat(U.font("verdana"), 14,0x000000,"center");
		descriptionBox.bold = true;
		
		darkness = new FlxSprite(0, 0);
		darkness.makeGraphic(800, 600, 0x88000000);
		add(darkness);
		
		hitBox = new FlxSprite(0, 0, U.gfx("confirmation_box","ui"));
		add(hitBox);
		
		hitBox2 = new FlxSprite(0, 0, U.gfx("newchar_menu_back","ui"));
		add(hitBox2);
		
		hitBox2.visible = false;
		
		add(yes_btn);
		add(no_btn);
		add(cancel_btn);
		
		add(titleBox);
		add(descriptionBox);
		hide();
		
		tabGroup = new TabGroup();
		add(tabGroup);
		
		tabGroup.add(yes_btn);
		tabGroup.add(no_btn);
		tabGroup.add(cancel_btn);
	}
		
}