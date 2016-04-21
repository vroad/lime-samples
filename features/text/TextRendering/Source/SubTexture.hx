package;

class SubTexture
{
	public var textureCache:TextureCache;
	public var rect:Rect;
	public var textureWidth (get, never):Int;
	public var textureHeight (get, never):Int;
	public var x:Int;
	public var y:Int;
	
	public function new(textureCache:TextureCache, rect:Rect, x:Int, y:Int) 
	{
		
		this.textureCache = textureCache;
		this.rect = rect;
		this.x = x;
		this.y = y;
		
	}
	
	@:noCompletion private function get_textureWidth():Int { return textureCache.width; }
	@:noCompletion private function get_textureHeight():Int { return textureCache.height; }
	
}