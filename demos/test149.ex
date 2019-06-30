
include GtkEngine.e

--# tinkering with pixbufs;

ifdef WINDOWS then 
	constant clown = "thumbnails/clown.png"
elsedef
	constant clown = "thumbnails/clown.svg"
end ifdef

constant win = create(GtkWindow,"background=blue,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant pixbox = create(GtkBox,"orientation=HORIZONTAL")
	add(panel,pixbox)

constant pix = create(GdkPixbuf,clown,200,200),
	img1 = create(GtkImage,pix)

constant x1 = get(pix,"add alpha",TRUE,237,0,0) -- 237 is color of bowtie & nose

constant img2 = create(GtkImage,x1)

atom x2 = create(GdkPixbuf,clown,200,200)
	set(pix,"saturate and pixelate",x2,1,TRUE)
	
constant img3 = create(GtkImage,x2)

constant x3 = create(GdkPixbuf,clown,200,200)

constant img4 = create(GtkImage,get(x3,"rotate simple",180))
	add(pixbox,{img1,img2,img3,img4})

constant lbl = create(GtkLabel)
	set(lbl,"color","white")
	set(lbl,"markup",
	  "Original\t\t\t\tAdd alpha transparency\t\tSaturate and Pixelate\t\t\tRotate 180")
	pack(panel,-lbl)

show_all(win)
main()
