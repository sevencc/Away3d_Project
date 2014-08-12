package role
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPEvent;

	public class AWPRoleController extends AWPKinematicCharacterController
	{
		private var _stage:Stage;
		private var _ans:AnimationSequence;
		public var speed:Number=20;
		public var angleValue:Number=6;
		
		private var _keyUp:Boolean;
		private var _keyDown:Boolean;
		private var _keyLeft:Boolean;
		private var _keyRight:Boolean;
		
		public function AWPRoleController(ghostObject : AWPGhostObject, stepHeight : Number,stage:Stage)
		{
			super(ghostObject,stepHeight);
			_stage = stage;
			_ans = ghostObject.skin as AnimationSequence;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			_stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			_stage.addEventListener(Event.ENTER_FRAME,enterHandler);
			
			ghostObject.addEventListener(AWPEvent.RAY_CAST,rayCastHandler);
			ghostObject.addRay(new Vector3D,new Vector3D(1000,0,0));
		}
		
		private function keyDownHandler(evt:KeyboardEvent):void
		{
			switch(evt.keyCode)
			{
				case Keyboard.W:
					_keyUp = true;
					_keyDown = false;
					speed = 20;
					break;
				case Keyboard.S:
					_keyUp = false;
					_keyDown = true;
					speed = 20;
					break;
				case Keyboard.A:
					_keyLeft = true;
					_keyRight = false;
					speed = 20;
					break;
				case Keyboard.D:
					_keyLeft = false;
					_keyRight = true;
					speed = 20;
					break;
				case Keyboard.SPACE:
					if(canJump())
					{
						jumpSpeed = 10;
						jump();
						_ans.changeAnimation("jump");
					}
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
			vx +=90;
			
			var move:Boolean = false;
			if(canJump())
			{
				if(_keyUp||_keyDown||_keyRight||_keyLeft)
				{
					_ans.changeAnimation("walk");
					move = true;
				}else{
					_ans.changeAnimation("idle");
				}
			}else{
				move = true;
			}
			if(move)
			{
				ghostObject.x -= speed * Math.sin((_ans.mesh.rotationY - vx)/ 180 * Math.PI);
				ghostObject.z -= speed * Math.cos((_ans.mesh.rotationY - vx)/ 180 * Math.PI);
//				ghostObject.rays[0].rayTo = new Vector3D(speed * Math.sin((_ans.mesh.rotationY - vx)/ 180 * Math.PI),speed * Math.cos((_ans.mesh.rotationY - vx)/ 180 * Math.PI));
			}
		}
		
		private function rayCastHandler(evt:AWPEvent):void
		{
			trace("------")
		}
		
		public function setPanAngle(p_angle:Number):void
		{
			_ans.mesh.rotationY = p_angle;
		}
		
	}
}