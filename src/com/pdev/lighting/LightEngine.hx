package com.pdev.lighting;
import com.pdev.lighting.occlusion.ILightOccluder;
import com.pdev.tools.LightTool;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * The main class of the lighting engine (hence it being called, LightEngine...), that takes a list of lights and a list of occluders and
 * draws some fancy, pretty lights!
 * @author P Svilans
 */

 using com.pdev.lighting.display.BitmapGraphics;

class LightEngine 
{
	
	/**
	 * Colour used to draw bounds of lights and shadows.
	 */
	public static inline var BOUND_COLOUR:Int = 0xFFFF0000;
	/**
	 * Fill colour to use as a mask for lights.
	 */
	public static inline var LIGHT_COLOUR:Int = 0xFF0000FF;
	
	private var lights:Array<Light>;
	private var occluders:Array<ILightOccluder>;
	
	/**
	 * The palette map to use to render lights.
	 */
	public var paletteMap:Array<Int>;

	public function new() 
	{
		lights = new Array<Light>();
		occluders = new Array<ILightOccluder>();
		
		paletteMap = LightTool.paletteMap( [ 0x00FFFFFF, 0xAA000000, 0xF8000000], [ 0, 180, 256]);
	}
	
	/**
	 * Render da lightz.
	 * @param	canvas The canvas to render to.
	 * @param	ox The offset x of the rendered area.
	 * @param	oy The offset y of the rendered area.
	 */
	public function render( canvas:BitmapData, ox:Int, oy:Int):Void
	{
		// lock the canvas, increases performance a tiny bit. (But realistically probably way too tiny to notice anything)
		canvas.lock();
		
		// Clear the canvas to a default, blank state.
		canvas.fillRect( canvas.rect, 0x00000000);
		
		// Clipping rectangle for the canvas
		var frame = canvas.rect;
		frame.x = ox;
		frame.y = oy;
		
		for ( light in lights)
		{
			//Check if a light is in view.
			if ( !light.bounds.intersects( frame) || !light.isEnabled) continue;
			
			var r = light.radius;
			
			if ( !light.isAmbient)
			{
				var c = light.canvas;
				// Lock the light's canvas. Just in case, shouldn't make a difference if you don't have the light's canvas attached to a Bitmap object.
				c.lock();
				
				// Clear the light's canvas.
				c.fillRect( c.rect, 0x00000000);
				
				light.init();
				
				for ( occluder in occluders)
				{
					// If the occluder is in range of the light.
					if ( !light.bounds.intersects( occluder.bounds ) ) continue;
					
					// Initialize the occluder. The occluder will draw itself to the light's canvas, as well as return an array of it's edge points.
					var points = occluder.init( light );
					
					var px = occluder.x;
					var py = occluder.y;
					// Cycle through edge points and draw a line from that point to the edge of the canvas.
					for ( point in points )
					{
						if ( !light.bounds.contains( point.x + px, point.y + py ) ) continue;
						
						var dx = point.x - light.x + px;
						var dy = point.y - light.y + py;
						
						var x:Int;
						var y:Int;
						
						// Boring rectangle clipping math and stuff.
						if ( dx == 0 && dy == 0) continue;
						else if ( dx == 0)
						{
							x = r;
							y = ( dy > 0) ? c.height : 0;
						}
						else if ( dy == 0)
						{
							x = ( dx > 0) ? c.width : 0;
							y = r;
						}
						else
						{
							var m:Float;
							var b:Float;
							
							if ( Math.abs( dy) > Math.abs( dx))
							{
								m = dx / dy;
								b = ( dx + r) - m * ( dy + r);
								
								if ( dy > 0)
								{
									y = c.height;
									x = Std.int( m * ( c.height) + b);
								}
								else
								{
									y = 0;
									x = Std.int( b);
								}
							}
							else
							{
								m = dy / dx;
								b =  ( dy + r) - m * ( dx + r);
								
								if ( dx > 0)
								{
									x = c.width;
									y = Std.int( m * ( c.width) + b);
								}
								else
								{
									x = 0;
									y = Std.int( b);
								}
							}
						}
						
						// Draw the line from the edge point to the edge of the light's canvas.
						c.drawLine( r + dx, r + dy, x, y, BOUND_COLOUR);
					}
				}
				
				// Draw the light's bounds, this speeds things up, because then floodFill() won't be filling in irrelevant areas.
				c.drawCircle( r, r, r, BOUND_COLOUR);
				// Flood fill the light.
				c.floodFill( r, r, LIGHT_COLOUR);
				// Remove all bound coloured areas.s
				c.threshold( c, c.rect, new Point(), "==", BOUND_COLOUR, 0x00000000, 0xFFFFFFFF, false);
				
				c.unlock();
				// Area which to draw on the main canvas.
				var fClip = frame.intersection( light.bounds);
				// Area which to copy from the light's canvas.
				var lClip = fClip.clone();
				fClip.x -= frame.x;
				fClip.y -= frame.y;
				lClip.x -= light.x - r;
				lClip.y -= light.y - r;
				
				// Copy the light's canvas to the main canvas.
				canvas.copyPixels( light.texture, lClip, new Point( fClip.x, fClip.y), c, new Point( lClip.x, lClip.y), true);
				//canvas.copyPixels( c, lClip, new Point( fClip.x, fClip.y), c, new Point( lClip.x, lClip.y), true);
			}
			else
			{
				// Area which to draw on the main canvas.
				var fClip = frame.intersection( light.bounds);
				// Area which to copy from the light's canvas.
				var lClip = fClip.clone();
				fClip.x -= frame.x;
				fClip.y -= frame.y;
				lClip.x -= light.x - r;
				lClip.y -= light.y - r;
				
				// Copy the light's canvas to the main canvas.
				canvas.copyPixels( light.texture, lClip, new Point( fClip.x, fClip.y), null, null, true);
			}
		}
		
		// Convert all lightmaps to real colours.
		canvas.paletteMap( canvas, canvas.rect, new Point(), null, null, null, paletteMap);
		
		canvas.unlock();
	}
	
	public function addLight( light:Light):Void
	{
		lights.push( light);
	}
	
	public function removeLight( light:Light):Void
	{
		lights.remove( light);
	}
	
	public function addOccluder( occluder:ILightOccluder):Void
	{
		occluders.push( occluder);
	}
	
	public function removeOccluder( occluder:ILightOccluder):Void
	{
		occluders.remove( occluder);
	}
	
	public function clear():Void
	{
		var L:Int;
		L = lights.length;
		for ( i in 0...L) lights.pop();
		
		L = occluders.length;
		for ( i in 0...L) occluders.pop();
	}
	
	public function lightIterator():Iterator<Light>
	{
		return lights.iterator();
	}
	
	public function occluderIterator():Iterator<ILightOccluder>
	{
		return occluders.iterator();
	}
	
}