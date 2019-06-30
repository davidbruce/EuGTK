
---------------------------------------------------------------
--# GtkSearchEntry
---------------------------------------------------------------

include GtkEngine.e

requires("3.6","GtkSearchEntry")

constant docs = `<u><b>Search Entry</b></u>
(doesn't work on Windows)
`
constant win = create(GtkWindow,{
    {"border width",20},
    {"position",GTK_WIN_POS_CENTER},
    {"default size",300,200},
    {"signal","destroy","Quit"}})

constant panel = add(win,create(GtkBox,VERTICAL))

constant lbl = add(panel,create(GtkLabel,{{"markup",docs}}))

constant se = add(panel,create(GtkSearchEntry,{
    {"placeholder text","Type search term here"},
    {"signal","search-changed","UpdateSearch"},
    {"signal","icon-press","IconPressed"},
    {"icon tooltip markup",GTK_ENTRY_ICON_SECONDARY,"<b>Click</b> to Clear"}}))

constant btn1 = create(GtkButton,"gtk-quit","Quit")
constant btn2 = create(GtkButton,"search#_Search","StartSearch")
constant btn3 = create(GtkButton,"gtk-about","About")
constant box = create(GtkButtonBox)
    pack(panel,-box)
    add(box,{btn1,btn2,btn3})

show_all(win)
set(btn2,"sensitive",FALSE)
set(btn3,"grab focus") -- so that placeholder text will appear;
main()

--------------------------------------------------------------------------
global function IconPressed(atom ctl, integer pos, atom event, atom data)
--------------------------------------------------------------------------
if pos = GTK_ENTRY_ICON_PRIMARY then -- search icon pressed
 StartSearch()
end if
return 1 
end function

-------------------------------
global function StartSearch()
-------------------------------
Info(win,,
    sprintf("Search for <span color='red'>%s</span>",{get(se,"text")}),
    "<small>Not really :)\nThere's no text to search!</small>")
return 1
end function

-------------------------------
global function UpdateSearch()
-------------------------------
if get(se,"text length") then
set(btn2,"sensitive",TRUE)
set(se,"icon sensitive",GTK_ENTRY_ICON_PRIMARY,TRUE)
set(se,"icon activatable",GTK_ENTRY_ICON_PRIMARY,TRUE)
set(se,"icon tooltip markup",GTK_ENTRY_ICON_PRIMARY,"<b>Click</b> to start search")
else
set(btn2,"sensitive",FALSE)
set(se,"icon sensitive",GTK_ENTRY_ICON_PRIMARY,FALSE)
set(se,"icon activatable",GTK_ENTRY_ICON_PRIMARY,FALSE)
set(se,"icon tooltip markup",GTK_ENTRY_ICON_PRIMARY,"Enter some text")
end if
return 1
end function

------------------------------
global function About()
------------------------------
Info(,"About",
"GtkSearchEntry\n",
`A subclass of GtkEntry that has been tailored 
 for use as a search entry.

 It will show an inactive symbolic "find" icon 
 when the search entry is empty, and a symbolic 
 "clear" icon when there is text. Clicking on the 
 "clear" icon will empty the search entry.

 Note that the search/clear icon is shown using 
 a secondary icon, and thus does not work if you
 are using the secondary icon position for some other purpose.

 To make filtering appear more reactive, it is a good 
 idea to not react to every change in the entry text 
 immediately, but only after a short delay. 
 To support this, GtkSearchEntry emits the "search-changed" 
 signal which can be used instead of the "changed" signal.
 
 The "previous-match", "next-match" and "stop-search" signals 
 can be uesd to implement moving between search results and 
 ending the search.

 Often, GtkSearchEntry will be fed events by means of being 
 placed inside a GtkSearchBar. If that is not the case, you 
 can use gtk_search_entry_handle_event() to pass events.`)
 
 return 1
end function
