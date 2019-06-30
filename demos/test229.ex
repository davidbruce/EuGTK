
--# GtkSyntaxColors dialog demo <span color='red'>New in 4.14.6</span>

include GtkEngine.e
include syntax_colors.e

constant 
    win = create(GtkWindow,"size=200x200,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,"Syntax Color Popup\n\n   Click the button"),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"thumbnails/4_rhombuses.gif#Colors","DisplayColorScheme")
    
    add(win,pan)
    add(pan,lbl)
    add(box,btn)
    pack(pan,-box)

show_all(win)
main()

---------------------------------------
global function DisplayColorScheme() --
---------------------------------------
run(syntax_colors:dialog)
object txt = {}
object color
object line 
object button = syntax_colors:button
object item = syntax_colors:item

for i = 1 to length(syntax_colors:button) do
    color = get(button[i],"rgba",1)
    
    if i = 2 then
        line = format("<span color='[]'>[] [] []</span>\n",
             {get(button[1],"rgba",1),item[i],color})
    else
        line = format("<span color='[]'>[] [] []</span>\n",
            {color,item[i],color})
    end if

    if get(syntax_colors:italic[i],"active") then
        line = "<i>" & line & "</i>"
    end if
    
    if get(syntax_colors:bold[i],"active") then
        line = "<b>" & line & "</b>"
    end if
    
    txt &= line
    
end for
set(win,"background",syntax_colors:background)
set(lbl,"markup",txt)
return 1
end function

