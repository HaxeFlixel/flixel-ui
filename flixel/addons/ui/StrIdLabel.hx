package flixel.addons.ui;

import flixel.util.FlxStringUtil;

class StrIdLabel
{
	public var id:String;
	public var label:String;
	
	public function new(Id:String="",Label:String="") 
	{
		id = Id;
		label = Label;
	}
	
	public function copy():StrIdLabel {
		return new StrIdLabel(id, label);
	}
	
	public static function sortByLabel(a:StrIdLabel, b:StrIdLabel):Int {
		if (a.label < b.label) { return -1; }
		if (a.label > b.label) { return  1; }
		return 0;
	}
	
	public static function sortById(a:StrIdLabel, b:StrIdLabel):Int {
		if (a.id < b.id) { return -1; }
		if (a.id > b.id) { return  1; }
		return 0;
	}
	
	public function toString():String {
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("id", id),
			LabelValuePair.weak("label", label)]);
	}
}