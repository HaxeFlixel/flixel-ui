package flixel.addons.ui;

import flixel.addons.ui.StrNameLabel;
import flixel.util.FlxStringUtil;

class StrNameLabel
{
	public var name:String;
	public var label:String;

	public function new(Name:String = "", Label:String = "")
	{
		name = Name;
		label = Label;
	}

	public function copy():StrNameLabel
	{
		return new StrNameLabel(name, label);
	}

	public static function sortByLabel(a:StrNameLabel, b:StrNameLabel):Int
	{
		if (a.label < b.label)
		{
			return -1;
		}
		if (a.label > b.label)
		{
			return 1;
		}
		return 0;
	}

	public static function sortByName(a:StrNameLabel, b:StrNameLabel):Int
	{
		if (a.name < b.name)
		{
			return -1;
		}
		if (a.name > b.name)
		{
			return 1;
		}
		return 0;
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("name", name), LabelValuePair.weak("label", label)]);
	}
}
