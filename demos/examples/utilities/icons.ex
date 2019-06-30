
---------------------------------------------------------------
--# Categorize, search, and display available icons.

-- tooltip for each icon displays the actual file path to icon.
-- double-clicking icon saves the icon to your home folder.
---------------------------------------------------------------

include GtkEngine.e
include std/sort.e
include std/wildcard.e
include std/datetime.e

constant docs = {
`<b><u>Themed Icons</u></b>

Select an icon category below, then click OK,
or enter a search string in the box at bottom,
and click Find or hit enter.

Double-click an icon to copy it to your home folder
at the size you set via the slider.
`,

`Enter a search string here,
 hit enter or click the find button`,

`
---------------------------------------------------------
-- NOTE: this file will be regenerated when you        --
-- run icons.ex, and will probably show different      --
-- icons from the ones I've listed here, since they    -- 
-- vary depending upon the window theme in use.        --                      
---------------------------------------------------------

`}

-- load current icons in default theme;
atom theme = create(GtkIconTheme)
object contexts = get(theme,"list contexts")
object list

-- write icon names to a text file for later reference;
atom fn = open(locate_file("resources/themeicons.txt"),"w")
puts(fn,docs[3])
puts(fn,datetime:format(datetime:now(),"Generated %A %B %d, %Y "))
printf(fn,"by %s on %s\n\n",{user_name,host_name})
object icons = repeat(0,length(contexts))
for i = 1 to length(contexts) do
    contexts[i] &= 0
    icons[i] = sort(get(theme,"list icons",contexts[i]))
    contexts[i] = {contexts[i],length(icons[i])}
    printf(fn,"Context: %s\n\t%d Icons:\n",contexts[i])
    for n = 1 to length(icons[i]) do
        printf(fn,"\t\t %s\n",{icons[i][n]})
    end for
    puts(fn,"\n")
end for
close(fn)

constant iconwin = create(GtkWindow,{  -- window for display of icons;
    {"default size", 640,600},
    {"deletable",FALSE},
    {"type hint",GDK_WINDOW_TYPE_HINT_MENU},
    {"position",GTK_WIN_POS_CENTER},
    {"icon","emblem-system"}})

constant iconpanel = create(GtkBox,VERTICAL)
    gtk:add(iconwin,iconpanel)

constant iscroller = create(GtkScrolledWindow)
    pack(iconpanel,iscroller,TRUE,TRUE)

constant iv = create(GtkIconView,{
    {"text column",1},
    {"pixbuf column",2},
    {"item width",90},
    {"columns",4},
    {"tooltip column",3}})
    gtk:add(iscroller,iv)
connect( iv,"item-activated",_("CopyIcon"))

constant istore = create(GtkListStore,{gSTR,gPIX,gSTR}) -- icon list;
    set(iv,"model",istore)

constant mainwin = create(GtkWindow,{ -- main window;
    {"title","System Icons"},
    {"default size",300,400},
    {"border width",10},
    {"move",0,0},
    {"icon","emblem-system"},
    {"connect","destroy",_("Bail")}})
    
constant panel = create(GtkBox,VERTICAL)
    gtk:add(mainwin,panel)
    
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs[1])
    gtk:add(panel,lbl)

object catstore = create(GtkListStore,{gSTR,gINT}) -- category list;
    set(catstore,"data",contexts) 

constant tv = create(GtkTreeView,{
    {"model",catstore},
    {"margin bottom",5},
    {"tooltip text","Select a category, then click the OK button"}})
    pack(panel,tv,TRUE,TRUE)
    connect(tv,"row-activated",_("DisplayIcons"))

constant selection = get(tv,"selection")
    set(selection,"mode",GTK_SELECTION_SINGLE)

constant rend1 = create(GtkCellRendererText),
    col1 = create(GtkTreeViewColumn,{
    {"pack start",rend1},
    {"add attribute",rend1,"text",1},
    {"title","Category"}})

constant rend2 = create(GtkCellRendererText),
    col2 = create(GtkTreeViewColumn,{
    {"pack start",rend2},
    {"add attribute",rend2,"text",2},
    {"title","# of icons"}})
    set(tv,"append columns",{col1,col2})

constant btn1 = create(GtkButton,"gtk-quit",_("Bail")),
    btn2 = create(GtkButton,"stock_search#_Search"),
    btn3 = create(GtkButton,"gtk-ok"),
    btnbox = create(GtkButtonBox)
    
    connect(btn2,"button-press-event",_("on_btn_down"))
    connect(btn2,"clicked",_("Search"))
    
    connect(btn3,"button-press-event",_("on_btn_down")) -- start wait cursor;
    connect(btn3,"clicked",_("DisplayIcons")) -- then load icons;
    
    gtk:pack(panel,-btnbox)
    gtk:add(btnbox,{btn1,btn2,btn3})
    set(btn1,"tooltip markup","Click to quit")
    set(btn2,"tooltip markup","Click to find all icons containing search string")
    set(btn3,"tooltip markup","Click to display all icons in selected category")

