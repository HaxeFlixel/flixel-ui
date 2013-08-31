package flixel.addons.ui;

/**
 * ...
 * @author 
 */
class FlxUIPopup extends FlxUISubState
{

	public override function create():Void {		
		if(_xml_id == null){
			_xml_id = FlxUIAssets.XML_DEFAULT_POPUP_ID;
		}
		getTextFallback = myGetTextFallback;
		super.create();
	}
	
	public override function eventResponse(id:String, sender:Dynamic, data:Array<Dynamic>):Void {
		switch(id) {
			case "click_button":
				var i:Int = cast data[0];
				var label:String = cast data[1];
				switch(i) {
					case 0, 1, 2: close();
				}
		}
	}
	
	//This function is passed into the UI object as a default in case the user is not using FireTongue
	
	private function myGetTextFallback(flag:String, context:String = "ui", safe:Bool = true):String {
		switch(flag) {
			case "$POPUP_YES": return "Yes";
			case "$POPUP_NO": return "No";
			case "$POPUP_OK": return "Ok";
			case "$POPUP_CANCEL": return "Cancel";
			case "$POPUP_TITLE_DEFAULT": return "Alert!";
			case "$POPUP_BODY_DEFAULT": return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam consectetur vehicula pellentesque. Phasellus at blandit augue. Suspendisse vel leo ut elit imperdiet eleifend ut quis purus. Quisque imperdiet turpis vitae justo hendrerit molestie. Quisque tempor ante eget posuere viverra.";
		}	
		return flag;
	}
	
}