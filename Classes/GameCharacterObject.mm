//
//  GameCharacterObject.mm
//  Invader
//
//  Created by Richard Adem on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "GameCharacterObject.h"

#include "OpenGLCommon.h"

//#define BASECLASS GameObject

GameCharacterObject::GameCharacterObject()
: GameMoveableObject()
, m_bufferedDataUsage(GL_STATIC_DRAW)
, m_vertexBufferObject(0)
, m_indexBufferObject(0)
, m_red(255)
, m_green(255)
, m_blue(255)
, m_alpha(255)
{
	for (int i = 0; i < 25; ++i)
	{
		m_image[i] = true;
	}
	
}
GameCharacterObject::~GameCharacterObject()
{
#ifdef USE_VBO
	destroyVBOs();
#endif
}

void GameCharacterObject::Init()
{
#ifdef USE_VBO
	setUpVBOs();
#endif
	
	GameMoveableObject::Init();
}

void GameCharacterObject::Draw()
{
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glColor4f(1.0, 1.0, 1.0, 1.0);
    
    //glEnableClientState(GL_VERTEX_ARRAY);
    //glEnableClientState(GL_NORMAL_ARRAY);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glLoadIdentity();
	
	glTranslatef(m_pos.y, m_pos.x, 0.0f);
#ifdef USE_VBO
	drawVBOs();
#else
	for (int i = 0; i < 25; i++)
	{
		if(m_image[i] == true)
		{
#if 0
			Triangle3D  triangle[2];
			float x = ((i % 5) * IPS);
			float y = ((i / 5) * IPS);
			/*
			triangle[0].v1 = Vertex3DMake((m_pos.y)+((i%5)*IPS),		m_pos.x+((i/5)*IPS),		0.0f); // 1
			triangle[0].v2 = Vertex3DMake((m_pos.y)+((i%5)*IPS),		m_pos.x+((i/5)*IPS)+IPS,	0.0f); // 2
			triangle[0].v3 = Vertex3DMake((m_pos.y)+((i%5)*IPS)+IPS,	m_pos.x+((i/5)*IPS)+IPS,	0.0f); // 3
			triangle[1].v1 = Vertex3DMake((m_pos.y)+((i%5)*IPS)+IPS,	m_pos.x+((i/5)*IPS)+IPS,	0.0f); // 3
			triangle[1].v2 = Vertex3DMake((m_pos.y)+((i%5)*IPS),		m_pos.x+((i/5)*IPS),		0.0f); // 1
			triangle[1].v3 = Vertex3DMake((m_pos.y)+((i%5)*IPS)+IPS,	m_pos.x+((i/5)*IPS),		0.0f); // 4
			*/
			triangle[0].v1 = Vertex3DMake(x,		y,			0.0f); // 1
			triangle[0].v2 = Vertex3DMake(x,		y + IPS,	0.0f); // 2
			triangle[0].v3 = Vertex3DMake(x + IPS,	y + IPS,	0.0f); // 3
			triangle[1].v1 = Vertex3DMake(x + IPS,	y + IPS,	0.0f); // 3
			triangle[1].v2 = Vertex3DMake(x,		y,			0.0f); // 1
			triangle[1].v3 = Vertex3DMake(x + IPS,	y,			0.0f); // 4
			
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(3, GL_FLOAT, 0, &triangle);
			glDrawArrays(GL_TRIANGLES, 0, 18);
			glDisableClientState(GL_VERTEX_ARRAY);
#else
			// GL_TRIANGLE_STRIP
			// 0 1
			// 0 0
			// 1 1
			// 1 0
			GLfloat quad[4][3];
			
			quad[0][0] = x;
			quad[0][1] = y + IPS;
			quad[0][2] = 0.0f;
			
			quad[1][0] = x;
			quad[1][1] = y;
			quad[1][2] = 0.0f;
			
			quad[2][0] = x + IPS;
			quad[2][1] = y + IPS;
			quad[2][2] = 0.0f;
			
			quad[3][0] = x + IPS;
			quad[3][1] = y;
			quad[3][2] = 0.0f;

			/*
			quad[0][0] = 0.0f;
			quad[0][1] = 0.0f + IPS;
			quad[0][2] = 0.0f;
			
			quad[1][0] = 0.0f;
			quad[1][1] = 0.0f;
			quad[1][2] = 0.0f;
			
			quad[2][0] = 0.0f + IPS;
			quad[2][1] = 0.0f + IPS;
			quad[2][2] = 0.0f;
			
			quad[3][0] = 0.0f + IPS;
			quad[3][1] = 0.0f;
			quad[3][2] = 0.0f;
*/
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(3, GL_FLOAT, 0, &quad);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glDisableClientState(GL_VERTEX_ARRAY);			
#endif
		}
	}
#endif
	
	GameMoveableObject::Draw();
}

