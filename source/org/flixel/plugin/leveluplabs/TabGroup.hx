package org.flixel.plugin.leveluplabs;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import nme.Lib;
import org.flixel.FlxBasic;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.plugin.leveluplabs.FlxGroupX;
/**
* ...
* @author 
*/
class TabGroup extends FlxGroupX
{
	private var curr_index:Int = 0;
	private var curr_sub_index:Int = 0;
	private var multi_object:Bool = false;
	
	public static var tab_key:String = "TAB";
	public static var back_key:String = "BACKSPACE";
	
	private var failsafe:Int = 0; 
	private var MAX_FAILSAFE:Int = 200;
	
	private var failsafe_tripped:Bool = true;
	
	public var checkBounds:Bool = true;
	public var checkRect:FlxRect;
	
	public var checkOverTab:Bool = false;

	public function new() 
	{
		super();			
	}
		
	public function purgeAll() {
		var i:Int = members.length - 1;
		while (i >= 0) {
			var o:FlxBasic = members[0];
			
			remove(o, true);
			if (Std.is(o,FlxGroupX)) {
				var fgx:FlxGroupX = cast( o , FlxGroupX);
				if (fgx.str_id == "tab_temp_group") {
					var j:Int = fgx.members.length - 1;
					while (j >= 0) {
						var oo:FlxBasic = fgx.members[j];
						fgx.remove(oo, true); 
						j--;
					}
					fgx.destroy();
				}
			}
			i--;
		}
	}
		
	public function purgeNull() {
		for (o in members) {
			if (o == null) {
				remove(o, true);
			}
		}
	}
			
	public override function destroy() {
		active = false;
		visible = false;
		purgeAll();
		checkRect = null;
		super.destroy();
	}
		
	public function addNoSort(o:FlxObject) {
		for (oo in members) {
			if (o == oo) {
				return;	//can't add an object more than once
			}
		}
		if (o == null) {
			return;
		}
		members.push(o);
		//super.add(o);
	}
	
	//override function updateMembers() {
		//do nothing
		
	//}
	
	//public override function reset(X:Float, Y:Float) {
		//do nothing
	//}
		
		
	public function addArray(a:Array<Dynamic>, doSort:Bool = true, asGroup:Bool = false, overTab:Bool = false) {
		if (asGroup) {
			var g:FlxGroupX = new FlxGroupX();
			//g.overTab = overTab; // TODO - ADD OVERTAB PROPERTY.
			g.str_id = "tab_temp_group";
			if (doSort) {
				a.sort(sortXY);
			}
			for (o in a) {
				g.add(o);
			}
			
			if(doSort){
				add(g);
				return;
			}else {
				addNoSort(cast(g,FlxObject));
				return;
			}
		}
		
		for (o in a) {
			if (doSort) {
				add(o);
			}else {
				addNoSort(o);
			}
		}
	}
	
	public function removeArray(a:Array<Dynamic>) {
		for (o in a) {
			remove(o,true);
		}
	}
		
	public override function add(o:FlxBasic):FlxBasic {
		
		for (oo in members) {
			if (o == oo) {
				return null;	//can't add an object more than once
			}
		}
		if (o == null) {
			return null;
		}
		//o = super.add(o);
		members.push(o);
		members.sort(sortXY);
		return o;
	}
		
	public function set_active_members(b:Bool) {
		active = b;
	}
	
	public override function update() {
		//super.update();
		if (!visible || !active) {
			return;
		}
		
		if(!failsafe_tripped){
			if (FlxG.keys.justPressed(tab_key)) {
				tabCycle(1);
			}else if (FlxG.keys.justPressed(back_key)) {
				tabCycle( -1);
			}
			failsafe = 0;
		}else {
			failsafe--;
			if (failsafe <= 0) {
				failsafe = 0;
				failsafe_tripped = false;
			}
		}
	}
	//do nothing
	//public override function render() {
	//}
		
	private function isLegalMultiType(o:FlxBasic):Bool {
		if (Std.is(o,FlxButton)) return true;
		//if (Std.is(o ,LevelUpGem_Big)) return true; 	// TODO - import LevelUpGem_Big
		//if (Std.is(o ,CheckMark)) return true;		// TODO - import CheckMark
		//if (Std.is(o ,FlxTextEdit)) return true;		// TODO - import FlxTextEdit
		//if (Std.is(o ,UI_Merchandise)) return true;	// TODO - import UI_Merchandise
		return false;
	}
		
