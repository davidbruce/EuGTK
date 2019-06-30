
------------------
namespace cairo -- wrapper for cairo graphics;
------------------

export constant version = "4.15.0"

/*
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

if not equal(version,gtk:version) then
    Error(,,"GtkCairo version mismatch","should be version " & gtk:version)
end if

export constant pango_version = gtk_str_func("pango_version_string")

widget[GdkCairo_t] = {"gdk_cairo",
{Cairo_t},
    {"new",{P},-routine_id("newGdkCairo")},
    {"draw_from_gl",{P,P,I,I,I,I,I,I,I}}, -- 3.16
    {"get_clip_rectangle",{P},-routine_id("getClipRect")},
    {"set_source_pixbuf",{P,P,D,D}},
    {"set_source_window",{P,P,D,D}},
    {"region",{P,P}},
    {"region_create_from_surface",{P},P},
    {"surface_create_from_pixbuf",{P,I,P},P,0,CairoSurface_t},
    {"set_source_rgba",{P,I,I,I,D},-routine_id("setCairoRGBA")},
    {"set_color",{P,P},-routine_id("setCairoColor")},
"GdkCairo_t"}

    function getClipRect(atom cr)
    atom fn = define_func("gdk_cairo_get_clip_rectangle",{P,P},B)
    atom rect = allocate(8,1)
    if c_func(fn,{cr,rect}) then
	return rect
    else return -1
    end if
    end function
    
    function newGdkCairo(atom win)
    return gtk_func("gdk_cairo_create",{P},{win})
    end function
    
    ----------------------------------------------------------------
    -- to use the Cairo color specs, where colors are 0.0 => 1.0
    ----------------------------------------------------------------------
    function setCairoRGBA(atom cr, atom r, atom g, atom b, atom a=1)
    gtk_proc("cairo_set_source_rgba",{P,D,D,D,D},{cr,r,g,b,a})
    return 1
    end function
    
    --------------------------------------------
    -- it's easier to use named colors
    --------------------------------------------
    function setCairoColor(atom cr, object color)
    if atom(color) then color = sprintf("#%06x",color) end if
    color = to_rgba(color)
    color = from_rgba(color,4) -- {r,g,b,a}
    setCairoRGBA(cr,color[1],color[2],color[3],color[4])
    return 1
    end function

widget[Cairo_t] = {"cairo",
{GObject},
    {"create",{P},P},
    {"reference",{P},P},
    {"destroy",{P}},
    {"status",{P},I},
    {"save",{P}},
    {"restore",{P}},
    {"get_target",{P},P,0,CairoSurface_t},
    {"push_group",{P}},
    {"push_group_with_content",{P,P}},
    {"pop_group",{P},P},
    {"pop_group_to_source",{P}},
    {"get_group_target",{P},P},
    {"set_source_rgb",{P,D,D,D}},
    {"set_source",{P,P}},
    {"get_source",{P},P},
    {"set_source_surface",{P,P,D,D}},
    {"set_antialias",{P,I}},
    {"get_antialias",{P},I},
    {"set_dash",{P,P,I,D}},
    {"get_dash_count",{P},I},
    {"get_dash",{P,D,D}},
    {"set_fill_rule",{P,I}},
    {"get_fill_rule",{P},I},
    {"set_line_cap",{P,I}},
    {"get_line_cap",{P},I},
    {"set_line_join",{P,I}},
    {"get_line_join",{P},I},
    {"set_line_width",{P,D}},
    {"get_line_width",{P},D},
    {"set_miter_limit",{P,I}},
    {"get_miter_limit",{P},I},
    {"set_operator",{P,I}},
    {"get_operator",{P},I},
    {"set_tolerance",{P,D}},
    {"get_tolerance",{P},D},
    {"clip",{P}},
    {"clip_preserve",{P}},
    {"clip_extents",{P,D,D,D,D}},
    {"in_clip",{P,D,D},B},
    {"reset_clip",{P}},
    {"rectangle_list_destroy",{P}},
    {"fill",{P}},
    {"fill_preserve",{P}},
    {"fill_extents",{P,D,D,D,D}},
    {"in_fill",{P,D,D},B},
    {"mask",{P,P}},
    {"mask_surface",{P,P,D,D}},
    {"paint",{P}},
    {"paint_with_alpha",{P,D}},
    {"stroke",{P}},
    {"stroke_preserve",{P}},
    {"stroke_extents",{P,D,D,D,D}},
    {"in_stroke",{P,D,D},B},
    {"copy_page",{P}},
    {"show_page",{P}},
    {"copy_path",{P},P},
    {"copy_path_flat",{P},P},
    {"path_destroy",{P}},
    {"append_path",{P,P}},
    {"has_current_point",{P},B},
    {"get_current_point",{P,D,D}},
    {"new_path",{P}},
    {"new_sub_path",{P}},
    {"close_path",{P}},
    {"set_user_data",{P,S,P,P},I},
    {"get_user_data",{P,S}},
    {"arc",{P,D,D,D,D,D}},
    {"arc_negative",{P,D,D,D,D,D}},
    {"move_to",{P,D,D}},
    {"rel_move_to",{P,D,D}},
    {"line_to",{P,D,D}},
    {"rel_line_to",{P,D,D}},
    {"rectangle",{P,D,D,D,D}},
    {"glyph_path",{P,I,I}},
    {"text_path",{P,S}},
    {"curve_to",{P,D,D,D,D,D,D}},
    {"rel_curve_to",{P,D,D,D,D,D,D}},
    {"path_extents",{P,D,D,D,D}},
    {"set_font_face",{P,S}},
    {"device_get_type",{P},I},
    {"device_status",{P},I},
    {"status_to_string",{I},S},
    {"translate",{P,D,D}},
    {"scale",{P,D,D}},
    {"rotate",{P,D}},
    {"transform",{P,P}},
    {"translate",{P,D,D}},
    {"scale",{P,D,D}},
    {"rotate",{P,D}},
    {"transform",{P,P}},
    {"set_matrix",{P,P}},
    {"get_matrix",{P,P}},
    {"identity_matrix",{P}},
    {"user_to_device",{P,D,D}},
    {"user_to_device_distance",{P,D,D}},
    {"device_to_user",{P,D,D}},
    {"device_to_user_distance",{P,D,D}},
    {"version",{},I},
    {"version_string",{},S},
    {"set_font_size",{P,D}},
    {"set_font_matrix",{P,P}},
    {"get_font_matrix",{P,P}},
    {"set_font_options",{P,P}},
    {"get_font_options",{P,P}},
    {"select_font_face",{P,S,I,I}},
    {"get_font_face",{P},P},
    {"set_scaled_font",{P,P}},
    {"get_scaled_font",{P},P},
    {"show_glyphs",{P,P}},
    {"show_text_glyphs",{P,S,I,P,I,P,I,I}},
    {"font_extents",{P,P}},
    {"text_extents",{P,S,P}},
    {"glyph_extents",{P,P,I,P}},
    {"toy_font_face_create",{S,I,I},P},
    {"toy_font_face_get_slant",{P},I},
    {"toy_font_face_get_weight",{P},I},
    {"glyph_allocate",{I},P},
    {"glyph_free",{P}},
    {"text_cluster_allocate",{I},P},
    {"text_cluster_free",{P}},
    {"show_text",{P,S}},
    {"set_source_rgba",{P,D,D,D,D},-routine_id("setCairoRGBA")},
    {"set_color",{P,S},-routine_id("setCairoColor")},
    {"should_draw_window",{P,P},-routine_id("CairoShouldDrawWin")},
    {"transform_to_window",{P,P,P},-routine_id("CairoTransformToWin")},
"Cairo_t"}

    function CairoShouldDrawWin(atom cr, atom win)
    return gtk_func("gtk_cairo_should_draw_window",{P,P},{cr,win})
    end function
    
    function CairoTransformToWin(atom cr, atom win1, atom win2)
    gtk_proc("gtk_cairo_transform_to_window",{P,P,P},{cr,win1,win2})
    return 1
    end function
    
widget[CairoPattern_t] = {0,
{Cairo_t},
"CairoPattern_t"}

widget[CairoFontOptions] = {"cairo_font_options",
{0},
"CairoFontOptions"}

widget[CairoContent_t] = {0,
{Cairo_t},
"CairoContent_t"}

widget[CairoStatus_t] = {0,
{0},
"CairoStatus_t"}

widget[CairoPattern] = {"cairo_pattern",
{CairoPattern_t},
    {"new",{P},-routine_id("newCairoPattern")},
    {"add_color_stop_rgb",{P,D,D,D,D}},
    {"add_color_stop_rgba",{P,D,D,D,D,D}},
    {"get_color_stop_count",{P,I},P,0,CairoStatus_t},
    {"get_color_stop_rgba",{P,I,D,D,D,D,D},P,0,CairoStatus_t},
    {"create_rgb",{D,D,D},P,0,CairoPattern_t},
    {"create_rgba",{D,D,D,D},P,0,CairoPattern_t},
    {"get_rgba",{P,D,D,D,D},P,0,CairoPattern_t},
    {"create_for_surface",{P},P,0,CairoPattern_t},
    {"reference",{P},P,0,CairoPattern_t},
    {"destroy",{P}},
    {"status",{P},P,0,CairoStatus_t},
    {"set_extend",{P,I}},
    {"get_extend",{P},I},
    {"set_filter",{P,I}},
    {"get_filter",{P},I},
    {"set_matrix",{P,P}},
    {"get_matrix",{P,P}},
    {"get_type",{P},I},
    {"get_reference_count",{P},I},
"CairoPattern"}

    function newCairoPattern(atom surf)
    return gtk_func("cairo_pattern_create_for_surface",{P},{surf})
    end function

widget[CairoLinearGradient] = {"cairo_pattern",
{CairoPattern},
    {"new",{D,D,D,D},-routine_id("newLinearGradient"),0,CairoPattern_t},
    {"get_linear_points",{P,D,D,D,D},P,0,CairoStatus_t},
"CairoLinearGradient"}

    function newLinearGradient(atom a, atom b, atom c, atom d)
    return gtk_func("cairo_pattern_create_linear",{D,D,D,D},{a,b,c,d})
    end function

widget[CairoRadialGradient] = {"cairo_pattern",
{CairoPattern},
    {"new",{D,D,D,D,D,D},-routine_id("newRadialGradient"),0,CairoPattern_t},
    {"get_radial_circles",{P,D,D,D,D,D,D},P,0,CairoStatus_t},
"CairoRadialGradient"}

    function newRadialGradient(atom a, atom b, atom c, atom d, atom e, atom f)
    return gtk_func("cairo_pattern_create_radial",{D,D,D,D,D,D},{a,b,c,d,e,f})
    end function
    
widget[CairoRegion_t] = {"cairo_region_t", -- FIXME!
{Cairo_t},
"CairoRegion_t"}

widget[CairoSurface_t] = {"cairo_surface_t",
{Cairo_t},
    {"get_write_to_png",{P,S},-routine_id("writetoPNG")},
    {"create_similar",{P,P,I,I},P,0,CairoSurface_t},
    {"create_for_rectangle",{P,D,D,D,D},P,0,CairoSurface_t},
    {"reference",{P},P,0,CairoSurface_t},
    {"destroy",{P}},
    {"finish",{P}},
    {"flush",{P}},
    {"get_font_options",{P,P}},
    {"mark_dirty",{P}},
    {"mark_dirty_rectangle",{P,I,I,I,I}},
    {"show_page",{P}},
"CairoSurface_t"}

    function writetoPNG(atom surf, object name) -- note difference in call name;
    return gtk_func("cairo_surface_write_to_png",{P,S},{surf,name})
    end function

widget[CairoImageSurface] = {"cairo_image_surface",
{CairoSurface_t},
    {"new",{P},-routine_id("newCairoImageSurface")},
    {"get_format",{P},I},
    {"get_width",{P},P},
    {"get_height",{P},P},
    {"get_stride",{P},I},
"CairoImageSurface"}

    function newCairoImageSurface(object png)
    if string(png) then
	png = locate_file(png) 
	if file_type(png) = 1 then
	    png = allocate_string(png)
        end if
    end if
    return gtk_func("cairo_image_surface_create_from_png",{S},{png})
    end function

widget[PangoCairoLayout] = {"pango_cairo",
{PangoLayout},
    {"new",{P},-routine_id("newPangoCairoLayout")},
    {"update_layout",{P,P},-routine_id("updateLayout")},
    {"show_glyph_string",{P,P,P}},
    {"show_glyph_item",{P,S,P}},
    {"show_layout_line",{P,P}},
    {"layout_line_path",{P,P}},
    {"layout_path",{P,P}},
"PangoCairoLayout"}

    function newPangoCairoLayout(atom cr)
    atom pcl = gtk_func("pango_cairo_create_layout",{P},{cr})
    register(pcl,PangoLayout)
    return pcl
    end function

    function updateLayout(atom pl, atom cr) -- params swapped;
    gtk_proc("pango_cairo_update_layout",{P,P},{cr,pl})
    return 1
    end function

widget[PangoFont] = {"pango_font",
{0},
    {"describe",{P},P,0,PangoFontDescription},
    {"describe_with_absolute_size",{P},P,0,PangoFontDescription},
    {"get_coverage",{P,P},P},
    {"get_metrics",{P,P},P},
    {"get_font_map",{P},P,0,PangoFontMap},
"PangoFont"}

widget[PangoAttrList] = {"pango_attr_list",
{0},
    {"new",{},P},
    {"copy",{P,P},P,0,PangoAttrList},
    {"insert",{P,P}},
    {"change",{P,P}},
    {"splice",{P,P,I,I}},
    {"filter",{P,P,P},P,0,PangoAttrList},
    {"get_iter",{P},P},
    {"iterator_next",{P},B},
    {"destroy",{P}},
"PangoAttrList"}

widget[PangoFontDescription] = {"pango_font_description",
{PangoFont},
    {"new",{P},-routine_id("newPangoFontDescription")},
    {"copy",{P},P,0,PangoFontDescription},
    {"copy_static",{P},P,0,PangoFontDescription},
    {"hash",{P},I},
    {"equal",{P,P},B},
    {"free",{P}},
    {"set_family",{P,S}},
    {"set_family_static",{P,S}},
    {"get_family",{P},S},
    {"set_style",{P,I}},
    {"get_style",{P},I},
    {"set_variant",{P,I}},
    {"get_variant",{P},P},
    {"set_weight",{P,I}},
    {"get_weight",{P},I},
    {"set_stretch",{P,I}},
    {"get_stretch",{P},I},
    {"set_size",{P,I}},
    {"get_size",{P},I},
    {"set_absolute_size",{P,D}},
    {"get_size_is_absolute",{P},B},
    {"set_gravity",{P,I}},
    {"get_gravity",{P},I},
    {"get_set_fields",{P},I},
    {"unset_fields",{P,I}},
    {"merge",{P,P,B}},
    {"merge_static",{P,P,B}},
    {"better_match",{P,P,P},B},
    -- from_string, see new
    {"to_string",{P},S},
    {"to_filename",{P},S},
"PangoFontDescription"}

    function newPangoFontDescription(object name=0)
    if atom(name) then
	return gtk_func("pango_font_description_new")
    else 
	return gtk_func("pango_font_description_from_string",{P},{allocate_string(name,1)})
    end if
    end function
	
widget[PangoContext] = {"pango_context",
{GObject},
    {"new",{},P},   
    {"load_font",{P,P},P},
    {"load_fontset",{P,P,P},P},
    {"get_metrics",{P,P,P},P},
    {"list_families",{P,A,I}},
    {"set_font_description",{P,P}},
    {"get_font_description",{P},P,0,PangoFontDescription},
    {"set_font_map",{P,P}},
    {"get_font_map",{P},P},
    {"set_base_gravity",{P,I}},
    {"get_language",{P},P},
    {"set_language",{P,P}},
    {"get_layout",{P},P},
    {"get_base_dir",{P},I},
    {"set_base_dir",{P,I}},
    {"get_base_gravity",{P},I},
    {"set_base_gravity",{P,I}},
    {"get_gravity",{P},I},
    {"get_gravity_hint",{P},I},
    {"set_gravity_hint",{P,I}},
    {"get_matrix",{P},P},
    {"set_matrix",{P,P}},
"PangoContext"}

widget[PangoFontsetSimple] = {"pango_fontset_simple",
{GObject},
    {"new",{P},P},
    {"append",{P,P}},
    {"size",{P},I},
"PangoFontsetSimple"}

widget[PangoFontSet] = {"pango_fontset",
{PangoFontsetSimple},
    {"get_font",{P,I},P,0,PangoFont},
    {"get_metrics",{P},P},
    {"foreach",{P,P,P}},
"PangoFontSet"}

widget[PangoFontMap] = {"pango_font_map",
{PangoFontSet},
    {"create_context",{P},P},
    {"load_font",{P,P,S},P},
    {"load_fontset",{P,P,S,P},P},
    {"list_families",{P,A,I}},
    {"get_shape_engine_type",{P},S},
    {"get_serial",{P},I},
    {"changed",{P}}, 
"PangoFontMap"}

widget[PangoFontFace] = {"pango_font_face",
{PangoFontMap},
    {"get_face_name",{P},S},
    {"list_sizes",{P,P,I}},
    {"describe",{P},P,0,PangoFontDescription},
    {"is_synthesized",{P},B},
"PangoFontFace"}

widget[PangoFontFamily] = {"pango_font_family",
{PangoFontFace},
    {"get_name",{P},S},
    {"is_monospace",{P},B},
    {"list_faces",{P,P,I}},
"PangoFontFamily"}

widget[PangoLayout] = {"pango_layout",
{GObject},
    {"new",{P},-routine_id("newPangoLayout")},
    {"set_text",{P,P},-routine_id("pl_set_text")},
    {"get_text",{P},S},
    {"get_character_count",{P},I},
    {"set_markup",{P,S},-routine_id("pl_set_markup")},
    {"set_markup_with_accel",{P,S,I,I},-routine_id("pl_set_markup_with_accel")},
    {"set_font_description",{P,P}},
    {"get_font_description",{P},P},
    {"set_attributes",{P,P}},
    {"get_attributes",{P},P,0,PangoAttrList},
    {"set_width",{P,I}},
    {"get_width",{P},I},
    {"set_height",{P,I}},
    {"get_height",{P},I},
    {"get_size",{P,I,I}},
    {"get_pixel_size",{P,I,I}},
    {"set_wrap",{P,I}},
    {"get_wrap",{P},I},
    {"is_wrapped",{P},B},
    {"set_ellipsize",{P,I}},
    {"get_ellipsize",{P},I},
    {"is_ellipsized",{P},B},
    {"set_indent",{P,I}},
    {"get_extents",{P,P,P}},
    {"get_indent",{P},I},
    {"get_pixel_size",{P,I,I}},
    {"get_size",{P,I,I}},
    {"set_spacing",{P,I}},
    {"get_spacing",{P},I},
    {"set_justify",{P,B}},
    {"get_justify",{P},B},
    {"set_auto_dir",{P,B}},
    {"get_auto_dir",{P},B},
    {"set_alignment",{P,P}},
    {"get_alignment",{P},P},
    {"set_tabs",{P,A}},
    {"get_tabs",{P},A},
    {"set_single_paragraph_mode",{P,B}},
    {"get_single_paragraph_mode",{P},B},
    {"get_unknown_glyphs_count",{P},I},
    {"get_log_attrs",{P,P,I}},
    {"get_log_attrs_readonly",{P,I},P},
    {"index_to_pos",{P,I,P}},
    {"index_to_line_x",{P,I,B,I,I}},
    {"xy_to_line",{P,I,I,I,I},B},
    {"get_cursor_pos",{P,I,P,P}},
    {"move_cursor_visually",{P,B,I,I,I,I,I}},
    {"get_pixel_extents",{P,P,P}},
    {"get_baseline",{P},I},
    {"get_line_count",{P},I},
    {"get_line",{P,I},P,0,PangoLayoutLine},
    {"get_line_readonly",{P,I},P,0,PangoLayoutLine},
    {"get_lines",{P},A,0,GSList},
    {"get_lines_readonly",{P},A,0,GSList},
    {"get_iter",{P},P,0,PangoLayoutIter},
    {"show_layout",{P,P},-routine_id("pl_show_layout")},
    {"get_context",{P},P,0,PangoContext},
    {"context_changed",{P}},
    {"get_serial",{P},I},
    {"get_extents",{P,P,P}},
"PangoLayout"}

    function newPangoLayout(atom cr=0)
     if cr=0 then
         Error(,,"requires cairo_t or pango layout as param!")
     end if
     if class_id(cr) = PangoContext then
         return gtk_func("pango_layout_new",{P},{cr})
     end if
     return gtk_func("pango_cairo_create_layout",{P},{cr})
    end function
    
    function pl_set_text(atom layout, object txt)
	if string(txt) then
	    txt = allocate_string(txt,1)
	end if
	gtk_proc("pango_layout_set_text",{P,P,I},{layout,txt,-1})
     return 1
    end function
	
    function pl_set_markup(atom layout, object txt)
	if string(txt) then
	    txt = allocate_string(txt,1)
	end if
	gtk_proc("pango_layout_set_markup",{P,P,I},{layout,txt,-1})
     return 1
    end function
    
    function pl_set_markup_with_accel(atom layout, object txt, 
	integer marker, integer char)
        if string(txt) then
            txt = allocate_string(txt,1)
        end if
        gtk_proc("pango_layout_set_markup_with_accel",{P,P,I,I,I},
	    {layout,txt,-1,marker,char})
     return 1
    end function
    
    function pl_show_layout(atom pcl, atom cr)
        gtk_proc("pango_cairo_show_layout",{P,P},{cr,pcl})
     return 1
    end function
 
widget[PangoLayoutLine] = {"pango_layout_line",
{0},
    {"ref",{P},P},
    {"unref",{P}},
    {"get_extents",{P,P,P}},
    {"get_pixel_extents",{P,P,P}},
    {"index_to_x",{P,I,B,I}},
    {"x_to_index",{P,I,I,I},B},
    {"get_x_ranges",{P,I,I,P,P}},
"PangoLayoutLine"}

widget[PangoLayoutIter] = {"pango_layout_iter",
{0},
    {"copy",{P},P,0,PangoLayoutIter},
    {"free",{P}},
    {"next_run",{P},B},
    {"next_char",{P},B},
    {"next_cluster",{P},B},
    {"next_line",{P},B},
    {"at_last_line",{P},B},
    {"get_index",{P},I},
    {"get_baseline",{P},I},
    {"get_run",{P},P,0,PangoLayoutRun},
    {"get_run_readonly",{P},P,0,PangoLayoutRun},
    {"get_line",{P},P,0,PangoLayoutLine},
    {"get_line_readonly",{P},P,0,PangoLayoutLine},
    {"get_layout",{P},P,0,PangoLayout},
    {"get_char_extents",{P,P}},
    {"get_cluster_extents",{P,P,P}},
    {"get_run_extents",{P,P,P}},
    {"get_line_yrange",{P,I,I}},
    {"get_line_extents",{P,P,P}},
    {"get_layout_extents",{P,P,P}},
"PangoLayoutIter"}

widget[PangoLayoutRun] = {"pango_layout_run",
{0},
"PangoLayoutRun"}

widget[PangoTabArray] = {"pango_tab_array",
{0},
    {"new",{I,B},P},
    {"get_size",{P},I},
    {"resize",{P,I}},
    {"set_tab",{P,I,I,I}},
    {"get_tab",{P,I,P,P}},
    {"get_tabs",{P,P,P}},
    {"get_position_in_pixels",{P},B},
"PangoTabArray"}

widget[PangoLanguage] = {"pango_language",
{GObject},
    {"new",{S},-routine_id("newPangoLanguage")},
    {"get_default",{P},-routine_id("getDefaultLanguage")},
    {"get_sample_string",{P},-routine_id("getSampleStr")},
    {"to_string",{P},S},
    {"matches",{P,S},B},
    {"includes_script",{P,P},B},
"PangoLanguage"}

    function newPangoLanguage(object s)
    return gtk_func("pango_language_from_string",{S},{s})
    end function

    function getDefaultLanguage(object junk)
    return gtk_str_func("pango_language_get_default")
    end function

    function getSampleStr(object x)
    return gtk_str_func("pango_language_get_sample_string",{P},{x})
    end function
 
widget[PangoAttr] = {"pango_attr",
{0},
    {"new",{P,P},-routine_id("newPangoAttr")},
"PangoAttr"}

    function newPangoAttr(sequence x, object z)
    x = sprintf("pango_attr_%s_new",{x})
    object a = gtk_func(x,{P},{z})
    register(a,PangoAttr)
    return a
    end function

export enum by * 2
    PANGO_STRETCH_ULTRA_CONDENSED,
    PANGO_STRETCH_EXTRA_CONDENSED,
    PANGO_STRETCH_CONDENSED,
    PANGO_STRETCH_SEMI_CONDENSED,
    PANGO_STRETCH_NORMAL,
    PANGO_STRETCH_SEMI_EXPANDED,
    PANGO_STRETCH_EXPANDED = 64,
    PANGO_STRETCH_EXTRA_EXPANDED,
    PANGO_STRETCH_ULTRA_EXPANDED
    
export enum by * 2
    PANGO_FONT_MASK_FAMILY,
    PANGO_FONT_MASK_STYLE,
    PANGO_FONT_MASK_VARIANT,
    PANGO_FONT_MASK_WEIGHT,
    PANGO_FONT_MASK_STRETCH,
    PANGO_FONT_MASK_SIZE,
    PANGO_FONT_MASK_GRAVITY

export enum
  CAIRO_EXTEND_REPEAT = 1,
  
  CAIRO_FILL_RULE_EVEN_ODD = 1,
  CAIRO_FILL_RULE_WINDING = 0,
  
  CAIRO_FONT_SLANT_NORMAL = 0,
  CAIRO_FONT_SLANT_ITALIC,
  CAIRO_FONT_SLANT_OBLIQUE,
  
  CAIRO_FONT_WEIGHT_NORMAL = 0, NORMAL = 0,
  CAIRO_FONT_WEIGHT_BOLD,   BOLD = 1,
  
  CAIRO_FORMAT_INVALID = -1,
  CAIRO_FORMAT_ARGB32 = 0,
  CAIRO_FORMAT_RGB24,
  CAIRO_FORMAT_A8,
  CAIRO_FORMAT_A1,
  CAIRO_FORMAT_RGB16_565,
  
  CAIRO_LINE_CAP_BUTT = 0,
  CAIRO_LINE_CAP_ROUND,
  CAIRO_LINE_CAP_SQUARE,
  
  CAIRO_LINE_JOIN_MITER = 0,
  CAIRO_LINE_JOIN_ROUND,
  CAIRO_LINE_JOIN_BEVEL,
  
  CAIRO_OPERATOR_CLEAR = 0,
  CAIRO_OPERATOR_SOURCE,
  CAIRO_OPERATOR_OVER,
  CAIRO_OPERATOR_IN,
  CAIRO_OPERATOR_OUT,
  CAIRO_OPERATOR_ATOP,
  CAIRO_OPERATOR_DEST,
  CAIRO_OPERATOR_DEST_OVER,
  CAIRO_OPERATOR_DEST_IN,
  CAIRO_OPERATOR_DEST_OUT,
  CAIRO_OPERATOR_DEST_ATOP,
  CAIRO_OPERATOR_XOR,
  CAIRO_OPERATOR_ADD,
  CAIRO_OPERATOR_SATURATE,
  CAIRO_OPERATOR_MULTIPLY,
  CAIRO_OPERATOR_SCREEN,
  CAIRO_OPERATOR_OVERLAY,
  CAIRO_OPERATOR_DARKEN,
  CAIRO_OPERATOR_LIGHTEN,
  CAIRO_OPERATOR_COLOR_DODGE,
  CAIRO_OPERATOR_COLOR_BURN,
  CAIRO_OPERATOR_HARD_LIGHT,
  CAIRO_OPERATOR_SOFT_LIGHT,
  CAIRO_OPERATOR_DIFFERENCE,
  CAIRO_OPERATOR_EXCLUSION,
  CAIRO_OPERATOR_HSL_HUE,
  CAIRO_OPERATOR_HSL_SATURATION,
  CAIRO_OPERATOR_HSL_COLOR,
  CAIRO_OPERATOR_HSL_LUMINOSITY,
  
  CAIRO_PDF_VERSION_1_4 = 0,
  CAIRO_PDF_VERSION_1_5,
  
  CAIRO_SVG_VERSION_1_1 = 0,
  CAIRO_SVG_VERSION_1_2,
  
  CAIRO_SURFACE_TYPE_IMAGE = 0,
  CAIRO_SURFACE_TYPE_PDF,
  CAIRO_SURFACE_TYPE_PS,
  CAIRO_SURFACE_TYPE_XLIB,
  CAIRO_SURFACE_TYPE_XCB,
  CAIRO_SURFACE_TYPE_GLITZ,
  CAIRO_SURFACE_TYPE_QUARTZ,
  CAIRO_SURFACE_TYPE_WIN32,
  CAIRO_SURFACE_TYPE_BEOS,
  CAIRO_SURFACE_TYPE_DIRECTFB,
  CAIRO_SURFACE_TYPE_SVG,
  CAIRO_SURFACE_TYPE_OS2,
  CAIRO_SURFACE_TYPE_WIN32_PRINTING,
  CAIRO_SURFACE_TYPE_QUARTZ_IMAGE,
  CAIRO_SURFACE_TYPE_SCRIPT,
  CAIRO_SURFACE_TYPE_QT,
  CAIRO_SURFACE_TYPE_RECORDING,
  CAIRO_SURFACE_TYPE_VG,
  CAIRO_SURFACE_TYPE_GL,
  CAIRO_SURFACE_TYPE_DRM,
  CAIRO_SURFACE_TYPE_TEE,
  CAIRO_SURFACE_TYPE_XML,
  CAIRO_SURFACE_TYPE_SKIA,
  CAIRO_SURFACE_TYPE_SUBSURFACE,
  
  CAIRO_FONT_TYPE_TOY = 0,
  CAIRO_FONT_TYPE_FT,
  CAIRO_FONT_TYPE_WIN32,
  CAIRO_FONT_TYPE_QUARTZ,
  CAIRO_FONT_TYPE_USER

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------

