
--# Sorting lists;

include GtkEngine.e
include std/sort.e

constant 
    win = create(GtkWindow,"size=300x500,border_width=5,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    scroller = create(GtkScrolledWindow),
    box = create(GtkButtonBox,"margin-top=5,margin-bottom=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    
    tstore = create(GtkListStore,{gSTR,gSTR}),
    tcol1 = create(GtkColumn,"title=`First, MI`,type=text,text=1,sort_column_id=1"),
    tcol2 = create(GtkColumn,"title=Last,type=text,text=2,sort_column_id=2"),
    tview = create(GtkTreeView,"rules hint=TRUE,font=Serif,headers visible=TRUE")
    set(tview,{
        {"model",tstore},
        {"append columns",{tcol1,tcol2}}})

object list = {
    "Sam Spade","Jennifer Anniston","arnold Swartzenoggin",
    "Glenda T. Goodwitch","Mary Contrary","Claire De_Loon",
    "Thomas A. Train","Barbarosa","Xavier Cluegot","Joe Schmoe","Sue Mi",
    "Zuzu Pitts","Tad B. Zippo, III","Bill Clinton","wilbur v. filbert",
    "King George","Jane Mansfield","sarah McFee","Albert King",
    "George King","lucile ball","Desi A. Arnaz"}

object tmp, first, mi, last, extra    
for i = 1 to length(list)  do
    first = ' ' mi = ' ' last = ' ' extra = ' '
     tmp = split(list[i]," ") 
     switch length(tmp) do
	case 1 then first = proper(tmp[1])
	case 2 then first = proper(tmp[1]) last = proper(tmp[2])   
        case 3 then first = proper(tmp[1]) mi = proper(tmp[2]) last = proper(tmp[3])
        case 4 then first = proper(tmp[1]) mi = proper(tmp[2]) last = proper(tmp[3]) extra = tmp[4]
     end switch
     list[i] = {first &' '& mi,last &' '& extra}
end for
    
set(tstore,"data",list)

    add(win,panel)
    pack(panel,scroller,TRUE,TRUE)
    add(scroller,tview)
    add(box,btn1)
    pack(panel,-box)
    
show_all(win)
main()