int GameCharacterObject::getImgIndexOffsetToStrip(int index)
{
	int offsetter;
	switch (index)
	{
		case 5:
			offsetter = 9;
			break;
		case 6:
			offsetter = 8;
			break;
			//skip 7 = 7
		case 8:
			offsetter = 6;
			break;
		case 9:
			offsetter = 5;
			break;
		case 15:
			offsetter = 19;
			break;
		case 16:
			offsetter = 18;
			break;
			// 17 = 17
		case 18:
			offsetter = 16;
			break;
		case 19:
			offsetter = 15;
			break;
		default:
			offsetter = index;
			break;
	}

	return offsetter;
}

#define PIXEL_COUNT 25

#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3

#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

#define NUMBER_OF_CUBE_INDICES 4 * PIXEL_COUNT

void GameCharacterObject::setUpVBOs()
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

	/*
	Log(@"m_vertexBufferObject: %d", m_vertexBufferObject);
	Log(@"%d %d %d %d %d - %d %d %d %d %d - %d %d %d %d %d - %d %d %d %d %d - %d %d %d %d %d"
		  , m_image[0] , m_image[1] , m_image[2] , m_image[3] , m_image[4]
		  , m_image[5] , m_image[6] , m_image[7] , m_image[8] , m_image[9]
		  , m_image[10] , m_image[11] , m_image[12] , m_image[13] , m_image[14]
		  , m_image[15] , m_image[16] , m_image[17] , m_image[18] , m_image[19]
		  , m_image[20] , m_image[21] , m_image[22] , m_image[23] , m_image[24]);
	*/				
	for (int i = 0; i < PIXEL_COUNT; i++)
	{
		int offsetter = getImgIndexOffsetToStrip(i);
		
		if ((i >= 5 && i < 10) || (i >= 15 && i < 20))
		{
			wholeImage[i][3][0] = (offsetter % 5) * IPS;
			wholeImage[i][3][1] = ((offsetter / 5) * IPS) + IPS;
			wholeImage[i][3][2] = 0.0f;
			
			wholeImage[i][2][0] = (offsetter % 5) * IPS;
			wholeImage[i][2][1] = (offsetter / 5) * IPS;
			wholeImage[i][2][2] = 0.0f;
			
			wholeImage[i][1][0] = ((offsetter % 5) * IPS) + IPS;
			wholeImage[i][1][1] = ((offsetter / 5) * IPS) + IPS;
			wholeImage[i][1][2] = 0.0f;
			
			wholeImage[i][0][0] = ((offsetter % 5) * IPS) + IPS;
			wholeImage[i][0][1] = (offsetter / 5) * IPS;
			wholeImage[i][0][2] = 0.0f;	
		}
		else
		{
			wholeImage[i][0][0] = (offsetter % 5) * IPS;
			wholeImage[i][0][1] = ((offsetter / 5) * IPS) + IPS;
			wholeImage[i][0][2] = 0.0f;
			
			wholeImage[i][1][0] = (offsetter % 5) * IPS;
			wholeImage[i][1][1] = (offsetter / 5) * IPS;
			wholeImage[i][1][2] = 0.0f;
			
			wholeImage[i][2][0] = ((offsetter % 5) * IPS) + IPS;
			wholeImage[i][2][1] = ((offsetter / 5) * IPS) + IPS;
			wholeImage[i][2][2] = 0.0f;
			
			wholeImage[i][3][0] = ((offsetter % 5) * IPS) + IPS;
			wholeImage[i][3][1] = (offsetter / 5) * IPS;
			wholeImage[i][3][2] = 0.0f;	
		}
		
		for (int j = 0; j < 4; ++j)
		{
			if(m_image[i] == true)
			{
				colours[offsetter][j][0] = m_red;
				colours[offsetter][j][1] = m_green;
				colours[offsetter][j][2] = m_blue;
				colours[offsetter][j][3] = m_alpha;
			}
			else
			{
				colours[offsetter][j][0] = 255;
				colours[offsetter][j][1] = 255;
				colours[offsetter][j][2] = 255;
				colours[offsetter][j][3] = 0;
			}
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
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, NUMBER_OF_CUBE_INDICES * sizeof(GLubyte), indexBuffer, m_bufferedDataUsage); // GL_STATIC_DRAW
	
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}
}

void GameCharacterObject::destroyVBOs()
{
	glDeleteBuffers(1, &m_indexBufferObject);
	glDeleteBuffers(1, &m_vertexBufferObject);	
}

void GameCharacterObject::drawVBOs()
{
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);

	// Activate the VBOs to draw
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferObject);

	// This could actually be moved into the setup since we never disable it
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);

	// This is the actual draw command
	glDrawElements(GL_TRIANGLE_STRIP, NUMBER_OF_CUBE_INDICES, GL_UNSIGNED_BYTE, (GLvoid*)((char*)NULL)); // GL_TRIANGLE_STRIP

	GLenum gl_error = glGetError();
	if (GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}	
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}