	private function tabCycle(i:Int) {
		var curr_obj:FlxObject;
		var multi_obj:FlxGroup;
		
		if(!multi_object){
			curr_index += i;
			
			if (curr_index < 0) {
				curr_index += members.length-1;
			}else if (curr_index >= members.length) {
				curr_index -= members.length;
			}
		
			curr_obj = cast(members[curr_index], FlxObject);
			
		}else {
			if (Std.is(members[curr_index], FlxGroup) == false) {
				multi_object = false;
				curr_sub_index = 0;
				cycleNext(i);
			}
			multi_obj = cast(members[curr_index], FlxGroup);
			curr_sub_index += i;
			
			if (curr_sub_index >= multi_obj.members.length) {
				//advance to the next object
				multi_object = false;
				curr_sub_index = 0;
				
				cycleNext(i);
				return;
			}else if (curr_sub_index < 0) {
				//return to the previous object
				multi_object = false;
				curr_sub_index = 0;
				
				cycleNext(i);
				return;
			}else{
				curr_obj = cast(multi_obj.members[curr_sub_index], FlxObject);					
			}
				
		}
					
		//If the object is invisible, inactive, or we are in infinite loop
		if (curr_obj == null || ((curr_obj.visible == false || curr_obj.active == false) && !failsafe_tripped)) {
			//multi_object = false;
			
			cycleNext(i);			
			return;
		}	
		
		// TODO - ADD OVERTAB PROPERTY
		//if (checkOverTab) {
			//if (!curr_obj.overTab) {
				//cycleNext(i);
				//return;
			//}
		//}
		
		if (checkBounds) {
			var fp:FlxPoint = curr_obj.getScreenXY();
			var pass:Bool = false;
			if (fp.x + curr_obj.width >= 0 && fp.x <= FlxG.width) {
				if (fp.y + curr_obj.height >= 0 && fp.y <= FlxG.height) {
					if(checkRect == null){
						pass = true;
					}else {
						if (checkVsRect(curr_obj,fp)) {
							pass = true;
						}
					}
				}
			}
			if (!pass) {
				cycleNext(i);
				return;
			}
		}
		
		if (Std.is(curr_obj ,FlxGroup) && !(isLegalMultiType(curr_obj))) {
			multi_object = true;
			if(i > 0){
				curr_sub_index = -1;
			}else {
				curr_sub_index = cast(curr_obj, FlxGroup).members.length;
			}
			cycleNext(i);
			return;
		// TODO - Import UI_Merchandise , UI_Swatch , CheckMark
		/*}else if (Std.is(curr_obj ,UI_Merchandise)) {
			var merch:UI_Merchandise = UI_Merchandise(curr_obj);
			FlxG.snapVMouseToLoc(merch.x + merch.back.width - 8, merch.y + merch.back.height - 8);
		}else if (Std.is(curr_obj ,CheckMark)) {
			var crect:FlxRect = CheckMark(curr_obj).checkBox;
			FlxG.snapVMouseToLoc(crect.x + crect.width / 2, crect.y + crect.height / 2);
		}else if (Std.is(curr_obj ,UI_Swatch)) {
			var swatch:UI_Swatch = UI_Swatch(curr_obj);
			if (swatch.swatch.id == "null") {
				cycleNext(i);
				return;
			}else {
				FlxG.snapVMouseToLoc(swatch.x + swatch.width - 8, swatch.y + swatch.height - 8);
			}*/
		}else if (Std.is(curr_obj ,FlxButton)) {
			
			var btn:FlxButton = cast(curr_obj, FlxButton);
			if (btn.onUp != null) {	
				if (Std.is(btn , FlxButtonPlusX) && cast(btn, FlxButtonPlusX).id == "invis") {	
					// TODO - implement mouse snap.
					//FlxG.snapVMouseToLoc(btn.x + btn.width/2, btn.y + btn.height/2); 
				}else {
					// TODO - implement mouse snap.
					//FlxG.snapVMouseToLoc(btn.x + btn.width - 8, btn.y + btn.height - 8);
				}
			}else {
				//skip buttons lacking a callback
				cycleNext(i);
				return;
			}
			// TODO
		//}else if (curr_obj is LevelUpGem_Big) {
			//var lug:LevelUpGem_Big = LevelUpGem_Big(curr_obj);
			//FlxG.snapVMouseToLoc(lug.x + lug.back.width - 8, lug.y + lug.back.height - 8);				
		//}else if (curr_obj is MapPearl) {
			//var pearl:MapPearl = MapPearl(curr_obj);
			//if(pearl.isVisible){
			//	FlxG.snapVMouseToLoc(pearl.x + pearl.width / 2, pearl.y + pearl.height / 2);
			//}else {
			//	cycleNext(i);
		//		return;
		//	}
		//}else if (curr_obj is FlxTextEdit) {
			//var frect:FlxRect;
			//
			//if (multi_obj) {
				//frect = FlxNumStepper(multi_obj).rect;
			//}else {
				//frect = FlxTextEdit(curr_obj).rect;
			//}
			//FlxG.snapVMouseToLoc(frect.x + frect.width - 8, frect.y + frect.height - 8);
		//}else if (Std.is(curr_obj ,Defender)) {
			//var creat:Defender = cast(curr_obj, Defender);
			// TODO - Implement mouse v lock.
			//FlxG.snapVMouseToLoc(creat.zone.center.x, creat.zone.center.y); 
		}else if (Std.is(curr_obj ,FlxSprite)){	//ignore flxsprites
			cycleNext(i);	
			return;

		}else {
			// TODO - Implement mouse v lock.
			//FlxG.snapVMouseToLoc(curr_obj.x + curr_obj.width / 2, curr_obj.y + curr_obj.height / 2);
		}
	}
		
