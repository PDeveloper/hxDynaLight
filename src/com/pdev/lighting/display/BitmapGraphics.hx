package com.pdev.lighting.display;
import flash.display.BitmapData;

/**
 * ...
 * @author P Svilans
 */

class BitmapGraphics 
{
	
	/**
	 * Draw a line to a bitmapData.
	 * @param	canvas The target BitmapData.
	 * @param	x0 Starting x coordinate.
	 * @param	y0 Starting y coordinate.
	 * @param	x1 Ending x coordinate.
	 * @param	y1 Ending y coordinate.
	 * @param	color Color to draw.
	 */
	
	public static inline function drawLine( canvas:BitmapData, x0:Int, y0:Int, x1:Int, y1:Int, color:Int = 0 ):Void
	{
		var yLonger:Bool = false;
		var incrementVal:Int, endVal:Int;
		
		var shortLen:Int = y1 - y0;
		var longLen:Int = x1 - x0;
		
		if (Math.abs( shortLen) > Math.abs( longLen))
		{
			var swap:Int = shortLen;
			shortLen = longLen;
			longLen = swap;
			yLonger = true;
		}
		
		endVal = longLen;
		if (longLen < 0)
		{
			incrementVal = -1;
			longLen = -longLen;
		}
		else incrementVal = 1;
		
		var decInc:Float;
		
		if (longLen == 0) decInc = shortLen;
		else decInc = (shortLen / longLen);
		
		var i:Int = 0;
		var j:Float = 0;
		if (yLonger)
		{
			while ( i != endVal)
			{
				canvas.setPixel32( Std.int( x0 + j), y0 + i, color);
				j += decInc;
				
				i += incrementVal;
			}
		}
		else
		{
			while ( i != endVal)
			{
				canvas.setPixel32( x0 + i, Std.int( y0 + j), color);
				j += decInc;
				
				i += incrementVal;
			}
		}
		
		canvas.setPixel32( x1, y1, color);
	}
	
	/**
	 * Draw a circle to a bitmapData
	 * @param	canvas	The target BitmapData.
	 * @param	x		The x position of the circle.
	 * @param	y		The y position of the circle.
	 * @param	radius	Radius of the circle.
	 * @param	color	Color to draw.
	 */
	
	public static inline function drawCircle( canvas:BitmapData, x0:Int, y0:Int, radius:Int, color:Int = 0 ):Void
	{
		var error:Int = -radius;
		var x:Int = radius;
		var y:Int = 0;
		
		canvas.setPixel32( x0, y0 - radius, color);
		
		while (x > y)
		{
			canvas.setPixel32(x0 + x, y0 + y, color);
			if (x != 0) canvas.setPixel32(x0 - x, y0 + y, color);
			if (y != 0) canvas.setPixel32(x0 + x, y0 - y, color);
			if (x != 0 && y != 0) canvas.setPixel32(x0 - x, y0 - y, color);
			canvas.setPixel32(x0 + y, y0 + x, color);
			if (x != 0) canvas.setPixel32(x0 - y, y0 + x, color);
			if (y != 0) canvas.setPixel32(x0 + y, y0 - x, color);
			if (x != 0 && y != 0) canvas.setPixel32(x0 - y, y0 - x, color);
			
			
			error += y;
			++y;
			error += y;
			
			if (error >= 0)
			{
				--x;
				error -= x;
				error -= x;
			}
		}
		
		canvas.setPixel32(x0 + y, y0 + x, color);
		if (x != 0) canvas.setPixel32(x0 - y, y0 + x, color);
		if (y != 0) canvas.setPixel32(x0 + y, y0 - x, color);
		if (x != 0 && y != 0) canvas.setPixel32(x0 - y, y0 - x, color);
	}
	
	/**
	 * Draw an arc to a bitmapData
	 * @param	canvas	The target BitmapData.
	 * @param	x0		The x position of the arc.
	 * @param	y0		The y position of the arc.
	 * @param	r		The radius of the arc.
	 * @param	t1		Starting angle of the arc, in radians.
	 * @param	t2		Ending angle of the arc, in radians.
	 * @param	color	Color to draw.
	 */
	
