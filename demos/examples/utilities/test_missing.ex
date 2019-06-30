
------------------------------------------------------------------------
--# finds unused test[n].ex program names
------------------------------------------------------------------------

include GtkEngine.e

constant win = create(GtkWindow,"title=Missing Tests,size=250x-1,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
	add(win,panel)

constant listbox = create(GtkListBox,"margin-top=10,margin bottom=10")
	add(panel,listbox)

constant box = create(GtkButtonBox)
	add(box,create(GtkButton,"gtk-quit","Quit"))
	pack(panel,-box)
	
chdir(canonical_path("~demos"))

boolean missing = FALSE

integer x = length(dir("test*.ex"))-1

for i = 0 to x do
	if file_exists(sprintf("test%d.ex",i)) then -- skip
	else printf(1,"missing test%d.ex\n",i)
	        add(listbox,create(GtkLabel,sprintf("test%d.ex",i)))
	        missing = TRUE
	end if
end for

if not missing then Info(,,"Congrats",
	sprintf("%d demos, none missing",x),,,"face-cool") 

else

  show_all(win)
  main()

end if
