package com.pdev.lighting.occlusion;
import com.pdev.lighting.Light;
import com.pdev.lighting.PointInt;
import de.polygonal.ds.SLL;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * ...
 * @author P Svilans
 */

interface ILightOccluder 
{
	
	public var x:Int;
	public var y:Int;
	public var rotation:Float;
	public var bounds(get_bounds, null):Rectangle;
	public function init( light:Light):SLL<PointInt>;
	
}