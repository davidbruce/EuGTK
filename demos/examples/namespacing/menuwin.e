 
namespace menu 
 
include GtkEngine.e 
 
export constant    
    
    group = create(GtkAccelGroup), -- container for control/alt keys;

     menubar = create(GtkMenuBar),
    
     filemenu = create(GtkMenuItem,"_File"),
      filesub = create(GtkMenu,{{"accel group",group}}),  
        fileexit = create(GtkMenuItem,"gtk-quit","onClose",,{group,"<ctl>Q"}),

     helpmenu = create(GtkMenuItem,"_Help"),
      helpsub = create(GtkMenu,{{"accel group",group}}),
        helplgpl = create(GtkMenuItem,"_License","onGPL",,{group,"<alt>l"}),
        helpabout = create(GtkMenuItem,"gtk-about","onAbout",,{group,"<alt>a"}),
        helphelp = create(GtkMenuItem,"gtk-help","onHelp",,{group,"F1"})
                
    add(menubar,{filemenu,helpmenu})
    add(filemenu,filesub)
    add(filesub,fileexit)
    add(helpmenu,helpsub)
    add(helpsub,{helplgpl,helphelp,helpabout})
    