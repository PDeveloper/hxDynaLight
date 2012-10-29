package com.pdev.lighting;

/**
 * Simplified class to act as a vector that has Int's as values etc.
 * @author P Svilans
 */

class PointInt 
{
	
	public var x:Int;
	public var y:Int;

	public function new( x:Int = 0, y:Int = 0) 
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function cross( p:PointInt):Float
	{
		return x * p.y - y * p.x;
	}
	
	public inline function length():Float
	{
		return Math.sqrt( x * x + y * y);
	}
	
	public inline function len_2():Float
	{
		return x * x + y * y;
	}
	
}