
--# Webserver - GUI for httpd.ex

include GtkEngine.e
include std/datetime.e
include std/net/dns.e

ifdef WINDOWS then
	Error(,"Sorry","webserver","does not work on Windows")
end ifdef

export constant version = "1.0"

------------------------------------------------------------------------
-- I use this to serve music or other files to my Google Nexus tablet
-- or smart phone, so I can listen, look at photos, read documentation, 
-- etc. while I work (or not :p)

-- You'll need the server connected to a router, of course,
-- otherwise, you can only serve to localhost.
------------------------------------------------------------------------

-- try to find a working terminal to use for displaying requests;
object term = 0, 
terms = {"mate-terminal","gnome-terminal","cmd.exe","xterm",getenv("TERM")}
for i = 1 to length(terms) do
    terms[i] = locate_file(terms[i]) 
    if file_exists(terms[i]) then
        term = terms[i]
        exit
    end if
end for

constant win = create(GtkWindow,{
    {"border width",20},
    {"default size",300,200},
    {"position",GTK_WIN_POS_CENTER},
    {"title"," EuGTK Web Server"},
    {"icon","~/demos/thumbnails/mongoose.png"}})
    connect(win,"destroy","Quit")

constant panel = create(GtkBox,VERTICAL)
gtk:add(win,panel)

constant addrbox = create(GtkGrid)
    set(addrbox,"column spacing",5)
    set(addrbox,"row spacing",5)
    gtk:add(panel,addrbox)
        
constant
    lbl1 = create(GtkLabel,"IP:"),
    ip = create(GtkEntry), 
    port = create(GtkSpinButton,8080,8090,1),
    lbl3 = create(GtkLabel,"Root"),
    root = create(GtkFileChooserButton),
    lbl4 = create(GtkLabel,"Log file:"),
    logf = create(GtkEntry),
    sortf = create(GtkCheckButton,"_Sort"),
    showreq = create(GtkCheckButton,"Show _Full Request"),
    hidden = create(GtkCheckButton,"Show _Hidden Files"),
    tailf = create(GtkCheckButton,"Tail -f")

    set(ip,"text",get_network_address())
    set(port,"value",8080)
    set(root,"current folder",canonical_path("~/demos/documentation"))
    set(root,"action",GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER)
    set(logf,"text",".server.log") --or blank to hide server log file
    set(sortf,"active",TRUE)
    set(tailf,"active",TRUE)
    
    set(root,"tooltip markup","Choose the base folder.\nEvery subfolder <i>below</i> this will be served")
    set(sortf,"tooltip markup","Sort the directory listings")
    set(showreq,"tooltip markup","Show <i>full request string</i> in logs")
    set(hidden,"tooltip markup","Include hidden files in those being served")
    set(tailf,"tooltip markup","Pop up a window to show active connections")
    
    set(addrbox,"attach",lbl1,1,1,1,1)
    set(addrbox,"attach",ip,2,1,1,1)
    set(addrbox,"attach",port,3,1,1,1)
    set(addrbox,"attach",create(GtkSeparator),1,2,4,1)
    set(addrbox,"attach",lbl3,1,3,1,1)
    set(addrbox,"attach",root,2,3,2,1)
    set(addrbox,"attach",create(GtkSeparator),1,4,4,1)
    set(addrbox,"attach",lbl4,1,5,1,1)
    set(addrbox,"attach",logf,2,5,1,1)
    if not atom(term) then
    set(addrbox,"attach",tailf,3,5,1,1)
    end if
    set(addrbox,"attach",create(GtkSeparator),1,6,4,1)
    set(addrbox,"attach",sortf,1,7,1,1)
    set(addrbox,"attach",showreq,2,7,1,1)
    set(addrbox,"attach",hidden,3,7,1,1)

constant box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-help","Help"),
    btn3 = create(GtkButton,"gtk-ok","StartServer")
    set(btn2,"tooltip markup","Click <i>here</i> for html help")
    set(btn3,"tooltip markup","Click <b>here</b> to start the server")
    set(box,"margin top",10)
    gtk:add(box,{btn1,btn2,btn3})
    pack(panel,-box)
    
show_all(win)
main()

------------------------------
global function StartServer()
------------------------------
object server = canonical_path("~/demos/examples/webserver/httpd.ex")
display("Server: []",{server})

object params = sprintf("eui %s -bind %s:%d ",
    {server,
     remove_all(' ',get(ip,"text")),
     get(port,"value")
     })
object log = get(logf,"text")
object path = get(root,"filename")
chdir(canonical_path(path))

object exe = ""

    if length(path) > 0 then 
        params &= sprintf("-root '%s' ",{current_dir()})
        log = path & "/" & log
    end if

    if length(log) > 0 then
        params &= sprintf("-log %s ",{log})
    end if

    if get(sortf,"active") then
        params &= " -s "
    end if

    if get(hidden,"active") then
        params &=" -h "
    end if

    if get(showreq,"active") then
        params &= " -r "
    end if
    exe = sprintf(`%s -e "%s" &`,{term,params})

    display(exe)
    system(exe)
    
return 1
end function

-----------------------------
global function Help()
-----------------------------
    show_uri(sprintf("file:///%s",
        {canonical_path("~/demos/documentation/ServerHelp.html")}))
return 1
end function

------------------------
-- 2014 by Irv Mullins
------------------------
