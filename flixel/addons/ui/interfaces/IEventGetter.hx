package flixel.addons.ui.interfaces;

/**
 * A simple, quick-and-dirty messaging interface
 * @author Lars Doucet
 */
interface IEventGetter 
{
	/**
	 * Usage: receiver.getEvent("event_id",sender,some_data);
	 * For when you want to send some event between objects
	 * 
	 * @param	id string id for the event
	 * @param	sender the object that initiated the event
	 * @param	data data you want to send
	 */
	public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void;
	
	/**
	 * Usage: response = getRequest("event_id",sender,some_data);
	 * For when you want to send some event between objects,
	 * and generate some kind of response or get data back
	 * 
	 * @param	id string id for the event
	 * @param	sender the object that initiated the event
	 * @param	data data you want to send
	 * @return	varies
	 */
	public function getRequest(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic;
}