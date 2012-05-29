//
//  Sprite.mm
//  InvaderR
//
//  Created by Richard Adem on 28/01/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#import "Sprite.h"
#include "OpenGLCommon.h"

static const Vector3D s_normals[] = 
{
	{0.0, 0.0, 1.0},
	{0.0, 0.0, 1.0},
	{0.0, 0.0, 1.0},
	{0.0, 0.0, 1.0},
};

// -----------------------------------------------------

Sprite::Sprite(float x, float y, NSString* file)
: GameMoveableObject()
, m_glTexture(0)
, m_width(0)
, m_height(0)
, m_vertexBufferObject(0)
, m_indexBufferObject(0)
{
	Point2D point;
	point.x = x;
	point.y = y;
	setPos(point);
	
	Load(file);
	SetupVBO();
}

Sprite::Sprite()
: GameMoveableObject()
, m_glTexture(0)
, m_width(0)
, m_height(0)
, m_vertexBufferObject(0)
, m_indexBufferObject(0)
{
}

Sprite* Sprite::Create(float x, float y, NSString* file)
{
	Sprite* sprite = new Sprite(x, y, file);
	return sprite;
}

Sprite::~Sprite()
{
	glDeleteBuffers(1, &m_indexBufferObject);
	glDeleteBuffers(1, &m_vertexBufferObject);	
}

#define PIXEL_COUNT 1

#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3

#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

#define NUMBER_OF_CUBE_INDICES 4 * PIXEL_COUNT

void Sprite::Draw()
{
	GameMoveableObject::Draw();
	
	// draw the texture
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	glFrontFace(GL_CW /* or GL_CCW */);
	glEnable(GL_CULL_FACE); // glDisable(GL_CULL_FACE); //
	//glColor4f(1.0, 1.0, 1.0, 1.0);
    
    //glEnableClientState(GL_VERTEX_ARRAY);
    //glEnableClientState(GL_NORMAL_ARRAY);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	//const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	const GLsizeiptr texCor_size = 2 * 4 * sizeof(GLfloat);
	//const GLsizeiptr normal_size = 4 * 4 * sizeof(GLfloat);
	
	glLoadIdentity();
	
    glBindTexture(GL_TEXTURE_2D, m_glTexture);
	glTranslatef(m_pos.y, m_pos.x, -0.0);
	
	// Activate the VBOs to draw
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	//glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
	glTexCoordPointer(2, GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size/* + colour_size*/));
	glNormalPointer(GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size + /*colour_size +*/ texCor_size));
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferObject);
	
	// This could actually be moved into the setup since we never disable it
	glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	// This is the actual draw command
	glDrawElements(GL_TRIANGLE_STRIP, NUMBER_OF_CUBE_INDICES, GL_UNSIGNED_BYTE, (GLvoid*)((char*)NULL)); // GL_TRIANGLE_STRIP
	
	GLenum gl_error = glGetError();
	if (GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}	
	
	glDisableClientState(GL_VERTEX_ARRAY);
	//glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	
	//glDisableClientState(GL_VERTEX_ARRAY);
	//glDisableClientState(GL_NORMAL_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

