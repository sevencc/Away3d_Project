package lzm.starling.swf.display
{
	import feathers.display.TiledImage;
	
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	/**
	 * 使用纹理填充的图片(纹理长宽需要为2的幂数) 
	 * @author zmliu
	 * 
	 */	
	public class SwfShapeImage extends TiledImage
	{
		/** 导出的链接名 */
		public var classLink:String;
		
		public function SwfShapeImage(texture:Texture)
		{
			super(texture,texture.scale);
			smoothing = TextureSmoothing.NONE;
		}
	}
}


