package com.pdev.lighting;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * ...
 * @author P Svilans
 */

class Light 
{
	
	public var isAmbient:Bool;
	
	public var x:Int;
	public var y:Int;
	public var rotation:Float;
	
	public var radius:Int;
	
	// Texture to be used as the light's lightmap, defining which areas are bright. The default is a radial gradient.
	private var _texture:BitmapData;
	public var canvas:BitmapData;
	
	public var offsetX:Int;
	public var offsetY:Int;
	
	private var _bounds:Rectangle;
	
	private var _isEnabled:Bool;
	
	/**
	 * Creates a new light (no shit)...
	 * @param	texture Texture to use as the source for the light's lightmap.
	 * @param	x x position of the light.
	 * @param	y y position of the light.
	 * @param	offsetX Doesn't work, but should be offsetting the position of the texture to the light's position.
	 * @param	offsetY Doesn't work.
	 */
	
	public function new( texture:BitmapData, x:Int = 0, y:Int = 0, offsetX:Int = 0, offsetY:Int = 0) 
	{
		_isEnabled = true;
		
		this.x = x;
		this.y = y;
		this.rotation = 0.0;
		
		this.texture = texture;
		
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		
		isAmbient = false;
	}
	
	/**
	 * Initialize this light before it's about to be drawn.
	 */
	
	public function init():Void
	{
		
	}
	
	public function setEnabled( enabled:Bool):Void
	{
		_isEnabled = enabled;
	}
	
	private function get_bounds():Rectangle 
	{
		_bounds.x = x - radius;
		_bounds.y = y - radius;
		return _bounds;
	}
	
	public var bounds(get_bounds, null):Rectangle;
	
	private function get_texture():BitmapData 
	{
		return _texture;
	}
	
	private function set_texture(value:BitmapData):BitmapData 
	{
		if ( value != null)
		{
			canvas = new BitmapData( value.width, value.height, true, 0);
			radius = canvas.width >> 1;
			_bounds = canvas.rect;
		}
		return _texture = value;
	}
	
	public var texture(get_texture, set_texture):BitmapData;
	
	function get_isEnabled():Bool 
	{
		return _isEnabled;
	}
	
	public var isEnabled(get_isEnabled, null):Bool;
	
}