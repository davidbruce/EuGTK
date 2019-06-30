
------------------------------------------------------------------------
--# Stock Buttons
-- a few buttons may not have icons, don't know why.
------------------------------------------------------------------------

include GtkEngine.e
include std/sort.e

constant list = create(GtkStockList)
object stock_ids = sort(list)
       stock_ids = breakup(stock_ids,5)

constant 
    win = create(GtkWindow,"title=`Stock Buttons`,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    grid = create(GtkGrid),
    lbl = add(panel,create(GtkLabel,{
    {"margin top",5},
    {"markup","<b><u>GtkStockItems</u></b> ~ " &
	"Mouse over buttons to see name, " &
	"change WM themes to see what they look like in different styles"}}))
	
atom btn, pix, icon
    for row = 1 to length(stock_ids) do
	for col = 1 to length(stock_ids[row]) do
	    btn = create(GtkButton,stock_ids[row][col])
	    set(btn,"tooltip text",stock_ids[row][col])
	    set(grid,"attach",btn,col,row,1,1)
	end for
    end for

    add(win,panel)
    add(panel,grid)
    
show_all(win)
main()
