package;


import haxe.io.Bytes;
import lime.app.Application;
import lime.graphics.opengl.*;
import lime.graphics.Image;
import lime.graphics.RenderContext;
import lime.math.Matrix4;
import lime.utils.ByteArray;
import lime.utils.Float32Array;
import lime.utils.GLUtils;
import lime.Assets;
import lime.utils.UInt8Array;
import lime.video.VideoLib;
import lime.video.Video;

class Main extends Application {
	
	
	private var buffer:GLBuffer;
	private var matrixUniform:GLUniformLocation;
	private var program:GLProgram;
	private var texture:GLTexture;
	private var textureAttribute:Int;
	private var vertexAttribute:Int;
	
	private var videoLib:VideoLib;
	private var video:Video;
	private var videoTexture:GLTexture;
	
	private var imageUniform:GLUniformLocation;
	
	public function new () {
		
		super ();
		
	}
	
	
	public override function render (context:RenderContext):Void {
		
		if (video == null) {
			
			videoLib = new VideoLib ();
			video = videoLib.createVideo ();
			if (!video.openFile ("bbb_sunflower_1080p_60fps_normal.mp4"))
				trace("Failed to open video file");
			
		}
		
		if (videoTexture == null && video.state == Paused) {
			
			switch (context) {
				
				case OPENGL (gl):
					
					videoTexture = gl.createTexture ();
					video.setTexture (videoTexture);
					
				default:
					
			}
			if (!video.play ())
				trace("Failed to play video");
			
			switch (context) {
				
				case OPENGL (gl):
					
					var vertexSource = 
						
						"attribute vec4 aPosition;
						attribute vec2 aTexCoord;
						varying vec2 vTexCoord;
						
						uniform mat4 uMatrix;
						
						void main(void) {
							
							vTexCoord = aTexCoord;
							gl_Position = uMatrix * aPosition;
							
						}";
					
					var fragmentSource = 
						
						"#if GL_ES\n" +
						"precision highp float;\n" +
						"#endif\n" +
						"varying vec2 vTexCoord;
						uniform sampler2D uImage0;
						
						void main(void)
						{
							gl_FragColor = texture2D (uImage0, vTexCoord);
						}";
					
					program = GLUtils.createProgram (vertexSource, fragmentSource);
					gl.useProgram (program);
					
					vertexAttribute = gl.getAttribLocation (program, "aPosition");
					textureAttribute = gl.getAttribLocation (program, "aTexCoord");
					matrixUniform = gl.getUniformLocation (program, "uMatrix");
					imageUniform = gl.getUniformLocation (program, "uImage0");
					
					gl.enableVertexAttribArray (vertexAttribute);
					gl.enableVertexAttribArray (textureAttribute);
					
					var width = window.width;
					var height = window.height;
					
					var data = [
						
						width, height, 0, 1, 1,
						0, height, 0, 0, 1,
						width, 0, 0, 1, 0,
						0, 0, 0, 0, 0
						
					];
					
					buffer = gl.createBuffer ();
					gl.bindBuffer (gl.ARRAY_BUFFER, buffer);
					gl.bufferData (gl.ARRAY_BUFFER, new Float32Array (data), gl.STATIC_DRAW);
					gl.bindBuffer (gl.ARRAY_BUFFER, null);				
					
					var r = ((config.background >> 16) & 0xFF) / 0xFF;
					var g = ((config.background >> 8) & 0xFF) / 0xFF;
					var b = (config.background & 0xFF) / 0xFF;
					var a = ((config.background >> 24) & 0xFF) / 0xFF;
					
					gl.clearColor (r, g, b, a);
				
				default:
				
			}
			
		}
		
		switch (context) {
			
			case OPENGL (gl):
				
				gl.viewport (0, 0, window.width, window.height);	
				
				gl.clear (gl.COLOR_BUFFER_BIT);
				
				var matrix = Matrix4.createOrtho (0, window.width, window.height, 0, -1000, 1000);
				gl.uniformMatrix4fv (matrixUniform, false, matrix);
				
				gl.bindTexture (gl.TEXTURE_2D, videoTexture);
				gl.activeTexture(gl.TEXTURE0);
				gl.uniform1i (imageUniform, 0);
				
				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				
				#if desktop
				gl.enable (gl.TEXTURE_2D);
				#end
				
				gl.bindBuffer (gl.ARRAY_BUFFER, buffer);
				gl.vertexAttribPointer (vertexAttribute, 3, gl.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer (textureAttribute, 2, gl.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
				
				gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
				
			default:
			
		}
		
	}
	
	
}