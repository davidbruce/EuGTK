
--# GLX <span color='red'>(NOT IMPLEMENTED!)</span>

include GtkEngine.e
include GtkOpenGL.e

constant
    win = create(GtkWindow,"size=300x300,$destroy=Quit"),
    dwg = create(GtkGLArea,"$realize=Realize,$render=Render")
    
    add(win,dwg)
    
show_all(win)
main()

----------------------------------
global function Realize(atom area)
----------------------------------
set(area,"make current") 
atom err = get(area,"error")
set(area,"error",err)
return 1
end function

-----------------------------------------------
global function Render(atom area, atom context)
-----------------------------------------------
return 1
end function


