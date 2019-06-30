
--# Grid demo

include GtkEngine.e

constant win = create(GtkWindow,{
    {"title","Grid Demo"},
    {"border width",10},
    {"position",GTK_WIN_POS_CENTER}})
    connect(win,"destroy","Quit")
    
constant grid = create(GtkGrid,{
    {"name","grid"},
   -- {"row homogeneous",TRUE}, -- turn row and/or column homogeneous on/off to see diff.
   -- {"column homogeneous",TRUE},
    {"row spacing",5},
    {"column spacing",5},
    {"font",24},
    $})
    add(win,grid)
    
integer i = 1
atom id

for row = 1 to 10 do
    for col = 1 to 10  do
	id = create(GtkLabel,{
	    {"text",sprintf("%3d",i)},
	    {"background",rand(#FFFFFF)},
	    {"color",rand(#FFFFFF)}})
	set(id,"tooltip text",sprintf("col %d row %d",{col,row}))
        set(grid,"attach",id,col,row,1,1)
        i += 1
    end for
end for

show_all(win)
main()
