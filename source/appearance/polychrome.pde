class Appearance
{
	color col;

	Appearance ()
	{
		col = color (random (255), random (255), random (255));
	}	

	void draw (Form f)
	{
		fill (col);
		f.draw ();
	}
}
