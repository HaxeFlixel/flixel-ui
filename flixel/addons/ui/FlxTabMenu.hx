package flixel.addons.ui;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class FlxTabMenu extends FlxGroupX implements IEventGetter
{

	/***Event Handling***/
	
	public function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		//not yet implemented
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//not yet implemented
		return null;
	}	
	
	/***PUBLIC***/
	
	public function new(back_:FlxSprite,tabs_:Array<FlxButtonToggle>) 
	{
		super();		
		_back = back_;
		add(_back);
		
		var offset_y:Float = 0;
		
		_tabs = tabs_;
		var xx:Float = 0;
		for (tab in _tabs) {
			add(tab);
			tab.x = xx;			
			tab.y = -(tab.btn_normal.height-2);
			#if cpp
				tab.y += 1;	//cpp target is off by 1 for some reason
			#end
			xx += tab.btn_normal.width;
			#if cpp
				xx -= 1;	//cpp target is off by 1 for some reason
			#end
			tab.Callback = onClickTab;
		}
				
		_tab_groups = new Array<FlxGroupX>();
	}
	
	public override function destroy():Void {
		super.destroy();
		U.clearArray(_tab_groups);
		U.clearArray(_tabs);
		_back = null;
		_tabs = null;
		_tab_groups = null;
	}

	public function addGroup(g:FlxGroupX):Void {
		if (g == this) {
			return;			//DO NOT ADD A GROUP TO ITSELF
		}
		
		if(!hasThis(g)){	//ONLY ADD IF IT DOESN'T EXIST
			add(g);
			_tab_groups.push(g);
		}
		
		_showOnlyGroup("");
	}
	
	public function showTabInt(i:Int):Void {
		if(_tabs != null && _tabs.length > i){
			var _tab:FlxButtonToggle = _tabs[i];
			var id:String = _tab.id;
			onClickTab([id]);
		}
	}
	
	public function onClickTab(Params:Dynamic):Void {
		var id:String = "";
		if (Std.is(Params,Array)) {
			if (Std.is(Params[0], String)) {
				id = Params[0];
			}
		}
		
		if (id == "") return;
		
		for (tab in _tabs) {
			if (tab.id == id) {
				if(!tab.toggle){
					tab.toggle = true;					
				}
			}else {
				tab.toggle = false;
			}
		}
		
		_showOnlyGroup(id);
	}
		
	/***PRIVATE***/
	
	private var _back:FlxSprite;
	private var _tabs:Array<FlxButtonToggle>;
	private var _tab_groups:Array<FlxGroupX>;
	
	private function _showOnlyGroup(id:String):Void {
		for (group in _tab_groups) {
			if (group.str_id == id) {
				group.visible = group.active = true;
			}else {
				group.visible = group.active = false;
			}
		}
	}
}