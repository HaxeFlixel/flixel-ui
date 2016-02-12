package flixel.addons.ui;
import flixel.addons.ui.FlxUITooltip;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * ...
 * @author larsiusprime
 */
class FlxUITooltipManager implements IFlxDestroyable
{
	/**
	 * Turn on flipping the anchor position around in order to keep a tooltip on screen
	 */
	public var autoFlipAnchor:Bool = true;
	
	/**
	 * Default anchor position for tooltips where no anchor is defined
	 */
	public var defaultAnchor:Anchor = null;
	
	/**
	 * Default style for tooltips where no style is defined
	 */
	public var defaultStyle:FlxUITooltipStyle = null;
	public var showOnClick:Bool = false;
	public var delay:Float = 0.1;
	
	public function new(?State:FlxUIState,?SubState:FlxUISubState) 
	{
		if (State != null)
		{
			state = State;
		}
		else if(SubState != null)
		{
			subState = SubState;
		}
		list = [];
		tooltip = new FlxUITooltip(100, 50);
		lastPosition = new FlxPoint(0, 0);
		defaultAnchor = tooltip.anchor.clone();
		defaultStyle = FlxUITooltip.cloneStyle(tooltip.style);
	}
	
	@:access(flixel.addons.ui.FlxUI)
	@:access(flixel.addons.ui.FlxUIState)
	@:access(flixel.addons.ui.FlxUISubState)
	public function init():Void
	{
		var ui:FlxUI = (state != null) ? state._ui : ((subState != null) ? subState._ui : null);
		if (ui == null)
		{
			return;
		}
		
		//See if there is a default tooltip definition specified in the xml, and if so, load that as our default tooltip style
		
		if (ui != null && ui.getDefinition("default:tooltip") != null)
		{
			var tt = ui._loadTooltipData(null);					//passing in null causes it to load the default tooltip style
			defaultStyle = FlxUITooltip.cloneStyle(tt.style);
			tooltip.style = defaultStyle;
		}
	}
	
	public function destroy()
	{
		FlxDestroyUtil.destroyArray(list); list = null;
		tooltip = null;
		lastPosition = null;
		state = null;
		subState = null;
		defaultAnchor = null;
		defaultStyle = null;
	}
	
	/**
	 * Removes all tooltips
	 */
	public function clear()
	{
		while (list.length > 0)
		{
			var entry = list.pop();
			if (entry != null)
			{
				entry.destroy();
			}
		}
	}
	
	/**
	 * Hides the tooltip that is being displayed right now
	 */
	
	public function hideCurrent()
	{
		if (current > 0)
		{
			hide(current);
		}
	}
	
	/**
	 * Checks whether the currently shown tooltip belongs to a given FlxSprite, or optionally, any of its children (if it is a FlxUIGroup or FlxUI)
	 * @param	thing			the FlxSprite to check
	 * @param	checkChildren	whether or not to check its children (default: true)
	 * @return
	 */
	public function doesCurrentTooltipBelongTo(thing:FlxSprite, checkChildren:Bool = true):Bool
	{
		if (Std.is(thing, FlxUIGroup))
		{
			var i = findObj(cast thing);
			if (i != -1) return true;
			
			if (checkChildren)
			{
				var fuig:FlxUIGroup = cast thing;
				for (member in fuig.members)
				{
					if (doesCurrentTooltipBelongTo(member))
					{
						return true;
					}
				}
			}
		}
		else if (Std.is(thing, FlxUIButton))
		{
			var i = findBtn(cast thing);
			if (i == -1) return false;
			return i == current;
		}
		else if(Std.is(thing, FlxObject))
		{
			var i = findObj(cast thing);
			if (i == -1) return false;
			return i == current;
		}
		return false;
	}
	
