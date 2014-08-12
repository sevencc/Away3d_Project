package role
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import awayphysics.dynamics.AWPRigidBody;
	
	public class AWPRididController extends RoleController
	{
		protected var _target:AWPRigidBody;
		protected var _sequence:AnimationSequence;
		
		public function AWPRididController(p_stage:Stage,target:AWPRigidBody)
		{
			super(p_stage);
			_target = target;
			_sequence = AnimationSequence(_target.skin);
		}
		
		override protected function enterHandler(evt:Event):void
		{
			var vx:Number = 0;
			super.enterHandler(evt);
			
			var move:Boolean = false;
			vx +=90;
			if(_keyUp||_keyDown||_keyRight||_keyLeft)
			{
				_sequence.changeAnimation("walk");
				move = true;
			}else{
				_sequence.changeAnimation("idle");
			}
			if(move)
			{
				_target.x -= speed * Math.sin((_sequence.mesh.rotationY - vx)/ 180 * Math.PI);
				_target.z -= speed * Math.cos((_sequence.mesh.rotationY - vx)/ 180 * Math.PI);
			}
		}
		
		public function warp(pos:Vector3D):void
		{
			_target.position = pos;
		}
		override public function setPanAngle(p_panAngle:Number):void
		{
			_sequence.mesh.rotationY = p_panAngle;
		}
		public function get body():AWPRigidBody
		{
			return _target;
		}
	}
}