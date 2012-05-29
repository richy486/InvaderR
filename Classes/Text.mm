/* invaderR, space invaders clone
 * Copyright (C) 2006 Richard Adem richy486@gmail.com
 */

#include "text.h"
#include "OpenGLCommon.h"

static TextController* s_instance = NULL;
TextController::~TextController()
{
	if (!m_textBoxes.empty())
	{
		std::list<TextBox*>::iterator iter;
		iter = m_textBoxes.begin(); 
		int count = 0;
		while(iter != m_textBoxes.end())
		{
			count++;
			iter++;
		}
		
		Log(@"WARNING, not all text boxes were deleted count: %d", count);
	}
	DeleteAll();
}
TextController* TextController::GetInstance()
{
	if (s_instance == NULL)
		s_instance = new TextController();
	
	return s_instance;
}

//TextBox* TextController::CreateText(float x, float y, TEXTSIZE::TEXTSIZE size, const wchar_t* fmt, ...)
TextBox* TextController::CreateText(float x, float y, TEXTSIZE::TEXTSIZE size, const wchar_t* text)
{
	TextBox* textBox = new TextBox();
	
	textBox->setPos(x, y);
	
	/*
	wchar_t text[256]; 
	va_list ap;
	va_start(ap, fmt);
    vswprintf(text, sizeof(wchar_t[256]), fmt, ap);
	va_end(ap);
	 */
	
	textBox->SetText(text);
	textBox->SetSize(size);
	
	m_textBoxes.push_back(textBox);
	
	return textBox;
}

void TextController::DeleteText(TextBox* textBox)
{
	if (!m_textBoxes.empty())
	{
		std::list<TextBox*>::iterator iter;
		iter = m_textBoxes.begin(); 
		while(iter != m_textBoxes.end())
		{
			if ((*iter) == textBox)
			{
				iter = m_textBoxes.erase(iter);
				delete textBox;
				return;
			}
			iter++;
		}
	}
	else 
	{
		assert("no text boxes alive" && false);
	}
	
	assert("could not find textBox" && false);
}
void TextController::DeleteAll()
{
	std::list<TextBox*>::iterator iter;
	iter = m_textBoxes.begin(); 
	while(iter != m_textBoxes.end())
	{
		iter = m_textBoxes.erase(iter);
	}
}

TextController::TextController()
{
	TextBox::InitTexture();
}

// --------------------------------------------------------------------

static const int s_characterCount = 16 * 32;

static bool s_initlised = false;
static GLuint s_glTexture; // all TextBoxes use the same texture. static GLuint s_glTexture[TEXTSIZE::COUNT];
static GLuint s_vertexBufferObject[TEXTSIZE::COUNT][s_characterCount];
static GLuint s_indexBufferObject[TEXTSIZE::COUNT][s_characterCount];

static const GLfloat s_fontSizes[] = {8.0f, 16.0f};

static const GLfloat s_charWidth = 1.0f / (GLfloat)16.0f;
static const GLfloat s_charHeight = 1.0f / (GLfloat)16.0f;

#define PIXEL_COUNT 1
#define NUMBER_OF_CUBE_VERTICES 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX 3
#define NUMBER_OF_CUBE_COLORS 4 * PIXEL_COUNT
#define NUMBER_OF_CUBE_COMPONENTS_PER_COLOR 4
#define NUMBER_OF_CUBE_INDICES 4 * PIXEL_COUNT

TextBox::~TextBox()
{
}

