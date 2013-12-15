package ;

import com.pdev.lighting.Light;
import com.pdev.lighting.LightEngine;
import com.pdev.lighting.occlusion.ShadowCircle;
import com.pdev.lighting.occlusion.ShadowSegment;
import com.pdev.lighting.PointInt;
import com.pdev.tools.LightTool;
import de.polygonal.ds.SLL;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

/**
 * ...
 * @author P Svilans
 */

class Main
{
	private var object:ShadowSegment;
	private var circle:ShadowCircle;
	
	private var engine:LightEngine;
	
	private var i:Float;
	
	private var canvas:BitmapData;
	
	private var light1:Light;
	private var light2:Light;
	private var light3:Light;
	
	function new() 
	{
		// Create an example object.
		object = new ShadowSegment();
		object.add( new PointInt( -10, -10));
		object.add( new PointInt( 15, -10));
		object.add( new PointInt( 3, 15));
		object.add( new PointInt( -10, 10));
		// Make the object a polygon.
		object.isClosed = true;
		
		// Create a circle.
		circle = new ShadowCircle( 20);
		circle.x = 300;
		circle.y = 300;
		
		// Create the canvas. This defines the size of the rendered area, so this should typically be the size of your stage.
		canvas = new BitmapData( 500, 500, true, 0x00000000);
		
		// Create 3 example lights
		light1 = new Light( LightTool.radialLightMap( 450, 450, 0.9));
		light1.x = 225;
		light1.y = 225;
		
		light2 = new Light( LightTool.radialLightMap( 450, 450, 0.8));
		light2.x = 450;
		light2.y = 250;
		
		
		light3 = new Light( LightTool.radialLightMap( 250, 250, 0.6));
		light3.x = 320;
		light3.y = 320;
		
		// Make le engine
		engine = new LightEngine();
		
		// Add the lights and the object/circle.
		engine.addLight( light1);
		engine.addLight( light2);
		engine.addLight( light3);
		//engine.addOccluder( circle);
		
		// Uncomment the following to make 100 little cute boxes.
		make100RandomBoxes();
		
		// Add the canvas and add it to the stage.
		Lib.current.addChild( new Bitmap( canvas));
		
		// Variable to just move the lights etc.
		i = 0;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterframe);
	}
	
	private function make100RandomBoxes():Void
	{
		for ( i in 0...100)
		{
			var obj:ShadowSegment = new ShadowSegment( Std.int( Math.random() * 500), Std.int( Math.random() * 500));
			obj.add( new PointInt( -5, -5));
			obj.add( new PointInt( 5, -5));
			obj.add( new PointInt( 5, 5));
			obj.add( new PointInt( -5, 5));
			
			obj.isClosed = true;
			
			engine.addOccluder( obj);
		}
	}
	
	private function enterframe( e:Event):Void
	{
		// Move the lights and circle and etc. and have fun...yaaay.
		circle.x = Std.int( Lib.current.mouseX);
		circle.y = Std.int( Lib.current.mouseY);
		light1.x = Std.int( Math.cos( i) * 200 + 250);
		light1.y = Std.int( Math.sin( i * 1.3) * 150 + 250);
		light2.x = Std.int( Math.cos( i * 1.1) * 50 + 350);
		light2.y = Std.int( Math.sin( i) * 150 + 300);
		i += 0.01;
		
		// Render yo.
		engine.render( canvas, 0, 0);
	}
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		
		new Main();
	}
	
}