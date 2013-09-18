package flixel.addons.ui;

/**
 * ...
 * @author 
 */
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
	
}