void Sprite::Load(NSString* file)
{
	// Bind the number of textures we need, in this case one.
	glGenTextures(1, &m_glTexture);
	glBindTexture(GL_TEXTURE_2D, m_glTexture);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST); // GL_LINEAR
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST); // GL_LINEAR
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// -----------------------------------
	
	NSString *path;
	//path = [[NSBundle mainBundle] pathForResource:file ofType:@""];
	//path = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"];
	
	//NSString* theFileName = [[file lastPathComponent] stringByDeletingPathExtension];
	// pathExtension
	
	path = [[NSBundle mainBundle] pathForResource:[[file lastPathComponent] stringByDeletingPathExtension] ofType:[[file lastPathComponent] pathExtension]];
	
	NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	
	if (image == nil)
		Log(@"Do real error checking here");
	
	m_width = CGImageGetWidth(image.CGImage);
	m_height = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	GLvoid *imageData = malloc(m_height * m_width * 4);
	CGContextRef context = CGBitmapContextCreate(imageData, m_width, m_height, 8, 4 * m_width, colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	// Flip the Y-axis
	CGContextTranslateCTM(context, 0, m_height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGColorSpaceRelease(colorSpace);
	CGContextClearRect(context, CGRectMake( 0, 0, m_width, m_height ));
	CGContextDrawImage(context, CGRectMake( 0, 0, m_width, m_height ), image.CGImage);
	
//glTexImage2D (GLenum target
//	, GLint level
//	, GLint internalformat
//	, GLsizei width
//	, GLsizei height
//	, GLint border
//	, GLenum format
//	, GLenum type
//	, const GLvoid *pixels);	
	
	Log(@"GL_MAX_TEXTURE_SIZE %D", GL_MAX_TEXTURE_SIZE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_width, m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_width, m_height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, imageData);
	
	{
		GLenum gl_error = glGetError();
		if (GL_NO_ERROR != gl_error)
		{
			Log(@"Error: %d", gl_error);
		}
	}
	
	CGContextRelease(context);
	
	free(imageData);
	[image release];
	[texData release];
	
	// ------------------------------------------------
	
	
}

void Sprite::SetupVBO()
{
	GLenum error = glGetError();
	if (error != 0)
		Log(@"GL error: %d", error);
	
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	//const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	const GLsizeiptr texCor_size = 2 * 4 * sizeof(GLfloat);
	const GLsizeiptr normal_size = 4 * 4 * sizeof(GLfloat);
	
	// allocate a new buffer
	glGenBuffers(1, &m_vertexBufferObject);
	
	// bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	
	
	// allocate enough space for the VBO
	glBufferData(GL_ARRAY_BUFFER, vertex_size/* + colour_size*/ + texCor_size + normal_size, 0, GL_STATIC_DRAW);
	
	GLfloat wholeImage[PIXEL_COUNT][4][3];
	//GLubyte colours[PIXEL_COUNT][4][4];
	
	Log(@"m_vertexBufferObject: %d", m_vertexBufferObject);
	
	for (int i = 0; i < PIXEL_COUNT; i++)
	{
		// offsetter reverses the order of the 2nd and 4th columns so the triangles are in a line
		//int offsetter = i;
		// 0 1
		// 0 0
		// 1 1
		// 1 0
		wholeImage[i][0][0] = 0.0f;
		wholeImage[i][0][1] = m_width;
		wholeImage[i][0][2] = 0.0f;
		
		wholeImage[i][1][0] = 0.0f;
		wholeImage[i][1][1] = 0.0f;
		wholeImage[i][1][2] = 0.0f;
		
		
		wholeImage[i][2][0] = m_height;
		wholeImage[i][2][1] = m_width;
		wholeImage[i][2][2] = 0.0f;
		
		wholeImage[i][3][0] = m_height;
		wholeImage[i][3][1] = 0.0f;
		wholeImage[i][3][2] = 0.0f;
		
		Log(@"(%d) %.02f x %.02f, %.02f x %.02f, %.02f x %.02f, %.02f x %.02f,"
			  , i
			  , wholeImage[i][0][0], wholeImage[i][0][1]
			  , wholeImage[i][1][0], wholeImage[i][1][1]
			  , wholeImage[i][2][0], wholeImage[i][2][1]
			  , wholeImage[i][3][0], wholeImage[i][3][1]);
		
		/*
		for (int j = 0; j < 4; ++j)
		{
			colours[offsetter][j][0] = 255;
			colours[offsetter][j][1] = 255;
			colours[offsetter][j][2] = 255;
			colours[offsetter][j][3] = 255;
		}*/
	}
	
	const GLfloat texCoords[] = 
	{
		// x: left to right, y bottom to top.
		// 3 2
		// 1 0
		1.0f,	0.0f,
		0.0f,	0.0f,
		1.0f,	1.0f,
		0.0f,	1.0f,
	};
	
	const GLfloat normals[] = 
	{
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
	};
	
#if 1
	// start at index 0, to length of vertex_size
	glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, wholeImage); 
	
	// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
	//glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, colours);
	
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size /*+ colour_size*/, texCor_size, texCoords);
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size/* + colour_size*/ + texCor_size, normal_size, normals);
#else
	GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES); 
	
	// transfer the vertex data to the VBO
	memcpy(vbo_buffer, wholeImage, vertex_size);
	
	// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
	//vbo_buffer += vertex_size;
	//memcpy(vbo_buffer, colours, colour_size);
	
	glUnmapBufferOES(GL_ARRAY_BUFFER); 
#endif
	
	// Describe to OpenGL where the vertex data is in the buffer
	glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	
	// Describe to OpenGL where the color data is in the buffer
	//glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL + vertex_size));
	
	glTexCoordPointer(2, GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size/* + colour_size*/));
	glNormalPointer(GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size/* + colour_size*/ + texCor_size));
	
	// create index buffer
	glGenBuffers(1, &m_indexBufferObject);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferObject);
	
	
	GLubyte indexBuffer[NUMBER_OF_CUBE_INDICES];
	for (int i = 0; i < NUMBER_OF_CUBE_INDICES; ++i)
	{
		indexBuffer[i] = (GLubyte)i;
	}
	
	// For constrast, instead of glBufferSubData and glMapBuffer, we can directly supply the data in one-shot
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, NUMBER_OF_CUBE_INDICES * sizeof(GLubyte), indexBuffer, GL_STATIC_DRAW);
	
	// -------------------------------------------------------
	
	error = glGetError();
	if (error != 0)
		Log(@"GL error: %d", error);
}