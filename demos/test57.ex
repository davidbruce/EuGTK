
---------------------------------------------------------------------------------------
--# GtkTextBuffer sharing; Using GtkEntry for password, progress, RTL text
---------------------------------------------------------------------------------------

include GtkEngine.e

constant update = call_back(routine_id("Update"))

constant 
    win = create(GtkWindow,"size=300x-1,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    lbl0 = create(GtkLabel,"markup=Sharing a text buffer\ntype up to 10 characters"),
    input1 = create(GtkEntry,"max length=10,tooltip text=Standard entry"),
    lbl1 = create(GtkLabel,"Password entry"),
    buffy = get(input1,"buffer"),
    input2 = create(GtkEntry,"visibility=FALSE,alignment=.5,tooltip text=Shown as a password"),
    lbl2 = create(GtkLabel,"RTL"),
    input3 = create(GtkEntry,"alignment=1.0"),
    lbl3 = create(GtkLabel,"Entry as progress"),
    input4 = create(GtkEntry,"text=percent done,alignment=0.5")
    -- above entry does not share buffer, but instead
    -- is used to display progress bar and %;

    add(win,panel)
    add(panel,{lbl0,input1,lbl1,input2,lbl2,input3,lbl3,input4})
    set(input2,"buffer",buffy)
    set(input3,"buffer",buffy)
    connect(buffy,"inserted-text",update)

show_all(win)
main()

------------------------------------------------------------------------
function Update() -- compute & display progress;
------------------------------------------------------------------------
integer len = get(buffy,"length")
    set(input4,"progress fraction",len/10)
    set(input4,"text",sprintf("%d%% done",(len/10)*100))
    -- others update automatically when the buffer contents change;
return 1
end function
