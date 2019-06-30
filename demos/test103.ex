
--# Connecting to the World Wide Web

include GtkEngine.e

constant txt = sprintf(`<b><u>Euphoria</u></b> was created 
by Robert Craig at <a href="http://rapideuphoria.com" title="Click to visit website">RapidEuphoria</a>

and is currently maintained 
by volunteers at <a href="http://OpenEuphoria.org" title="Click to visit the new <span color='red'>OpenEuphoria</span> website">OpenEuphoria</a>

file: <a href="%s" title="Open a local file">README.html</a>`,
{canonical_path(locate_file("documentation/README.html"))})
 
constant 
    win = create(GtkWindow,"border_width=10,position=center,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"), 
    lbl1 = create(GtkLabel,{
    {"markup",txt},
    {"track visited links",TRUE},
    {"connect","activate-link","Foo"}})
    
    add(win,panel)
    add(panel,lbl1)

show_all(win)
main()

-------------------------------------------------------------
global function Foo(atom ctl, object uri)
-------------------------------------------------------------
object img 
sequence Q

uri = peek_string(uri)

if file_exists(uri) then
	img = create(GtkImage,"text-html",6)
	if Question(win,,"Open File",uri,,img) = MB_YES then
		ifdef WINDOWS then
			system("explorer "  & uri)
			return 1
		end ifdef
	    show_uri("file://" & uri)
	end if
	return 1
else 
    if not networked() then 
	return Warn(,host_addr,"Sorry","Not connected to a network")
    end if
	
    if inet_connected() then 
	img = create(GtkImage,"emblem-web",6)
	if Question(win,,"Browse Website",uri,,img) = MB_YES then
	    show_uri(uri)
	end if
    else
	return Warn(,host_addr,"Sorry","No internets!")
    end if
end if
return 1
end function
