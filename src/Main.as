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
	import away3d.library.AssetLibrary;
	import away3d.lights.DirectionalLight;
	import away3d.loaders.parsers.MD2Parser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;
	
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	
	import role.AWPRoleController;
	import role.AnimationSequence;
	
	public class Main extends Sprite
	{
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		private var away3dView : View3D;
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		private var hoverController : HoverController;
		private var _world:AWPDynamicsWorld;
		
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		private var keyDown:Boolean;
		private var speed:Number = 8;
		
		private var _stepTime:Number = 1/60;
		
		[Embed(source="/../embeds/arid.jpg")]
		private const floorSkin:Class;
		
		[Embed(source="/../embeds/pknight2.png")]
		public static var PKnightTexture3:Class;
		
		[Embed(source="/../embeds/pknight.md2", mimeType="application/octet-stream")]
		public static var PKnightModel:Class;
		
		private var _heroController:AWPRoleController;
		
		private var _debug:AWPDebugDraw;
		
		public function Main()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			initProxies();
		}
		
		/**
		 * Initialise the Stage3D proxies
		 */
		private function initProxies():void
		{
			stage3DManager = Stage3DManager.getInstance(stage);
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
		}
		
		/**
		 * Initialise the Away3D views
		 */
		private function initAway3D() : void
		{
			away3dView = new View3D();
			away3dView.stage3DProxy = stage3DProxy;
			away3dView.shareContext = true;
			
			_world=AWPDynamicsWorld.getInstance();
			_world.initWithDbvtBroadphase();
			_world.collisionCallbackOn = true;
			_debug = new AWPDebugDraw(away3dView,_world);
			
			_light = new DirectionalLight();
			_lightPicker = new StaticLightPicker([_light]);
			away3dView.scene.addChild(_light);
			
			addChild(away3dView);
			addChild(new AwayStats(away3dView));
		}
		
		private function initObjects() : void 
		{
			hoverController = new HoverController(away3dView.camera, null, 45, 30, 1200, 5, 89.999);
			
			var floorMaterial:TextureMaterial = new TextureMaterial(new BitmapTexture(new floorSkin().bitmapData),true,true);
			floorMaterial.shadowMethod = new FilteredShadowMapMethod(_light);
			floorMaterial.lightPicker = _lightPicker;
			var plane:Mesh = new Mesh(new CubeGeometry(10000,10,10000),floorMaterial);
			plane.geometry.scaleUV(10,10);
			plane.geometry.convertToSeparateBuffers();
			away3dView.scene.addChild(plane);
			
			var sceneShape:AWPBoxShape = new AWPBoxShape(10000,10,10000);
			var sceneBody:AWPRigidBody = new AWPRigidBody(sceneShape, plane);
			sceneBody.position = plane.position;
			_world.addRigidBody(sceneBody);
			
			AssetLibrary.enableParser(MD2Parser);
			var heroSequence:AnimationSequence = new AnimationSequence(new PKnightModel(), new PKnightTexture3());
			heroSequence.addEventListener(Event.COMPLETE,function onComplete(evt:Event):void{
				heroSequence.removeEventListener(Event.COMPLETE,onComplete);
				var scale:Number = 5;
				var redis:Number = 30*scale;
				heroSequence.scale(scale);
				heroSequence.pivotPoint = new Vector3D(0,8);
				heroSequence.position = new Vector3D(0,redis*.5 + 8);
					
				var heroShape:AWPSphereShape = new AWPSphereShape(redis);
				var heroObj:AWPGhostObject = new AWPGhostObject(heroShape,heroSequence);
				heroObj.addEventListener(AWPEvent.COLLISION_ADDED,collisionHandler);
				
				_heroController = new AWPRoleController(heroObj,_stepTime,stage);
				_heroController.warp(heroSequence.position);
				_heroController.setPanAngle(hoverController.panAngle + 90);
				_world.addCharacter(_heroController);
				
				var cubeMesh:Mesh=new Mesh(new CubeGeometry(100,500,100));
				cubeMesh.material=new ColorMaterial();
				cubeMesh.material.lightPicker = _lightPicker
				
				cubeMesh.position = new Vector3D(230,250,0);
				var cubeShape:AWPBoxShape=new AWPBoxShape(100,500,100);
				var cube:AWPRigidBody =new AWPRigidBody(cubeShape,cubeMesh,100); 
				cube.position = cubeMesh.position;
				cube.friction = 0.9;
				_world.addRigidBody(cube);
				
				away3dView.scene.addChild(heroSequence);
				away3dView.scene.addChild(cubeMesh);
				
				initListeners();
			});
		}
		
		private function collisionHandler(evt:AWPEvent):void
		{
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
				hoverController.tiltAngle =  0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
				hoverController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				_heroController.setPanAngle(hoverController.panAngle + 90);
			}
			
			hoverController.lookAtPosition = _heroController.ghostObject.position;
			_world.step(_stepTime,1,_stepTime);
//			_debug.debugDrawWorld();
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