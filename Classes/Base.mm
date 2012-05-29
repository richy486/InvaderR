#include "base.h"

#define BASECLASS GameCharacterObject

Base::Base(void)
: GameCharacterObject()
{
	m_bufferedDataUsage = GL_DYNAMIC_DRAW;
}

Base::~Base(void)
{
}

// Test if any of the pixels of the base have been hit.
bool Base::TestHit(Point2D& currentPos, Point2D& previousPos)
{
	const float offSet = 1.5f; // What is this for?
	bool movingUp = currentPos.y > previousPos.y;
	
	// ------------
	for(int i = 0; i < 25; i++)
	{
		float iOfFive = i / 5;
		float iModFive = i % 5;
		float xBlockOffset = iOfFive * IPS;
		float yBlockOffset = iModFive * IPS;
		
		if(currentPos.x + offSet >= m_pos.x + xBlockOffset
		   && currentPos.x + offSet <= m_pos.x + xBlockOffset + IPS
		   && currentPos.y >= (m_pos.y) + yBlockOffset
		   && currentPos.y <= (m_pos.y) + yBlockOffset + IPS
		   && m_image[i] == true)
		{
			int inbetweenPixel = i;
			
			// test if there were pixels above of below that are inbetween the cur and prev positions
			if (movingUp)
			{
				
				int bottomNumber = iOfFive * 5;
				
				// search down the line of pixels				
				//while (--inbetweenPixel != bottomNumber - 1)
				while (--inbetweenPixel >= bottomNumber)
				{
					if (!m_image[inbetweenPixel])
					{
						if (m_image[inbetweenPixel + 1])
							m_image[inbetweenPixel + 1] = false;
						else
							Log(@"already false!?!?");
						
						updateVBO();
						return true;
					}
				}
				if (m_image[bottomNumber])
					m_image[bottomNumber] = false;
				else
					Log(@"already false!?!?");
				
				updateVBO();
				return true;
			}
			else
			{
#if 1
				int topNumber = (iOfFive * 5) + 4;
				
				// search up the line of pixels
				//while (++inbetweenPixel != topNumber + 1)
				while (++inbetweenPixel <= topNumber)
				{
					if (!m_image[inbetweenPixel])
					{
						if (m_image[inbetweenPixel - 1])
							m_image[inbetweenPixel - 1] = false;
						else
							Log(@"already false!?!?");
						
						updateVBO();
						return true;
					}
				}
				if (m_image[topNumber])
					m_image[topNumber] = false;
				else
					Log(@"already false!?!?");
				
				updateVBO();
				return true;
#else
				m_image[i] = false;
				
				updateVBO();
				return true;
#endif
			}
		}
	}
	
	return false;
}

void Base::Init()
{
	for(int i = 0; i < 25; i++)
	{
		m_image[i] = true;
	}
	m_image[4] = false;
	m_image[24] = false;
	m_image[5] = false;
	m_image[10] = false;
	m_image[15] = false;
	
	m_red = 255;
	m_green = 255;
	m_blue = 225;
	m_alpha = 255;
	
	
	BASECLASS::Init();
}

void Base::Draw()
{
	glColor4f(0.9f, 0.9f, 0.9f, 1.0f);
	//((GameObject)this).Draw();
	BASECLASS::Draw();
}

#define PIXEL_COUNT 25

#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3

#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4

void Base::updateVBO()
{
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	GLubyte colours[25][4][4];
	
	for (int i = 0; i < 25; ++i)
	{
		int offsetter = getImgIndexOffsetToStrip(i);
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
	
	glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferObject);
	glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, colours);
	//glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
	
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}
}
