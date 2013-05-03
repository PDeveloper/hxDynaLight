package com.pdev.lighting;
import flash.display.BitmapData;
 
/**
 * ...
 * @author P Svilans
 */

 using com.pdev.lighting.display.BitmapGraphics;
 
class DirectionalLight extends Light
{
	
	public var width:Float;
	
	public function new( texture:BitmapData, width:Float = 80.0) 
	{
		super( texture);
		
		this.width = width;
	}
	
	override public function init():Void 
	{
		var r:Int = texture.width >> 1;
		
		var mx:Int = canvas.width >> 1;
		var my:Int = canvas.height >> 1;
		
		var pi2 = Math.PI * 0.5;
		
		var r0 = rotation - pi2 + 0.05;
		var r1 = rotation + pi2 - 0.05;
		
		canvas.drawArc( mx, my, 3, r1, r0, 0xFFFF0000);
		
		var vx = Math.cos( rotation);
		var vy = Math.sin( rotation);
		
		var rx:Int = Std.int( vx * 3.0);
		var ry:Int = Std.int( vy * 3.0);
		
		var x0:Int = Std.int( vx * r - vy * width);
		var y0:Int = Std.int( vy * r + vx * width);
		
		var x1:Int = Std.int( vx * r + vy * width);
		var y1:Int = Std.int( vy * r - vx * width);
		
		canvas.drawLine( mx - ry, my + rx, mx + x0, my + y0, 0xFFFF0000);
		canvas.drawLine( mx + ry, my - rx, mx + x1, my + y1, 0xFFFF0000);
	}
	
}