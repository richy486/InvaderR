//
//  GameProjectileObject.mm
//  InvaderR
//
//  Created by Richard Adem on 4/02/10.
//  Copyright 2010 vorticity. All rights reserved.
//

#import "GameProjectileObjectBomb.h"

GameProjectileObjectBomb::GameProjectileObjectBomb()
: GameProjectileObject()
{
}
GameProjectileObjectBomb::~GameProjectileObjectBomb()
{
#ifdef USE_VBO
	destroyVBOs();
#endif
}

#define PIXEL_COUNT 1

#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3

#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

#define NUMBER_OF_CUBE_INDICES 4 * PIXEL_COUNT

void GameProjectileObjectBomb::setUpVBOs()
{
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);

	// allocate a new buffer
	glGenBuffers(1, &m_vertexBufferObject);
	
	// bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	
	
	// allocate enough space for the VBO
	glBufferData(GL_ARRAY_BUFFER, vertex_size + colour_size, 0, GL_STATIC_DRAW);
	
	GLfloat wholeImage[PIXEL_COUNT][4][3];
	GLubyte colours[PIXEL_COUNT][4][4];
	
	Log(@"GameProjectileObject __ m_vertexBufferObject: %d", m_vertexBufferObject);
	
	for (int i = 0; i < PIXEL_COUNT; i++)
	{
		// offsetter reverses the order of the 2nd and 4th columns so the triangles are in a line
		int offsetter = i;

		wholeImage[i][0][0] = (offsetter % 5) * IPS;
		wholeImage[i][0][1] = ((offsetter / 5) * IPS) + IPS;
		wholeImage[i][0][2] = 0.0f;
		
		wholeImage[i][1][0] = (offsetter % 5) * IPS;
		wholeImage[i][1][1] = (offsetter / 5) * IPS;
		wholeImage[i][1][2] = 0.0f;
		
		wholeImage[i][2][0] = ((offsetter % 5) * IPS) + IPS + (IPS * 7); // left
		wholeImage[i][2][1] = ((offsetter / 5) * IPS) + IPS;
		wholeImage[i][2][2] = 0.0f;
		
		wholeImage[i][3][0] = ((offsetter % 5) * IPS) + IPS + (IPS * 7); // right
		wholeImage[i][3][1] = (offsetter / 5) * IPS;
		wholeImage[i][3][2] = 0.0f;	
		
		
		for (int j = 0; j < 2; ++j)
		{
			colours[offsetter][j][0] = m_colRed;
			colours[offsetter][j][1] = m_colGreen;
			colours[offsetter][j][2] = m_colBlue;
			colours[offsetter][j][3] = m_colAlpha;
		}
		
		for (int j = 2; j < 4; ++j)
		{
			colours[offsetter][j][0] = m_colRed;
			colours[offsetter][j][1] = m_colGreen;
			colours[offsetter][j][2] = m_colBlue;
			colours[offsetter][j][3] = 0;
		}
	}
	
#if 1
	// start at index 0, to length of vertex_size
	glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, wholeImage); 
	
	// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, colours); 
#else
	GLvoid* vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES); 
	
	// transfer the vertex data to the VBO
	memcpy(vbo_buffer, wholeImage, vertex_size);
	
	// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
	vbo_buffer += vertex_size;
	memcpy(vbo_buffer, colours, colour_size);
	
	glUnmapBufferOES(GL_ARRAY_BUFFER); 
#endif
	
	// Describe to OpenGL where the vertex data is in the buffer
	glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	
	// Describe to OpenGL where the color data is in the buffer
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
	
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
	
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}	
}