void TextBox::InitTexture()
{
	// Bind the number of textures we need, in this case one.
	glGenTextures(1, &s_glTexture); // glGenTextures(1, &s_glTexture[i]);
	glBindTexture(GL_TEXTURE_2D, s_glTexture); // glBindTexture(GL_TEXTURE_2D, s_glTexture[i]);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST); // GL_LINEAR
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST); // GL_LINEAR
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	// DEBUG
	//Log(@"sizeof(char): %d, sizeof(int): %d, sizeof(wchar_t): %d", sizeof(char), sizeof(int), sizeof(wchar_t));

	
	// -----------------------------------
	
	NSString *path;
	/*
	switch (i)
	{
		case TEXTSIZE::EIGHT:
			path = [[NSBundle mainBundle] pathForResource:@"osFont8" ofType:@"png"];
			break;
		case TEXTSIZE::SIXTEEN:
			path = [[NSBundle mainBundle] pathForResource:@"osFont16" ofType:@"png"];
			break;
		default:
			Log(@"invalid text size");
			return;
			break;
	}
	*/
	
	path = [[NSBundle mainBundle] pathForResource:@"osFont" ofType:@"png"];

	NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	
	if (image == nil)
		Log(@"Do real error checking here");
	
	GLuint width = CGImageGetWidth(image.CGImage);
	GLuint height = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = malloc( height * width * 4 );
	CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	
	// Flip the Y-axis
	CGContextTranslateCTM (context, 0, height);
	CGContextScaleCTM (context, 1.0, -1.0);
	
	CGColorSpaceRelease( colorSpace );
	CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
	CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	CGContextRelease(context);
	
	free(imageData);
	[image release];
	[texData release];
	
	// ------------------------------------------------
	for (int i = 0; i < TEXTSIZE::COUNT; ++i)
	{
		
		GLenum error = glGetError();
		if (error != 0)
			Log(@"GL error: %d", error);
		
		const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
		const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
		const GLsizeiptr texCor_size = 2 * 4 * sizeof(GLfloat);
		const GLsizeiptr normal_size = 4 * 4 * sizeof(GLfloat);

		GLfloat wholeImage[PIXEL_COUNT][4][3];
		GLubyte colours[PIXEL_COUNT][4][4];
		
		const GLfloat normals[] = 
		{
			0.0f, 0.0f, 1.0f,
			0.0f, 0.0f, 1.0f,
			0.0f, 0.0f, 1.0f,
			0.0f, 0.0f, 1.0f,
		};
		
		for (int j = 0; j < PIXEL_COUNT; ++j)
		{
			for (int k = 0; k < 4; ++k)
			{
				colours[j][k][0] = 255;
				colours[j][k][1] = 255;
				colours[j][k][2] = 255;
				colours[j][k][3] = 255;
			}
		}

		// loop through each character in the texture
		for (int iChar = 0; iChar < s_characterCount; ++iChar)
		{
		
			// allocate a new buffer
			glGenBuffers(1, &s_vertexBufferObject[i][iChar]);
			
			// bind the buffer object to use
			glBindBuffer(GL_ARRAY_BUFFER, s_vertexBufferObject[i][iChar]);
			
			
			// allocate enough space for the VBO
			glBufferData(GL_ARRAY_BUFFER, vertex_size + colour_size + texCor_size + normal_size, 0, GL_STATIC_DRAW);
			
			//Log(@"Text _%c_ m_vertexBufferObject: %d", (char)iChar, s_vertexBufferObject[i]);
			
			for (int j = 0; j < PIXEL_COUNT; ++j)
			{
				// offsetter reverses the order of the 2nd and 4th columns so the triangles are in a line
				// 0 1
				// 0 0
				// 1 1
				// 1 0

				wholeImage[j][0][0] = 0.0f;
				wholeImage[j][0][1] = s_fontSizes[i];
				wholeImage[j][0][0] = 0.0f;
				
				wholeImage[j][1][0] = 0.0f;
				wholeImage[j][1][1] = 0.0f;
				wholeImage[j][1][2] = 0.0f;
				
				
				wholeImage[j][2][0] = s_fontSizes[i];
				wholeImage[j][2][1] = s_fontSizes[i];
				wholeImage[j][2][2] = 0.0f;
				
				wholeImage[j][3][0] = s_fontSizes[i];
				wholeImage[j][3][1] = 0.0f;
				wholeImage[j][3][2] = 0.0f;
				
			}
			
			static const GLfloat chaWH = (1.0f / (GLfloat)64.0f);

			GLfloat xPos = ((iChar % 16) * s_charWidth) / 4.0f; // + (i * 0.5);
			GLfloat yPos = 1.0f - (((iChar / 16) + 1.0f) * chaWH);
			
			const GLfloat textCoords[] =
			{
				xPos + chaWH, //s_charWidth,
				yPos,
				
				xPos,
				yPos,
				
				xPos + chaWH, //s_charWidth,
				yPos + chaWH, //s_charHeight,
				
				xPos,
				yPos + chaWH, //s_charHeight,
			};
			
			//Log(@"%.02f, %.02f -  %d, %c", xPos, yPos, iChar, iChar);
			
#if 1
			// start at index 0, to length of vertex_size
			glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_size, wholeImage); 
			
			// append color data to vertex data. To be optimal, data should probably be interleaved and not appended
			glBufferSubData(GL_ARRAY_BUFFER, vertex_size, colour_size, colours);
			
			glBufferSubData(GL_ARRAY_BUFFER, vertex_size + colour_size, texCor_size, textCoords);
			glBufferSubData(GL_ARRAY_BUFFER, vertex_size + colour_size + texCor_size, normal_size, normals);
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
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL + vertex_size));
			
			glTexCoordPointer(2, GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size + colour_size));
			glNormalPointer(GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size + colour_size + texCor_size));
			
			// create index buffer
			glGenBuffers(1, &s_indexBufferObject[i][iChar]);
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, s_indexBufferObject[i][iChar]);
			
			
			GLubyte indexBuffer[NUMBER_OF_CUBE_INDICES];
			for (int i = 0; i < NUMBER_OF_CUBE_INDICES; ++i)
			{
				indexBuffer[i] = (GLubyte)i;
			}
			
			// For constrast, instead of glBufferSubData and glMapBuffer, we can directly supply the data in one-shot
			glBufferData(GL_ELEMENT_ARRAY_BUFFER, NUMBER_OF_CUBE_INDICES * sizeof(GLubyte), indexBuffer, GL_STATIC_DRAW);
			
			error = glGetError();
			if (error != 0)
				Log(@"GL error: %d", error);
			else
				s_initlised = true;
			
		} // iChar
	} // i (textures)
}
	
