
----------------------------------------------------------------------------
--# Draws a 'rainbow' spectrum - Spectrum code from <b>Loki</b> (L. Patrick) 
----------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e

constant 
	WIDTH = 280, 
	HEIGHT = 80,
	MAX_INTENSITY = 255,
	NCOLORS = 256

sequence color = repeat(0,NCOLORS+1)

-------------------------------------------------------------
procedure CreateSpectrum(integer ncolors)
-------------------------------------------------------------
atom c, x, y, r, g, b

	c = 1.0 / ( (1-0.3455)*(1-0.3455) * (1-0.90453)*(1-0.90453) )

	for i = 1 to ncolors+1 do
	 -- ramp for first color, y=x
		x = i / ncolors
		r = floor(x * MAX_INTENSITY)

	 -- single hump for next color, y=x(4x-3)^2
		y = x * (4*x - 3)*(4*x-3)
		if y > 1 then y = 1 end if
		if y < 0 then y = 0 end if
		g = floor(y * MAX_INTENSITY)

	 -- double hump for next color, y=cx(x-a)^2(x-b)^2
		y = c*x*(x-0.3455)*(x-0.3455)*(x-0.90453)*(x-0.90453)
		if y > 1 then y = 1 end if
		if y < 0 then y = 0 end if
		b = floor(y * MAX_INTENSITY)

	 -- store resultant color
	 -- change the order of r,g,b in this line to see more spectrums */
            color[i] = {r/256,g/256,b/256} 
            
       end for
end procedure

---------------------------------------------------
function DrawSpectrum()
---------------------------------------------------
atom n
atom cr = create(GdkCairo_t,get(drawable,"window"))

 CreateSpectrum(NCOLORS)

 for x = 1 to WIDTH do
   n = 1 + floor(x * NCOLORS / WIDTH) 
   set(cr,"source rgb",color[n][1],color[n][2],color[n][3])
   set(cr,"line width",1)
   set(cr,"move to",x,1)
   set(cr,"line to",x,80)
   set(cr,"stroke")
 end for
   set(cr,"destroy")

 return 1
end function

------------------------[ MAIN ]-------------------

constant win = create(GtkWindow,"resizable=0,position=1,$destroy=Quit")
set(win,"title","Loki's Spectrum")

constant panel = create(GtkBox,"orientation=VERTICAL")
add(win,panel)

constant drawable = create(GtkDrawingArea,"background=black")
set(drawable,"size request",WIDTH,HEIGHT)

add(panel,drawable)

show_all(win)

-- draw when displayed or uncovered;
 connect(drawable,"draw",_("DrawSpectrum"))

 main()

--------------------------------------------------------------------------
-- Copyright 2010 by Irv Mullins all code released under the LGPL
--------------------------------------------------------------------------
