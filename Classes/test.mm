//
//  test.mm
//  InvaderR
//
//  Created by Richard Adem on 2/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#import "test.h"
#ifdef USE_VBO
// vertex coords array
static GLfloat s_cubeVertices[] =
{
	-1.0, +1.0, +1.0,  -1.0, -1.0, +1.0,  +1.0, +1.0, +1.0,  +1.0, -1.0, +1.0,        // v0-v1-v2-v3
	+1.0, +1.0, +1.0,  +1.0, -1.0, +1.0,  +1.0, +1.0, -1.0,  +1.0, -1.0, -1.0,          // v2-v3-v4-v5
	+1.0, +1.0, -1.0,  +1.0, -1.0, -1.0,  -1.0, +1.0, -1.0,  -1.0, -1.0, -1.0,    // v4-v5-v6-v7
	-1.0, +1.0, -1.0,  -1.0, -1.0, -1.0,  -1.0, +1.0, +1.0,  -1.0, -1.0, +1.0     // v6-v7-v0-v1
};
#define NUMBER_OF_CUBE_VERTICES 16
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3

// color array
GLubyte s_cubeColors[] = 
{
	// Bleh. I hate unsigned bytes for colors. Normalized floats are much more elegant.
	255,0,0,255, 255,0,0,255, 255,0,0,255, 255,0,0,255,
	0,255,0,255, 0,255,0,255, 0,255,0,255, 0,255,0,255, 
	0,0,255,255, 0,0,255,255, 0,0,255,255, 0,0,255,255,
	0,255,255,255, 0,255,255,255, 0,255,255,255, 0,255,255,255,  
	
};
#define NUMBER_OF_CUBE_COLORS 16
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

// Describes a box, but without a top and bottom
GLubyte s_cubeIndices[] = 
{
	0,1,2,3,
	4,5,6,7,
	8,9,10,11,
	12,13,14,15
};
#define NUMBER_OF_CUBE_INDICES 16

#endif

Test::Test()
{
#ifdef USE_VBO
	// allocate a new buffer
	glGenBuffers(1, &cubeVBO);
	
	// bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
	
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES*NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX*sizeof(GLfloat);
	const GLsizeiptr color_size = NUMBER_OF_CUBE_COLORS*NUMBER_OF_CUBE_COMPONENTS_PER_COLOR*sizeof(GLubyte);
	
	// allocate enough space for the VBO
	glBufferData(GL_ARRAY_BUFFER, vertex_size+color_size, 0, GL_STATIC_DRAW);
	
#if 1
	glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, s_cubeVertices); // start at index 0, to length of vertex_size
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size, color_size, s_cubeColors); // append color data to vertex data. To be optimal, data should probably be interleaved and not appended
#else
	GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES); 
	// transfer the vertex data to the VBO
	memcpy(vbo_buffer, s_cubeVertices, vertex_size);
	
	// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
	vbo_buffer += vertex_size;
	memcpy(vbo_buffer, s_cubeColors, color_size);
	
	glUnmapBufferOES(GL_ARRAY_BUFFER); 
#endif
	
	
	// Describe to OpenGL where the vertex data is in the buffer
	glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	
	// Describe to OpenGL where the color data is in the buffer
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
	
	
	// create index buffer
	glGenBuffers(1, &cubeIBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeIBO);
	// For constrast, instead of glBufferSubData and glMapBuffer, we can directly supply the data in one-shot
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, NUMBER_OF_CUBE_INDICES*sizeof(GLubyte), s_cubeIndices, GL_STATIC_DRAW);
#endif
}
Test::~Test()
{
#ifdef USE_VBO
	glDeleteBuffers(1, &cubeIBO);
	glDeleteBuffers(1, &cubeVBO);
#endif
}

void Test::Draw()
{
#ifdef USE_VBO
	/*
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-1.5f, 1.5f, -2.5f, 2.5f, -10.5f, 10.5f);
    glMatrixMode(GL_MODELVIEW);
    glRotatef(0.1f, 0.3f, 0.5f, 0.0f);
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	 */
	
	glTranslatef(50.0f, 50.0f, 0.0f);
	
	// Activate the VBOs to draw
	glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeIBO);
	
	// This could actually be moved into the setup since we never disable it
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	// This is the actual draw command
	glDrawElements(GL_TRIANGLE_STRIP, NUMBER_OF_CUBE_INDICES, GL_UNSIGNED_BYTE, (GLvoid*)((char*)NULL));
	
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
#endif
}