package controllers
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import away3d.entities.Mesh;

	public class RoleController extends Sprite
	{
		public var speed:Number=8;
		public var angleValue:Number=3;
		
		private var _stage:Stage;
		private var _role:Mesh;
		
		private var _keyUp:Boolean;
		private var _keyDown:Boolean;
		private var _keyLeft:Boolean;
		private var _keyRight:Boolean;
			
		public function RoleController(p_roleMesh:Mesh,p_stage:Stage)
		{
			_role = p_roleMesh;
			_stage = p_stage;
			
			_stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			_stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			this.addEventListener(Event.ENTER_FRAME,enterHandler);
		}
		
		private function keyDownHandler(evt:KeyboardEvent):void
		{
			switch(evt.keyCode)
			{
				case Keyboard.W:
					_keyUp = true;
					_keyDown = false;
					break;
				case Keyboard.S:
					_keyUp = false;
					_keyDown = true;
					break;
				case Keyboard.A:
					_keyLeft = true;
					_keyRight = false;
					break;
				case Keyboard.D:
					_keyLeft = false;
					_keyRight = true;
					break;
			}
		}
		
		private function keyUpHandler(evt:KeyboardEvent):void
		{
			switch(evt.keyCode)
			{
				case Keyboard.W:
				_keyUp = false;
				break;
				case Keyboard.S:
				_keyDown = false;
				break;
				case Keyboard.A:
				_keyLeft = false;
				_keyRight = false;
				break;
				case Keyboard.D:
				_keyLeft = false;
				_keyRight = false;
				break;
			}
		}
		
		
		private function enterHandler(evt:Event):void
		{
			var vx:Number = 0;
			if(_keyUp)
			{
				if(_keyLeft)
				{
					vx = 45;
				}else if(_keyRight){
					vx = -45;
				}
			}else if(_keyDown)
			{
				vx = 180;
				if(_keyLeft)
				{
					vx = 135;
				}else if(_keyRight){
					vx = -135;
				}
			}else if(_keyLeft){
				vx = 90;
			}
			else if(_keyRight){
				vx = 270;
			}
			
			if(_keyUp||_keyDown||_keyRight||_keyLeft)
			{
				_role.x -= speed * Math.sin((_role.rotationY - vx)/ 180 * Math.PI);
				_role.z -= speed * Math.cos((_role.rotationY - vx)/ 180 * Math.PI);
			}
		}
		
		public function setPostion(p_pos:Vector3D):void
		{
			_role.position = p_pos;
		}
		
		public function setPanAngle(p_panAngle:Number):void
		{
			_role.rotationY = p_panAngle;
		}
		
		public function get mesh():Mesh
		{
			return _role;
		}
	}
}