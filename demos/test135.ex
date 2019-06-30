
--------------------------------------------------------------------------
--# Valid Icons
--------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Icons</b></u>
This chooses the first <i>valid</i> icon 
from a {list} of icon names you supply.
`
constant win = create(GtkWindow,"border=20,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant lbl1 = create(GtkLabel)
    add(panel,lbl1)
    set(lbl1,"markup",docs)
    
-- list of possible icons to use (some may not exist):
sequence icon = {"face-bogus","face-xcool","face-smile","gtk-ok"}
for i = 1 to length(icon) do
    if has_icon(icon[i]) then
        icon = icon[i]
        exit
    end if
end for

constant img1 = create(GtkImage,icon,256)
    add(panel,img1)
   
constant lbl2 = create(GtkLabel,icon)
    add(panel,lbl2)
 
show_all(win)
main()
