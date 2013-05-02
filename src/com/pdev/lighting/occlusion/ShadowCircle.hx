package com.pdev.lighting.occlusion;
import com.pdev.lighting.Light;
import com.pdev.lighting.LightEngine;
import com.pdev.lighting.PointInt;
import de.polygonal.ds.SLL;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * ...
 * @author P Svilans
 */

using com.pdev.lighting.display.BitmapGraphics;

class ShadowCircle implements ILightOccluder
{
	
	public var x:Int;
	public var y:Int;
	public var rotation:Float;
	
	private var _radius:Int;
	
	private var _bounds:Rectangle;

	public function new( radius:Int, x:Int = 0, y:Int = 0) 
	{
		_bounds = new Rectangle();
		
		this.x = x;
		this.y = y;
		this.radius = radius;
	}
	
	/* INTERFACE com.pdev.lighting.occlusion.ILightOccluder */
	
	public function init( light:Light):SLL<PointInt> 
	{
		/**
		 * Super unoptimized way to get the tangents of this circle to the light source.
		 */
		var toObject = new PointInt( x - light.x, y - light.y);
		var lr = light.radius;
		var r = _radius;
		var d = toObject.length();
		var t = Math.sqrt( d * d - r * r);
		var sinA = r / d;
		var cosA = t / d;
		
		var rads = Math.PI * 0.5 - Math.atan2( r, t);
		var orig = Math.atan2( toObject.y, toObject.x) + Math.PI;
		
		var r1 = orig + rads;
		var r2 = orig - rads;
		
		// Draw an arc between both tangents
		light.canvas.drawArc( lr + toObject.x, lr + toObject.y, r, r1, r2, LightEngine.BOUND_COLOUR);
		
		var x1 = Std.int( Math.cos( r1) * r);
		var y1 = Std.int( Math.sin( r1) * r);
		
		var x2 = Std.int( Math.cos( r2) * r);
		var y2 = Std.int( Math.sin( r2) * r);
		
		//Add tangent points as edge points.
		var e = new SLL<PointInt>();
		e.append( new PointInt( x1, y1));
		e.append( new PointInt( x2, y2));
		
		return e;
	}
	
	private function get_bounds():Rectangle 
	{
		_bounds.x = x - radius;
		_bounds.y = y - radius;
		return _bounds;
	}
	
	public var bounds(get_bounds, null):Rectangle;
	
	private function get_radius():Int 
	{
		return _radius;
	}
	
	private function set_radius(value:Int):Int 
	{
		if ( value < 0) value = -value;
		
		_bounds.width = value << 1;
		_bounds.height = value << 1;
		return _radius = value;
	}
	
	public var radius(get_radius, set_radius):Int;
	
}