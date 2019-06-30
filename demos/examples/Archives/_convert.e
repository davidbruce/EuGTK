--
-- Measurement Conversion function (second update) 
-- (c2001) Jim Roberts 
 
export sequence Unit -- made exportable for use with convert.ex GUI - Irv
 integer l 
 
  Unit = { 
 
-- Length 
   {"m",1,"cm",100,"mm",1e3,"um",1e6,"km",1e-3,"in",1/.0254,"ft",1/.3048, 
    "yd",1/.9144,"mi",1/1609.344,"fl",4.973e-3,"lg",2.071237307e-4, 
    "au",6.684587154e-12,"ly",1.056980777e-16,"ps",3.24254e-17,"nmi",1/1852}, 
 
-- Time 
   {"s",1,"min",1/60,"hr",1/3600,"dy",1/86400,"wk",1/604800,"yr",1/31557600}, 
 
-- Velocity 
   {"m/s",1,"cm/s",100,"mm/s",1e3,"km/s",1e-3,"in/s",1/.0254,"ft/s",1/.3048, 
    "mi/s",1/1609.344,"km/hr",3.6,"mi/hr",1/.44704,"kn",3.6/1.852}, 
 
-- Angles 
   {"rad",1,"deg",57.29577951,"arcs",2.062648063e5,"arcmin",3437.746771, 
    "gra",63.66197724}, 
 
-- Angular velocity 
   {"rad/s",1,"deg/s",57.29577951,"deg/min",3437.746771,"rev/s",.1591549431, 
    "rev/min",9.549296586,"rev/hr",572.9577952}, 
 
-- Area 
   {"m2",1,"cm2",1e4,"mm2",1e6,"km2",1e-6,"in2",1550.0031,"ft2",10.76390841, 
    "yd2",1.195990046,"mi2",3.861021585e-7,"acr",2.471053354e-04,"ha",.0001}, 
 
-- Volume 
   {"m3",1,"cm3",1e6,"ft3",35.31466672,"in3",61023.74409,"yd3",1.307950618, 
    "gal",264.1721,"lt",1e3,"pt",2113.3768,"qt",1056.6884,"mm3",1e9}, 
 
-- Weight 
   {"kg",1,"g",1000,"lbs",2.205,"tn",1.1025e-3,"oz",35.28,"mtn",1e-3}, 
 
-- Pressure 
   {"Pa",1,"N/m2",1,"bar",1e-5,"mbar",1e-2,"N/cm2",1e-4,"dn/cm2",10, 
    "g/cm2",1/98.0665,"kg/cm2",1/98066.5,"atm",1/101325,"lbs/in2",1/6894.8, 
    "lbs/ft2",1/47.88055555,"kg/m2",1/9.80665}, 
 
-- Energy 
   {"j",1, "kj", 1000,"mj", 1000000, "erg",1e7,"btu",9.48e-04,"ft*lbs",.7376, 
   "w*hr",2.778e-4,"kw*hr",2.778e-7, "kcal", 0.000239006} 
 
   } 
 
  l = length(Unit) 
 
global function convert_unit(atom val, sequence from, sequence To ) 
 
    integer f, t, i1, i2 
 
    f = 0 
    t = 0 
 
    for a = 1 to l do                 -- indexes from and To units 
	if not f then f = find(from, Unit[a])  i1=a  end if 
	if not t then t = find(  To, Unit[a])  i2=a  end if 
    end for 
 
    if not f or not t then 
	return {not f, not t, 0}      -- Error for unsupported units 
    end if 
 
    if i1 != i2  then 
	return {-1, -1, 0}            -- Error for mis-matched units 
    end if 
 
    val /= Unit[i1][f+1]              -- converts val to base unit 
    val *= Unit[i1][t+1]              -- converts val to To unit 
 
    return {0, 0, val}                -- return no error and converted value 
 
end function 

 
