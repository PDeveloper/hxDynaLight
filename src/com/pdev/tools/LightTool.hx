package com.pdev.tools;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Matrix;

/**
 * ...
 * @author P Svilans
 */

class LightTool 
{
	
	/**
	 * Generates a radial lightmap. Probably going to be enough for 99% of lighting situations.
	 * @param	width Width of the lightmap.
	 * @param	height Height of the lightmap.
	 * @param	brightness The brightest value of the lightmap (at the centre)
	 * @return The lightmap's BitmapData
	 */
	public static function radialLightMap( width:Int, height:Int, brightness:Float):BitmapData
	{
		var bitmap = new BitmapData( width, height, true, 0);
		
		var temp_spr:Shape = new Shape();
		var temp_g:Graphics = temp_spr.graphics;
		
		var grType:GradientType = GradientType.RADIAL;
		
		var grMatrix:Matrix = new Matrix();
		grMatrix.createGradientBox( width, height);
		
		var grCols:Array<Int> = [ 0, 0];
		var grAlphas:Array<Float> = [  brightness, 0];
		var grRatio:Array<Int> = [ 0, 255];
		
		temp_g.beginGradientFill( grType, grCols, grAlphas, grRatio, grMatrix);
		temp_g.drawRect( 0, 0, width, height);
		
		bitmap.draw( temp_spr);
		
		temp_spr = null;
		
		return bitmap;
	}
	
	/**
	 * Generates a palette map for the lights. This defines the actual colour of lights and how lightmaps are translated to actual colours.
	 * @param	colours An array of colours to use as the palette map's gradient.
	 * @param	ratios An array of ratios at which to interpolate the colours. If no array is provided, an array of [ 0, 256] is assumed.
	 * @return A palette map array of colours.
	 */
	public static function paletteMap( colours:Array<Int>, ratios:Array<Int> = null):Array<Int>
	{
		var i:Int;
		var hex:Int;
		
		if ( ratios == null) ratios = [ 0, 256];
		
		var t:Float;
		
		var palette:Array<Int> = new Array<Int>();
		palette[0] = colours[0];
		
		var c1:Dynamic;
		var r1:Float;
		var c2:Dynamic;
		var r2:Float;
		
		var a:Int;
		var r:Int;
		var g:Int;
		var b:Int;
		
		var diff:Float;
		
		for ( i in 1...256)
		{
			var j:Int = 0;
			for ( r in 0...ratios.length)
			{
				if ( i < ratios[r])
				{
					j = r;
					break;
				}
			}
			
			c1 = HEXToARGB( colours[j - 1]);
			c2 = HEXToARGB( colours[j]);
			
			r1 = ratios[ j - 1];
			r2 = ratios[ j];
			
			t = ( i - r1) / ( r2 - r1);
			
			a = c1.a + (c2.a - c1.a) * t;
			r = c1.r + (c2.r - c1.r) * t;
			g = c1.g + (c2.g - c1.g) * t;
			b = c1.b + (c2.b - c1.b) * t;
			
			hex = ARGB2HEX( a, r, g, b);
			
			palette[i] = hex;
		}
		
		palette.reverse();
		
		return palette;
	}
	
	public static inline function ARGB2HEX( a:Int, r:Int, g:Int, b:Int):Int
	{
		return a << 24 | r << 16 | g << 8 | b;
	}
	
	public static inline function HEXToARGB( hex:Int):Dynamic
	{
		var rgbObj:Dynamic = {
			a: (hex >> 24) & 0xFF,
			r: (hex >> 16) & 0xFF,
			g: (hex >> 8) & 0xFF,
			b: hex & 0xFF
		};
		
		return rgbObj;
	}
	
}