package lzm.starling.swf.components.feathers
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.TextInput;
	
	import lzm.starling.swf.components.ISwfComponent;
	import lzm.starling.swf.display.SwfSprite;
	
	import starling.display.DisplayObject;
	import starling.text.TextField;
	
	public class FeathersTextInput extends TextInput implements ISwfComponent
	{
		public function FeathersTextInput()
		{
			super();
		}
		
		public function initialization(componetContent:SwfSprite):void{
			var _backgroundSkin:DisplayObject = componetContent.getChildByName("_backgroundSkin");
			var _backgroundDisabledSkin:DisplayObject = componetContent.getChildByName("_backgroundDisabledSkin");
			var _backgroundFocusedSkin:DisplayObject = componetContent.getChildByName("_backgroundFocusedSkin");
			
			var _textFormat:TextField = componetContent.getTextField("_textFormat");
			
			if(_backgroundSkin){
				this.backgroundSkin = _backgroundSkin;
				_backgroundSkin.removeFromParent();
			}
			if(_backgroundDisabledSkin){
				this.backgroundDisabledSkin = _backgroundDisabledSkin;
				_backgroundDisabledSkin.removeFromParent();
			}
			if(_backgroundFocusedSkin){
				this.backgroundFocusedSkin = _backgroundFocusedSkin;
				_backgroundFocusedSkin.removeFromParent();
			}
			
			if(_textFormat != null){
				this.textEditorProperties.fontFamily = _textFormat.fontName;
				this.textEditorProperties.fontSize = _textFormat.fontSize;
				this.textEditorProperties.color = _textFormat.color;
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.font = _textFormat.fontName;
				textFormat.size = _textFormat.fontSize;
				textFormat.color = _textFormat.color;
				
				this.promptProperties.textFormat = textFormat;
				this.prompt = _textFormat.text;
			}
			componetContent.removeFromParent(true);
		}
		
		public function get editableProperties():Object{
			return {
				prompt:prompt,
				displayAsPassword:displayAsPassword,
				maxChars:maxChars,
				isEditable:isEditable
			};
		}
		
		public function set editableProperties(properties:Object):void{
			for(var key:String in properties){
				this[key] = properties[key];
			}
		}
	}
}