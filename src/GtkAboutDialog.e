
------------------
namespace about -- Generic About dialog
------------------

export constant version = "4.15.0"

/*
 * -- EXPORTS:
 *    about:Dialog -- so you can set parameters before running;
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */

include GtkEngine.e
public include euphoria/info.e

if not equal(version,gtk:version) then
    Error(,,"GtkAboutDialog version mismatch","should be version " & gtk:version)
end if

export atom Dialog = create(GtkAboutDialog,{
	{"name","about:dialog"},
	{"logo","thumbnails/eugtk.png"},
	{"program name",prg_name},
	{"version","EuGTK version: " & gtk:version},
	{"copyright",copyright}, -- use EuGTK copyright;
	{"comments","For information on the Euphoria\nprogramming language, click below"},

-- must specify custom as the license type if supplying the license text;
	{"license type",GTK_LICENSE_CUSTOM},
	{"license",LGPL}, -- LGPL boilerplate text is built into EuGTK
	{"wrap license",FALSE},

	{"website","http://OpenEuphoria.org"}, -- url string;
	{"website label","OpenEuphoria"}, -- text string;

	{"authors",{real_name}}, -- sequence of 1 or more strings, default is user's real_name;

-- the following are left blank, so won't show. you can set them in your code:
/*
	{"artists",{"Vinnie vanGo","Andy Warthog"}}, -- sequence of strings required;
	{"documenters",{"Donald Doc","Doc Holliday"}}, -- sequence of strings required;
	{"translator credits","Xcellent Translation Service,Inc."}, -- string only;
	{"add credit section","Special Thanks to",{"Bob's Burgers","Duff's Beer"}},
*/

   $})

/* Quote from GTK docs:

 * The GtkAboutDialog offers a simple way to display information about a program
 * like its logo, name, copyright, website and license. It is also possible to give
 * credits to the authors, documenters, translators and artists who have worked on
 * the program. An about dialog is typically opened when the user selects the About
 * option from the Help menu. All parts of the dialog are optional.
 *
 * About dialogs often contain links and email addresses. GtkAboutDialog displays
 * these as clickable links. By default, it calls gtk_show_uri() when a user clicks
 * one. The behaviour can be overridden with the "activate-link" signal.
 *
 * To specify a person with an email address, use a string like "Edgar Allan Poe <edgarpoe.com>".
 *
 * To specify a website with a title, use a string like "GTK+ team http://www.gtk.org".
 *
*/

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------