		private function checkVsRect(obj:FlxObject,fp:FlxPoint):Bool {
			var xw:Float = fp.x + obj.width;
			var yh:Float = fp.y + obj.height;
			
			if (fp.x < checkRect.x || xw > checkRect.x + checkRect.width) {
				if (fp.y < checkRect.y || yh > checkRect.y + checkRect.height) {
					return true;
				}
			}
			
			return false;
		}
		
		private function cycleNext(i:Int) {
			failsafe++;
			if (failsafe > MAX_FAILSAFE) {
				failsafe_tripped = true;
			}else{
				tabCycle(i);	
			}
		}
				
		public function sortXY(a:Dynamic, b:Dynamic):Int {
			
			if (a == null) {
				if (b == null) {
					return 0;
				}else {
					return 1;
				}
			}else if (b == null) {
				return -1;
			}
			
			
			if (Std.is(a ,FlxGroup) && !isLegalMultiType(a)) {
				if (!Std.is(a ,FlxRadioGroup)) {
					if(cast(a, FlxGroup).members[0] != null) {
						a = cast(a, FlxGroup).members[0];
					}
				}
			}
			
			if (Std.is(b , FlxGroupX) && !isLegalMultiType(b)) {
				if (!Std.is(b ,FlxRadioGroup)) {
					if(cast(b, FlxGroup).members[0] != null){
						b = cast(b, FlxGroup).members[0];
					}
				}				
			}
			
			//var _a:Dynamic = null;
			//var _b:Dynamic = null;
			
			//if (Std.is(a , FlxObject))
				//_a = cast(a, FlxObject);
			//else
			//if (Std.is(a, FlxGroupX))
				//_a = cast(a, FlxGroupX);
			//else 
			//if (Std.is(a, FlxButtonPlusX))
				//_a = cast(a , FlxButtonPlusX);
				//
			//if (Std.is(b, FlxObject))
				//_b = cast(b, FlxObject);
			//else 
			//if (Std.is(b, FlxGroupX))
				//_b = cast(b, FlxGroupX);
			//else
			//if (Std.is(b, FlxButtonPlusX))
				//_b = cast(b, FlxButtonPlusX);
			
			var axy:Float = (a.y * Lib.stage.stageWidth) + a.x;
			var bxy:Float = (b.y * Lib.stage.stageHeight) + b.x;
			if (axy < bxy) return -1;
			if (axy > bxy) return 1;
			return 0;
		}
		
}