constant srch = create(GtkEntry,{  -- search entry;
    {"tooltip text",docs[2]},
    {"margin bottom",10},
    {"placeholder text","Enter search string here, click find button"}})
    connect(srch,"activate",_("Search"))
    
constant adj = create(GtkAdjustment,48,16,512,16,1)
constant size = create(GtkScale,HORIZONTAL,adj)
    set(size,"digits",0)
    set(size,"tooltip text","Select Icon Size")
    
constant pan2 = create(GtkBox,HORIZONTAL)
    pack(panel,-pan2)
    pack(pan2,srch)
    pack(pan2,size,1,1)
    
show_all(mainwin)
main()

function on_btn_down() -- show 'wait' cursor while loading;
    set(mainwin,"cursor",GDK_WATCH)
return 0
end function

function on_btn_up() -- show normal cursor;
    set(mainwin,"cursor",GDK_ARROW)
return 0
end function

----------------------------------
function CopyIcon(atom iv)
----------------------------------
integer x = get(iv,"cursor") -- get index of clicked icon;

object copyto = getenv("HOME") 
object output_file, file_extension
integer is_svg = equal("svg",fileext(list[x][3]))
 if is_svg then
     output_file = allocate_string(sprintf("%s/%s.png",{copyto,filebase(list[x][3])}))
     file_extension = allocate_string("png")
 else 
    file_extension = allocate_string(fileext(list[x][3]))
    output_file = allocate_string(sprintf("%s/%s",{copyto,filename(list[x][3])}))
 end if

 atom pix
 atom err = allocate(8) err = 0

if Question(mainwin,,"Copy this icon?",list[x][1],,
    list[x][1]) = MB_YES then
        if is_svg then
            pix = create(GdkPixbuf,list[x][3],get(size,"value"),0,1)
            gtk_func("gdk_pixbuf_save",{P,P,P,P,P},
                {pix,output_file,file_extension,err,0})
        else -- save in original format;
           gtk_func("gdk_pixbuf_save",{P,P,P,P,P},
                {list[x][2],output_file,file_extension,err,0})
        end if
end if

return 1
end function

--------------------------------
function DisplayIcons()
--------------------------------
atom img    

object n = get(selection,"selected row") 
object cat = contexts[n][1] 
object name, info, 
   flags = GTK_ICON_LOOKUP_FORCE_SVG 
         + GTK_ICON_LOOKUP_USE_BUILTIN 
         + GTK_ICON_LOOKUP_FORCE_SIZE
         + GTK_ICON_LOOKUP_FORCE_REGULAR
    set(iconwin,"title",cat)
    set(istore,"clear")
    list = repeat({0,0,0},length(icons[n]))
    
    for i = 1 to length(icons[n]) do
        name = icons[n][i]
        info = icon_info(name) 
        list[i][1] = name
        list[i][2] = get(theme,"load icon",name,get(size,"value"),flags,0)
        if string(info[3]) then -- tooltip is filename;
            list[i][3] = info[3] 
        else 
            list[i][3] = name 
        end if 
    end for
    
    set(istore,"data",list)
    show_all(iconwin)

set(mainwin,"cursor",GDK_ARROW)

return 1
end function

----------------------------------
function Search()
----------------------------------
object x = get(srch,"text")
atom img
integer ct = 0
object name, info,
    flags = GTK_ICON_LOOKUP_FORCE_SVG 
         + GTK_ICON_LOOKUP_USE_BUILTIN 
         + GTK_ICON_LOOKUP_FORCE_SIZE
         + GTK_ICON_LOOKUP_FORCE_REGULAR
   
 list = {}
 
    if length(x) > 0 then
        set(istore,"clear")
        x = "*" & lower(x) & "*"
        set(srch,"text",x)
        
        for i = 1 to length(contexts) do
            for j = 1 to length(icons[i]) do
                name = icons[i][j]
                if is_match(x,name) then
                    info = icon_info(name)
                    img = get(theme,"load icon",name,get(size,"value"),flags,0)
                    if string(info[3]) then
			list = append(list,{name,img,info[3]})  -- tooltip
                    end if
                    ct += 1
                end if
            end for
        end for
        
        set(istore,"data",list)
        show_all(iconwin)
        set(iconwin,"title",sprintf("Search results for %s:    %d found",{x,ct}))
        
    end if

set(mainwin,"cursor","default")

return 1
end function

------------------------
function Bail()
------------------------
Info(mainwin,,
    "The icon names for this theme\nhave been written to:",
        "~/demos/resources/themeicons.txt")
Quit()
return 1
end function