	public static inline function drawArc( canvas:BitmapData, x0: Int, y0: Int, radius: Int, r1:Float, r2:Float, color:Int = 0 ):Void
	{
		var x: Int, y: Int, g: Int, dx: Int, dxdy: Int;
		var Dxa: Int, Dya: Int, Dxb: Int, Dyb: Int;
		var small:Bool;
		
		r1 -= Math.PI * 0.5;
		r2 -= Math.PI * 0.5;

	/* get start and stop angles from user */
		if (r2 < r1) r2 += 2 * Math.PI;
		if ((r2 - r1) < Math.PI) small = true;
		else small = false;
		
	/* initialize line draw variables for arc boundary lines */
		Dxa = Std.int( 1000 * Math.cos( r1));
		Dya = Std.int( 1000 * Math.sin( r1));
		Dxb = Std.int( 1000 * Math.cos( r2));
		Dyb = Std.int( 1000 * Math.sin( r2));
		
	/* initialize circle draw variables */
		x = 0;
		y = radius;
		g = 3 - (radius << 1);
		dxdy = 10 - (radius << 2);
		dx = 6;
		
		var S1a: Int, S2a: Int, S5a: Int, S6a: Int, S3a: Int, S4a: Int, S0a: Int, S7a: Int, S1b: Int, S2b: Int, S5b: Int, S6b: Int, S3b: Int, S4b: Int, S0b: Int, S7b: Int;
		
	/* initialize line variables */
		S1a = S2a = radius * Dxa;
		S5a = S6a = -S1a;
		S3a = S4a = radius * Dya;
		S0a = S7a = -S3a;
		S1b = S2b = radius * Dxb;
		S5b = S6b = -S1b;
		S3b = S4b = radius * Dyb;
		S0b = S7b = -S3b;
		
	/* main circle (arc) routine */
		while (x <= y)
		{
			if ( small)
			{
				if (S1a > 0 && S1b < 0) 
					canvas.setPixel32( x0 - y, y0 + x, color);//bmp[18+y][18+x] = 1;        /* P1 */
				if (S2a > 0 && S2b < 0) 
					canvas.setPixel32( x0 - y, y0 - x, color);//bmp[18+y][18-x] = 1;        /* P2 */
				if (S6a > 0 && S6b < 0) 
					canvas.setPixel32( x0 + y, y0 + x, color);//bmp[18-y][18+x] = 1;        /* P6 */
				if (S5a > 0 && S5b < 0) 
					canvas.setPixel32( x0 + y, y0 - x, color);//bmp[18-y][18-x] = 1;        /* P5 */
				if (S0a > 0 && S0b < 0) 
					canvas.setPixel32( x0 - x, y0 + y, color);//bmp[18+x][18+y] = 1;        /* P0 */
				if (S3a > 0 && S3b < 0) 
					canvas.setPixel32( x0 - x, y0 - y, color);//bmp[18+x][18-y] = 1;        /* P3 */
				if (S7a > 0 && S7b < 0) 
					canvas.setPixel32( x0 + x, y0 + y, color);//bmp[18-x][18+y] = 1;        /* P7 */
				if (S4a > 0 && S4b < 0) 
					canvas.setPixel32( x0 + x, y0 - y, color);//bmp[18-x][18-y] = 1;        /* P4 */
			}
			else
			{
				if (S1a > 0 || S1b < 0) 
					canvas.setPixel32( x0 - y, y0 + x, color);//bmp[18+y][18+x] = 1;        /* P1 */
				if (S2a > 0 || S2b < 0) 
					canvas.setPixel32( x0 - y, y0 - x, color);//bmp[18+y][18-x] = 1;        /* P2 */
				if (S6a > 0 || S6b < 0) 
					canvas.setPixel32( x0 + y, y0 + x, color);//bmp[18-y][18+x] = 1;        /* P6 */
				if (S5a > 0 || S5b < 0)
					canvas.setPixel32( x0 + y, y0 - x, color);//bmp[18-y][18-x] = 1;        /* P5 */
				if (S0a > 0 || S0b < 0) 
					canvas.setPixel32( x0 - x, y0 + y, color);//bmp[18+x][18+y] = 1;        /* P0 */
				if (S3a > 0 || S3b < 0) 
					canvas.setPixel32( x0 - x, y0 - y, color);//bmp[18+x][18-y] = 1;        /* P3 */
				if (S7a > 0 || S7b < 0) 
					canvas.setPixel32( x0 + x, y0 + y, color);//bmp[18-x][18+y] = 1;        /* P7 */
				if (S4a > 0 || S4b < 0) 
					canvas.setPixel32( x0 + x, y0 - y, color);//bmp[18-x][18-y] = 1;        /* P4 */
			}
			
			if (g >= 0)
			{
				g += dxdy;
				dxdy += 8;
				y--;
				S0a += Dya;
				S1a -= Dxa;
				S2a -= Dxa;
				S3a -= Dya;
				S4a -= Dya;
				S5a += Dxa;
				S6a += Dxa;
				S7a += Dya;
				S0b += Dyb;
				S1b -= Dxb;
				S2b -= Dxb;
				S3b -= Dyb;
				S4b -= Dyb;
				S5b += Dxb;
				S6b += Dxb;
				S7b += Dyb;
			}
			else
			{
				g += dx;
				dxdy += 4;
			}
			
			dx += 4;
			x++;
			S0a += Dxa;
			S1a -= Dya;
			S2a += Dya;
			S3a += Dxa;
			S4a -= Dxa;
			S5a += Dya;
			S6a -= Dya;
			S7a -= Dxa;
			S0b += Dxb;
			S1b -= Dyb;
			S2b += Dyb;
			S3b += Dxb;
			S4b -= Dxb;
			S5b += Dyb;
			S6b -= Dyb;
			S7b -= Dxb;
		}
	}
	
	public static inline function fastFill( canvas:BitmapData, x0:Int, y0:Int, color:Int=0):Void
	{
		
	}
	
}