package com.pdev.lighting.occlusion;
import com.pdev.lighting.Light;
import com.pdev.lighting.LightEngine;
import com.pdev.lighting.PointInt;
import de.polygonal.ds.SLL;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author P Svilans
 */

 // Gives us functions for drawing lines and circles and arcs on a bitmapDatas
using com.pdev.lighting.display.BitmapGraphics;

class ShadowSegment implements ILightOccluder
{
	
	public var x:Int;
	public var y:Int;
	public var rotation:Float;
	
	// Points are stored in a single-linked-list, since we only ever need to iterate through them in one way.
	private var points:SLL<PointInt>;
	
	public var isClosed:Bool;
	
	public var isClockwise:Bool;
	
	private var _bounds:Rectangle;
	
	public var shadowDistance:Float;
	public var constant:Bool;

	public function new( x:Int = 0, y:Int = 0, rotation:Float = 0.0 ) 
	{
		this.x = x;
		this.y = y;
		this.rotation = rotation;
		
		points = new SLL<PointInt>();
		isClosed = false;
		isClockwise = false;
		
		shadowDistance = 1 / 0; //Set infinity as default
		
		_bounds = new Rectangle();
	}
	
	public function add( point:PointInt):Void
	{
		points.append( point);
	}
	
	public function remove( point:PointInt):Void
	{
		points.remove( point);
	}
	
	public function iterator():Iterator<PointInt>
	{
		return points.iterator();
	}
	
	/* INTERFACE com.pdev.lighting.occlusion.ILightOccluder */
	
	/**
	 * This draws the object to the light's canvas, and also returns it's edge points.
	 * @param	light The light that is currently being processed.
	 * @return A list of edge points.
	 */
	public function init( light:Light ):SLL<PointInt>
	{
		var e:SLL<PointInt> = new SLL<PointInt>();
		
		// Transform points
		var matrix:Matrix = new Matrix();
		matrix.rotate( rotation );
		var points:SLL<PointInt> = new SLL<PointInt>();
		var p:Point = new Point();
		
		for ( point in this.points )
		{
			p.x = point.x;
			p.y = point.y;
			
			p = matrix.transformPoint( p );
			
			
			points.append( new PointInt( Std.int( p.x ), Std.int( p.y ) ) );
		}
		
		// Declare vars (no shit)
		// Vector to the current point.
		var toC:PointInt;
		// Vector to the next point.
		var toN:PointInt;
		// Cross product of the next point to the current point.
		var next:Float;
		// Cross product of the previous point to the current point.
		var prev:Float;
		// Init first with a default value (is either never used or overwritten)
		var first:Float = 0.0;
		
		// shorthand for the light's radius.
		var r = light.radius;
		// shorthand for light's canvas.
		var canvas = light.canvas;
		
		// define the current list node.
		var c = points.head;
		// define the next list node.
		var n = c.next;
		
		// Define the vectors to the current and next point of the polygon.
		toC = new PointInt( c.val.x + x - light.x, c.val.y + y - light.y );
		toN = new PointInt( n.val.x + x - light.x, n.val.y + y - light.y );
		
		// Get the next cross product.
		next = toC.cross( toN );
		
		// If next is positive, the edge (from first point to the second point) is facing away from the light, so draw the edge.
		if ( next > 0 || !isClosed )
		{
			canvas.drawLine( c.val.x - light.x + r + x,
							c.val.y - light.y + r + y,
							n.val.x - light.x + r + x,
							n.val.y - light.y + r + y,
							LightEngine.BOUND_COLOUR);
		}
		
		// If we want the series of points to define a polygon, and not a series of line segments.
		if ( isClosed )
		{
			// Get the last point of the list (technically the previous point of the current (first) point)
			var p = points.tail;
			// Get the vector from the light to the previous point.
			var toP = new PointInt( p.val.x + x - light.x, p.val.y + y - light.y);
			
			//Cross product...
			prev = toC.cross( toP);
			// If both the previous and next point are on the same side of the current point-to-light vector,
			// the current point is an edge point.
			// Add the current point to the list of edge points we will return to the light engine.
			if ( prev * next >= 0) e.append( c.val);
			// Since we don't care about the actual value of the cross product, only it's sign, we store the negative of the
			// first-last cross product, since we will need it at the end for the last-first cross product.
			first = -prev;
		}
		else
		{
			// If we don't want a closed polygon, but a series of line segments, then the first point will always be an edge point, so add it.
			e.append( c.val);
		}
		
		// Store the first node when we will deal with the last node (and the first node then will be the next node to the last node).
		var f = c;
		
		// The negative cross product of next will be the next points prev cross product (at least the sign, but the actual value doesn't matter.)
		prev = -next;
		// Copy values of next point-to-light vector to the current point-to-light vector.
		toC.x = toN.x;
		toC.y = toN.y;
		// Current = Next (advances the list to examine the next point).
		c = n;
		
		// While we have more nodes to examine...
		while ( c.hasNext() )
		{
			// Get the next node.
			n = c.next;
			
			// Get the next-to-light vector.
			toN.x = n.val.x + x - light.x;
			toN.y = n.val.y + y - light.y;
			
			// Get the next cross product.
			next = toC.cross( toN);
			
			// If next is positive, this edge (from current to next point) is facing away from the light, draw it to the light's canvas.
			if ( next > 0 || !isClosed)
			{
				canvas.drawLine( c.val.x - light.x + r + x,
								c.val.y - light.y + r + y,
								n.val.x - light.x + r + x,
								n.val.y - light.y + r + y,
								LightEngine.BOUND_COLOUR);
			}
			
			// If prev and next are both either negative or both positive, the current point is an edge point.
			if ( prev * next >= 0 ) e.append( c.val );
			
			// Advance all vars to the next point.
			prev = -next;
			toC.x = toN.x;
			toC.y = toN.y;
			c = n;
		}
		
		// Check if we want to make a closed polygon, and, if first was greater than 0, then the last edge is facing away from the light, draw it.
		if ( isClosed && first > 0)
		{
			canvas.drawLine( f.val.x - light.x + r + x,
							f.val.y - light.y + r + y,
							c.val.x - light.x + r + x,
							c.val.y - light.y + r + y,
							LightEngine.BOUND_COLOUR);
		}
		
		// If either we want a series a line segments, the last point will be an edge point...
		// ...OR, if the first and second last point are on the same side of the last-to-light vector, the last point is an edge point.
		// Add it.
		if ( !isClosed || prev * first >= 0)
		{
			e.append( c.val);
		}
		
		// Return the list of edge points.
		return e;
	}
	
	private function get_bounds():Rectangle 
	{
		// Transform points
		var matrix:Matrix = new Matrix();
		matrix.rotate( rotation);
		
		var point:Point = new Point();
		
		var v = false;
		for ( p in points)
		{
			point.x = p.x;
			point.y = p.y;
			
			point = matrix.transformPoint( point);
			
			if ( v)
			{
				_bounds.left = Math.min( point.x + x, _bounds.left);
				_bounds.right = Math.max( point.x + x, _bounds.right);
				_bounds.top = Math.min( point.y + y, _bounds.top);
				_bounds.bottom = Math.max( point.y + y, _bounds.bottom);
			}
			else
			{
				v = true;
				_bounds.x = point.x + x;
				_bounds.y = point.y + y;
				_bounds.width = 0;
				_bounds.height = 0;
			}
		}
		return _bounds;
	}
	
	public var bounds(get_bounds, null):Rectangle;
	
}