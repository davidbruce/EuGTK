
----------------------------------------------------------------
--# GtkGrid
----------------------------------------------------------------

include GtkEngine.e

sequence position = { -- these are the tooltips to attach to buttons
	`add(grid,btn[1])`,
	`set(grid,"attach",btn[2],1,0,2,1)`,
	`set(grid,"attach next to",btn[3],btn[1],BOTTOM,1,2)`,
	`set(grid,"attach next to",btn[4],btn[3],RIGHT,2,1)`,
	`set(grid,"attach",btn[5],1,2,1,1)`,
	`set(grid,"attach next to",btn[6],btn[5],RIGHT,1,1)`
}

constant 
    win = create(GtkWindow,"position=1,$destroy=Quit"),
    grid = create(GtkGrid)
    add(win,grid)
    
object btn = repeat(0,6)
    for i = 1 to 6 do
	btn[i] = create(GtkButton,sprintf("Button %d",i))
	set(btn[i],"tooltip text",position[i])
    end for
	
    add(grid,btn[1])
    set(grid,{
	{"attach",btn[2],1,0,2,1},
	{"attach next to",btn[3],btn[1],BOTTOM,1,2},
	{"attach next to",btn[4],btn[3],RIGHT,2,1},
	{"attach",btn[5],1,2,1,1},
	{"attach next to",btn[6],btn[5],RIGHT,1,1}})

show_all(win)
main()
