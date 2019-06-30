
--# GtkNotebook with css styling;

include GtkEngine.e

constant provider = create(GtkCssProvider,canonical_path("resources/mystyle6.css"))

constant pgs = { -- text, bg color, icon
 {"Hello World!",  "light yellow", "face-cool"},
 {"Goodbye World!","sky blue",     "face-sad"}
 }
 
constant 
     win = create(GtkWindow,"position=1,border=10,$destroy=Quit"),
     panel = create(GtkBox,"orientation=VERTICAL"),
     box = create(GtkButtonBox),
     btn1 = create(GtkButton,"gtk-quit","Quit"),
     nb = create(GtkNotebook,"name=frame4,size=200x200,popup enable=TRUE")

     for i = 1 to length(pgs) do
     set(nb,"append page",build_page(pgs[i]))
     end for

     add(win,panel)
     add(panel,nb)
     pack(panel,-box)
     add(box,btn1)

show_all(win)
main()

------------------------------
function build_page(object p)
------------------------------
 object pg = create(GtkBox) 
 object eb = create(GtkEventBox)
 pack(pg,eb,1,1) 
 object bx = create(GtkBox,"orientation=HORIZONTAL,margin=10")
 add(eb,bx)
 set(eb,"background",p[2])
 add(bx,create(GtkLabel,{{"markup",p[1]}}))
 object img = create(GtkImage,p[3],100,100,1)
 add(bx,img)
 set(pg,"name",p[3])
return pg
end function