void TextBox::Draw()
{
#ifndef DISABLE_TEXT_DRAW
	GameMoveableObject::Draw();
	
	assert("Must call InitTexture() without error before calling Draw()" && s_initlised);
	
	// draw the texture
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(1.0, 1.0, 1.0, 1.0);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	const GLsizeiptr vertex_size = NUMBER_OF_CUBE_VERTICES * NUMBER_OF_CUBE_COMPONENTS_PER_VERTEX * sizeof(GLfloat);
	const GLsizeiptr colour_size = NUMBER_OF_CUBE_COLORS * NUMBER_OF_CUBE_COMPONENTS_PER_COLOR * sizeof(GLubyte);
	const GLsizeiptr texCor_size = 2 * 4 * sizeof(GLfloat);
	//const GLsizeiptr normal_size = 4 * 4 * sizeof(GLfloat);
	
	glLoadIdentity();
	
    glBindTexture(GL_TEXTURE_2D, s_glTexture); // glBindTexture(GL_TEXTURE_2D, s_glTexture[m_size]);
	glTranslatef(m_pos.y, m_pos.x, -0.0);
	
		
	// This could actually be moved into the setup since we never disable it
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	//Log(@"-----------");
	for (int i = 0; i < s_maxTextLength; ++i)
	{
		glTranslatef(0.0f, s_fontSizes[m_size], -0.0);
		
		// Activate the VBOs to draw
		glBindBuffer(GL_ARRAY_BUFFER, s_vertexBufferObject[m_size][m_text[i]]);
		glVertexPointer(3, GL_FLOAT, 0, (GLvoid*)((char*)NULL));
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, (GLvoid*)((char*)NULL+vertex_size));
		glTexCoordPointer(2, GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size + colour_size));
		glNormalPointer(GL_FLOAT, 0, (GLvoid*)((char*)NULL + vertex_size + colour_size + texCor_size));
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, s_indexBufferObject[m_size][m_text[i]]);
		

		// This is the actual draw command
		glDrawElements(GL_TRIANGLE_STRIP, NUMBER_OF_CUBE_INDICES, GL_UNSIGNED_BYTE, (GLvoid*)((char*)NULL)); // GL_TRIANGLE_STRIP
		//Log(@"%d", m_text[i]);
	}
	
	GLenum gl_error = glGetError();
	if (GL_NO_ERROR != gl_error)
	{
		Log(@"Error: %d", gl_error);
	}	
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);

	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
#endif
}

//void TextBox::SetText(const wchar_t* fmt, ...)
void TextBox::SetText(const wchar_t* text)
{
	// clear the text to spaces
	memset(m_text, 0, sizeof(int[s_maxTextLength]));
	
	//va_list ap;
	if (text == NULL) //if (fmt == NULL) 
		return;
	
	/*
	va_start(ap, fmt);
    vswprintf(m_text, sizeof(wchar_t[256]), fmt, ap);
	va_end(ap);
	 */
	memcpy(m_text, text, sizeof(int[s_maxTextLength]));
	
	//if (m_text[0] == '\0')
	//	return;
}
const wchar_t* TextBox::GetText()
{
	return m_text;
}

void TextBox::SetSize(TEXTSIZE::TEXTSIZE size)
{
	m_size = size;
}
	
TextBox::TextBox()
: GameMoveableObject()
{
}

@implementation UTextConverter

+ (wchar_t*) ConvertUText:(NSString*) text
{
	wchar_t* ctext = new wchar_t[s_maxTextLength];
	memset(ctext, 0, sizeof(int[s_maxTextLength]));
	for (int i = 0; i < [text length]; ++i) 
	{
		unichar uni = [text characterAtIndex: i];
		int scaledDown = uni; // = uni >= 12352 ? uni - 12352 + 256 : uni;
		if (uni >= 12352)
		{
			int zeroed = uni - 12352;
			//int halfed = zeroed / 2;
			//scaledDown = halfed + 256;
			scaledDown = zeroed + 256;
		}
		else if (uni == 12288)
		{
			scaledDown = 0;
		}
		
		//Log(@"ConvertUText: %@ - %C, %d", [NSString stringWithFormat:@"%x", uni], uni, scaledDown);
		ctext[i] = scaledDown;
	}
	return ctext;
}

@end
