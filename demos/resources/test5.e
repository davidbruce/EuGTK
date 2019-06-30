
include GtkEngine.e

-- This is some boilerplate text used by test5.ex to demonstrate markup.
--
-- Note that in the first line of text, we offer GTK a choice of fonts;
-- it will use the first available.
--
-- This is necessary since Windows, for example, probably won't have
-- URW Chancery L, and Linux may not have Comic Sans MS! The fallback
-- if neither exists is sans. Font names are separated by commas, 
-- Whichever font is found will be 32 point. Size comes last, not preceeded
-- by a comma.

export constant text = 
"""
<span font='Purisa, URW Chancery L, Comic Sans MS, Sans 32'>Hello <b>World!</b></span> 

<span color='red' size='xx-large'>Howdy!</span>

<span underline_color='green' strikethrough_color='blue'>
This is <u>underlined</u> <sub>subscripted</sub> 
this is <s>strike thru</s> <sup>superscripted</sup> </span>
this is <span underline='double' color='blue'>double underlined</span>
this is an <span underline='error' color='red'>error</span>
XML: &#169; 2015 Naskapi woo: &#5142; and &#223; &#64275; as well.
"""

export constant docs = 
sprintf(`You can use <b>Markup</b> similar to html to set the style of text. 
See <a href="file://%s">Pango Markup</a>.
`,
{canonical_path("~/demos/documentation/pango_markup.html")})

