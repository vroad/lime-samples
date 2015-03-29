package ;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.utils.UInt8Array;

class TextureCache
{
	public var texture:GLTexture;
	public var width (default, null):Int;
	public var height (default, null):Int;
	private var binPack:MaxRectsBinPack;
	
	public function new (width:Int, height:Int)
	{
		
		texture = GL.createTexture ();
		this.width = width;
		this.height = height;
		binPack = new MaxRectsBinPack (width, height);
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.ALPHA, width, height, 0, GL.ALPHA, GL.UNSIGNED_BYTE, new UInt8Array(width * height));
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
	public function dispose ():Void
	{
		
		GL.deleteTexture (texture);
		
	}

	public function addImage (image:Image):SubTexture
	{
		
		var rect:Rect = binPack.quickInsert (image.width + 1, image.height + 1);
		if (rect.height == 0)
			return null;
		rect.width -= 1;
		rect.height -= 1;
		
		GL.bindTexture (GL.TEXTURE_2D, texture);
		GL.pixelStorei (GL.UNPACK_ALIGNMENT, 1);
		GL.texSubImage2D (GL.TEXTURE_2D, 0, rect.x, rect.y, image.width, image.height, GL.ALPHA, GL.UNSIGNED_BYTE, image.buffer.data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
		return new SubTexture (this, rect, Std.int(image.x), Std.int(image.y));
		
	}
}