	/**
	 * Allows you to turn tooltips on or off for an object that has already been added
	 * @param	thing	The object you want to turn tooltips on or off for
	 * @param	b		On or off
	 * 
	 * @return	true if the object was found and the property set, false if the object has not been added to the tooltip manager
	 */
	public function enableTooltipFor(thing:FlxObject, enabled:Bool):Bool
	{
		if (thing == null) return false;
		
		for (entry in list)
		{
			if (entry.obj == thing || (Std.is(thing,IFlxUIButton) && cast(thing,IFlxUIButton) == entry.btn))
			{
				entry.enabled = enabled;
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Adds a tooltip for this object, using the specified data.
	 * NOTE: if thing does not implement IFlxUIButton, a new invisible
	 * button will be created for it in order to drive tooltips.
	 * 
	 * @param	thing	The object you want to add a tooltip to.
	 * @param	data
	 */
	
	public function add(thing:FlxObject, data:FlxUITooltipData):Void
	{
		if (_init) {
			data.style = FlxUITooltip.styleFix(data.style, defaultStyle);		//replace null values with sensible defaults
		}
		
		var btn:IFlxUIButton = null;
		var i = -1;
		if (Std.is(thing, IFlxUIButton))
		{
			btn = cast thing;
			
			i = findBtn(btn);
			
			if (i == -1)
			{
				//doesn't exist, make a new one
				list.push(new FlxUITooltipEntry(btn, data));
			}
			else
			{
				//does exist, replace the old one
				list[i].data = data;
				list[i].count = 0;
			}
		}
		else	//create a button to process the tooltip for this sprite
		{
			i = findObj(thing);
			
			if (i == -1)
			{
				//doesn't exist, make a new one
				
				//create a blank button to process the tooltip
				var b = new FlxUIButton(0, 0, "", null, false, true);
				b.resize(thing.width, thing.height);
				
				btn = b;
				//btn = new FlxUIButton(0, 0, "", null, false, true);
				
				//match the properties of the sprite
				btn.x = thing.x;
				btn.y = thing.y;
				btn.width = thing.width;
				btn.height = thing.height;
				btn.scrollFactor.set(thing.scrollFactor.x, thing.scrollFactor.y);
				
				//add it to the state
				if (state != null)
				{
					state.add(cast btn);
				}
				else if (subState != null)
				{
					subState.add(cast btn);
				}
				
				//add it to the list
				list.push(new FlxUITooltipEntry(btn, data, thing));
			}
			else
			{
				//does exist, replace the old one
				
				list[i].data = data;
				list[i].count = 0;
				
				list[i].btn.x = thing.x;
				list[i].btn.y = thing.y;
				list[i].btn.width = thing.width;
				list[i].btn.height = thing.height;
				list[i].btn.scrollFactor.set(thing.scrollFactor.x, thing.scrollFactor.y);
			}
		}
	}
	
	/**
	 * Remove a tooltip associated with this object, if there is one
	 * @param	thing
	 */
	public function remove(thing:FlxObject)
	{
		var btn:IFlxUIButton = null;
		var i = -1;
		if (Std.is(thing, IFlxUIButton))
		{
			btn = cast thing;
			i = findBtn(btn);
		}
		else
		{
			i = findObj(thing);
		}
		if (i != -1)
		{
			if (current == i)
			{
				hide(current);
			}
			var entry = list[i];
			list.splice(i, 1);
			entry.destroy();
		}
	}
	
	public function update(elapsed:Float):Void
	{
		//iterate over all our buttons and watch their states
		for (i in 0...list.length)
		{
			var btn = list[i].btn;
			var obj = list[i].obj;
			
			if (list[i].enabled == false)
			{
				if (current == i)
				{
					hide(i);
				}
				list[i].count = 0;
				continue;
			}
			
			if (obj != null)
			{
				btn.x = obj.x;
				btn.y = obj.y;
				btn.visible = obj.visible;
			}
			
			if (false == btn.visible || btn.justMousedOut || btn.mouseIsOut)
			{
				list[i].count = 0;
				hide(i);
			}
			else if (btn.justMousedOver || btn.mouseIsOver)
			{
				if (btn.mouseIsOver)
				{
					list[i].count += elapsed;
				}
			}
			
			if (list[i].count > delay || (list[i].data.delay >= 0 && list[i].count > list[i].data.delay))
			{
				if (current != i)
				{
					show(i); 
				}
				else if (list[i].data.moving)
				{
					show(i);
				}
			}
		}
	}
	
	/*********PRIVATE*************/
	
	private var _init:Bool = false;
	
	/**list of all the tooltip entries**/
	private var list:Array<FlxUITooltipEntry>;
	
	/**we actually only ever use one tooltip object :) **/
	private var tooltip:FlxUITooltip;
	
	/**the current tooltip**/
	private var current:Int = -1;
	private var lastPosition:FlxPoint;
	
	private var state:FlxUIState;
	private var subState:FlxUISubState;
	
	private function hide(i:Int):Void
	{
		if (current == i)
		{
			tooltip.hide();
			if (state != null)
			{
				state.remove(tooltip, true);
			}
			if (subState != null)
			{
				subState.remove(tooltip, true);
			}
			current = -1;
		}
	}
	
	private function findBtn(btn:IFlxUIButton):Int
	{
		if (btn == null) return -1;
		for (i in 0...list.length)
		{
			if (list[i] != null && list[i].btn == btn)
			{
				return i;
			}
		}
		return -1;
	}
	
	private function findObj(obj:FlxObject):Int
	{
		if (obj == null) return -1;
		for (i in 0...list.length)
		{
			if (list[i] != null && list[i].obj == obj)
			{
				return i;
			}
		}
		return -1;
	}
	
	private function show(i:Int):Void
	{
		var btn  = list[i].btn;
		
		if (btn.visible == false || (list[i].obj != null && list[i].obj.visible == false))
		{
			return;
		}
		
		if (current == i)
		{
			var deltaX = btn.x - lastPosition.x;
			var deltaY = btn.y - lastPosition.y;
			
			lastPosition.x = btn.x;
			lastPosition.y = btn.y;
			
			tooltip.x += deltaX;
			tooltip.y += deltaY;
			return;
		}
		
		current = i;
		
		var data = list[i].data;
		
		if (data.init != true)
		{
			data.style = FlxUITooltip.styleFix(data.style, defaultStyle);		//replace null values with sensible defaults
			data.init = true;
		}
		
		var autoSizeVertical = true;
		var autoSizeHorizontal = true;
		if (data.style != null)
		{
			tooltip.style = data.style;
			autoSizeVertical = data.style.autoSizeVertical;
			autoSizeHorizontal = data.style.autoSizeHorizontal;
		}
		
		if (data.anchor != null)
		{
			tooltip.anchor = data.anchor;
		}
		else if(defaultAnchor != null)
		{
			tooltip.anchor = defaultAnchor;
		}
		
		if (state != null)
		{
			state.add(tooltip);
		}
		if (subState != null)
		{
			subState.add(tooltip);
		}
		
		tooltip.show(cast btn, data.title, data.body, autoSizeVertical, autoSizeHorizontal);
		
		if (autoFlipAnchor)
		{
			if (checkAutoFlip(btn, tooltip))
			{
				tooltip.show(cast btn, data.title, data.body, autoSizeVertical, autoSizeHorizontal);
			}
		}
		
		lastPosition.set(btn.x, btn.y);
	}
	
	private function checkAutoFlip(thing:IFlxUIButton, tooltip:FlxUITooltip):Bool
	{
		var flipX = (tooltip.x < 0 || (tooltip.x + tooltip.width  > FlxG.width));
		var flipY = (tooltip.y < 0 || (tooltip.y + tooltip.height > FlxG.height));
		
		if (flipX || flipY)
		{
			tooltip.anchor = tooltip.anchor.getFlipped(flipX, flipY);
			return true;
		}
		
		return false;
	}
}

private class FlxUITooltipEntry implements IFlxDestroyable
{
	public var obj:FlxObject;
	public var btn:IFlxUIButton;
	public var count:Float;
	public var data:FlxUITooltipData;
	public var enabled:Bool;
	
	public function new(Btn:IFlxUIButton, Data:FlxUITooltipData, ?Obj:FlxObject)
	{
		btn = Btn;
		data = Data;
		obj = Obj;
		count = 0;
		enabled = true;
		if (data != null)
		{
			if (data.delay == null) data.delay = -1;
			if (data.moving == null) data.moving = false;
		}
	}
	
	public function destroy():Void
	{
		count = 0;
		obj = null;
		btn = null;
		data.anchor = null;
		data.style = null;
		data = null;
	}
}

typedef FlxUITooltipData = {
	title:String,
	body:String,
	?anchor:Anchor,
	?style:FlxUITooltipStyle,
	?init:Bool,
	?delay:Int,
	?moving:Bool
}