package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.Stage3DEvent;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.WireframePlane;
	
	import controllers.RoleController;
	
	public class Main extends Sprite
	{
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		// Away3D view instances
		private var away3dView : View3D;
		
		// Camera controllers 
		private var hoverController : HoverController;
		
		// Runtime variables
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		private var keyDown:Boolean;
		private var angles:Number = 5;
		private var heroController:RoleController;
		private var speedX:Number=0;
		private var speedZ:Number=0;
		private var speed:Number = 8;
		
		public function Main()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			//			stage.color = 0x0;
			initProxies();
		}
		
		/**
		 * Initialise the Stage3D proxies
		 */
		private function initProxies():void
		{
			// Define a new Stage3DManager for the Stage3D objects
			stage3DManager = Stage3DManager.getInstance(stage);
			
			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0x0;
			stage3DProxy.width = stage.fullScreenWidth;
			stage3DProxy.height = stage.fullScreenHeight;
		}
		
		private function onContextCreated(event : Stage3DEvent) : void {
			initAway3D();
			initObjects();
			initListeners();
		}
		
		/**
		 * Initialise the Away3D views
		 */
		private function initAway3D() : void
		{
			// Create the first Away3D view which holds the cube objects.
			away3dView = new View3D();
			away3dView.stage3DProxy = stage3DProxy;
			away3dView.shareContext = true;
			
			hoverController = new HoverController(away3dView.camera, null, 45, 30, 1200, 5, 89.999);
			
			addChild(away3dView);
			addChild(new AwayStats(away3dView));
		}
		
		private function initObjects() : void 
		{
			away3dView.scene.addChild(new WireframePlane(2500, 2500, 20, 20, 0xbbbb00, 1.5, WireframePlane.ORIENTATION_XZ));
			
			heroController = new RoleController(new Mesh(new CubeGeometry()),stage);
			heroController.setPostion(new Vector3D(0,50,0));
			heroController.setPanAngle(hoverController.panAngle);
			away3dView.scene.addChild(heroController.mesh);
		}
		
		
		/**
		 * Set up the rendering processing event listeners
		 */
		private function initListeners() : void {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event : Event) : void {
			if (mouseDown) 
			{
				hoverController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
				hoverController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				heroController.setPanAngle(0.3 * (stage.mouseX - lastMouseX) + lastPanAngle);
			}
			hoverController.lookAtObject = heroController.mesh;
			away3dView.render();
		}
		
		/**
		 * Handle the mouse down event and remember details for hovercontroller
		 */
		private function onMouseDown(event : MouseEvent) : void {
			mouseDown = true;
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
		}
		
		/**
		 * Clear the mouse down flag to stop the hovercontroller
		 */
		private function onMouseUp(event : MouseEvent) : void {
			mouseDown = false; 
		}
		
	}
}