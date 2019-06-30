<div align="center">
  <img src="https://github.com/davidbruce/EuGTK/blob/master/logo.png?raw=true"/>
  <h3>
    GTK 3 wrapper for <a href="https://openeuphoria.org/">Open Euphoria</a> <br /><a href="http://htmlpreview.github.io/?https://github.com/davidbruce/EuGTK/blob/master/demos/documentation/README.html">View documentation</a>
  </h3>
</div>

# Summary 

A cross-platform GTK3 library for the [Euphoria](http://openeuphoria.org) programming language. EuGTK makes it easy to create modern, professional programs quickly. 

Euphoria is a powerful but easy-to-learn programming language. It has a simple syntax and structure with consistent rules, and is also easy to read. You can quickly, and with little effort, develop applications, big and small, for Windows, Unix variants (Linux, FreeBSD, ...) and OS X. 

EuGTK wraps the [GTK3](http://gtk.org) calls in a sudo object-oriented fashion; you create GTK objects, and then set or get properties of those objects. There's no need to manually lay out "widgets", this is handled automatically. 
No tricky sizing or layout code is required, and all that crazy type-casting you have to do with other programming languages doesn't exist! In addition, EuGTK provides 'wrappers' around several of the more difficult-to-use Gtk widgets (e.g. GtkListView) which makes them much easier to use.

Development is fast, since Euphoria is one of the fastest interpreters available, making the development cycle easy (you just test each line of code as you add it) - and Euphoria can optionally convert your code to C and compile it into an executable with a single call.

For more information:
https://sites.google.com/site/euphoriagtk/Home

# Dependencies
[Euphoria 4.1](https://openeuphoria.org/wiki/view/DownloadEuphoria.wc#betafortestingeuphoria410beta2)

[GTK 3.x](https://www.gtk.org/download/index.php)

**NOTE:** Linux users should install GTK with their package manager and OSX users may want to install via [Macports](https://www.macports.org/)

# Running Example programs
Save the below Hello World program anywhere and run it with
`eui -i path/to/EuGTK/src helloworld.ex`

```
----------------------------------------------------------------------------
--# Example: Yet Another Hello World! program
----------------------------------------------------------------------------

include GtkEngine.e

--[1] create the widgets;

constant   
	win = create(GtkWindow,"border width=10,icon=face-laugh,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical"), 
	box = create(GtkButtonBox), 
	btn = create(GtkButton,"gtk-quit", "Quit"),
	lbl = create(GtkLabel,"color=blue")

--[2] mark up label using basic html; 

    set(lbl,"markup", 
	"<b><u><span color='red'><big>Hello World!</big></span></u></b>\n\n" &
	"This demos a simple window with\na label and a quit button.\n")

--[3] add widgets to containers; 

    add(win,pan)  
    add(pan,lbl)  
    add(box,btn)  
    pack(pan,-box)
 
show_all(win) --[4] instantiate widgets; 
main()        --[5] enter main processing loop; 
```
