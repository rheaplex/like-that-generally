import processing.candy.*;
import processing.xml.*;

////////////////////////////////////////////////////////////////////////////////
// This is a data object for the various routines to use as a data store
// Each strategy for the routines will declare its own version of Appearance,
//   Form and Animation. But they will all know how to access an Entity.
////////////////////////////////////////////////////////////////////////////////


class Entity
{
        Appearance appearance;
        Form form;
        Animation animation;

	Entity (Appearance app, Form fo, Animation anim)
	{
		appearance = app;
		form = fo;
		animation = anim;
	}

	void draw (float time)
	{
		animation.apply (form, time);
		appearance.draw (form);
	}

	boolean finished (float time)
	{
		return animation.finished (time);
	}
}

////////////////////////////////////////////////////////////////////////////////
// SVG Form. Subclass and set entityNames to use.
////////////////////////////////////////////////////////////////////////////////

/*

SVG[] entities = null;
PApplet SvgParent = this;

class SvgForm
{
	String[] entityNames = null;
	float x;
	float y;
	float size;

	Svg entity;

	SvgEntity ()
	{
		if (entities == null)
		{
			loadEntitiesSvg ();
		}
		
		entity = entities [int (random (entities.length))];
	}

	void loadEntitiesSvg ()
	{
		entities = new Entities [entityNames.length];
		for (int i = 0; i < entityNames.length; i++)
		{
			entities.i = new SVG (SvgParent, names[i] + ".svg")
			entities.drawMode (CENTER);
			entities.ignoreStyles ();
		}
	}

	void draw ()
	{
		entity draw (x, y, size, size);	
	}
}
*/
class Appearance
{
	void draw (Form f)
	{
		fill (0, 0, 0, 245);
		f.draw ();
	}
}
// (:clashes "outline" "burst_2d" "cluster_2d" "grow_2d")

String MODE = P3D;

class Form
{
	float size;
	float x;
	float y;
	float z;

	Form ()
	{
	}

	void draw ()
	{
		pushMatrix ();
  		translate (x, y, z);
  		rotateX (- PI / 8.0);
  		rotateY (PI / 8.0);
  		box (size);
  		popMatrix ();
	}
}class Animation
{
    float x;
    float y;
    float z;
    float size;
    
    float start_shrinking;
    float stop_shrinking;
    float shrink_factor;
    float start_growing;
    float stop_growing;
    float grow_factor;
    
    Animation (float xx, float yy, float zz, float siz,
	       float start_grow, float stop_grow,
	       float start_shrink, float stop_shrink)
    {
	x = xx;
	y = yy;
	z = zz;
	size = siz;
	start_growing = start_grow;
	stop_growing = stop_grow;
	start_shrinking = start_shrink;
	stop_shrinking = stop_shrink;

        grow_factor = 1.0 / (stop_grow - start_grow);
        shrink_factor = 1.0 / (stop_shrink - start_shrink);
    }


    float scaleFactor (float t)
    { 
	if (t > stop_shrinking)
	    {
		return 0.0;
	    } 
 	else if (t > start_shrinking)
	    {
		return 1.0 - (shrink_factor * (t - start_shrinking));
	    }
 	else if (t > stop_growing)
	    {
		return 1.0;
	    }
 	else if (t > start_growing)
	    {
		return grow_factor * (t - start_growing); 
	    }
  	// So <= start_growing
  	return  0.0;
    }
    
    
    void apply (Form form, float t)
    {
	float scale_factor = scaleFactor (t); 
	if (scale_factor == 0)
	    {
		return; 
	    }
	
	form.size = size * scale_factor;

  	float side_length = size * scale_factor;
  	if (side_length > size)
	    {
		side_length = size; 
	    }
  	form.x = x * scale_factor;
	form.y = y * scale_factor;
	form.z = z * scale_factor;
    }
    
    boolean finished (float t)
    {
      return t > stop_shrinking;
    }
}
// Configuration constants

int min_objects = 4;
int max_objects = 24;

// In pixels

int canvas_width = 400;
int canvas_height = 400;

int min_object_x = -100;
int max_object_x = 100;
int min_object_y = -100;
int max_object_y = 100;

float min_object_start_t = 0.0;
float max_object_start_t = 0.5;

int min_object_size = 5;
int max_object_size = 200;

// In seconds

float min_duration = 1.0;
float max_duration = 10.0;


int num_objects;
Entity[] entities;
float rotation;
float end_of_current_sequence;


float RandomDuration ()
{
  return random (min_duration, max_duration) * 1000; 
}

void GenObjects ()
{
  rotation = random (PI / 2.0);
  
  num_objects = (int)random(min_objects, max_objects);
  
  entities = new Entity[num_objects]; 

  float start_growing = millis ();
  float growing_range = RandomDuration ();
  float stop_growing = start_growing + growing_range;
  float start_shrinking = stop_growing + RandomDuration ();
  float shrinking_range = RandomDuration ();
  float stop_shrinking = start_shrinking + shrinking_range;
  
  end_of_current_sequence = stop_shrinking;

  for (int i = 0; i < num_objects; i++) 
  {
	float t_factor = random (min_object_start_t, max_object_start_t);
        entities[i] = new Entity (
	 new Appearance (),
	 new Form (),
	 new Animation (
   	  random (min_object_x, max_object_x),
   	  random (min_object_y, max_object_y), 
   	  0.0, //random (min_object_z, max_object_z), 
   	  random (min_object_size, max_object_size), 
	  start_growing + (growing_range * t_factor),
	  stop_growing,
	  start_shrinking,
	  start_shrinking + (shrinking_range * t_factor)));
  }
}

void DrawObjects ()
{
  float now = millis ();
  if (now >= end_of_current_sequence)
  {
   GenObjects ();
  }
  for (int i = 0; i < num_objects; i++)
  {
    if (! entities[i].finished (now))
      entities[i].draw (now);
  } 
}

void draw ()
{
  background(255);
  if (MODE != P3D)
  {
     smooth ();
  }
  if ((MODE == P3D) || MODE == (OPENGL))
  {
	ambientLight (245, 245, 245);
  	directionalLight (50, 50, 50, 0, 1, -1);
	translate (canvas_width / 2.0, canvas_height / 2.0,
                   - (max (canvas_width, canvas_height) * 0.4));
  }
  else
  {
    translate (canvas_width / 2.0, canvas_height / 2.0);
  }
  noStroke ();
  DrawObjects ();   
}

void setup ()
{
  size(canvas_width, canvas_height, MODE); 
  frameRate(30);
  GenObjects ();
}
