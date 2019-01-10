load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/shp_Function.ncl"
;***********************************************************************;
;  Function : add_china_map                                             ;
;   This function attaches the China map(eg. map of China, Yangtze      ;
;   River and Yellow River, provinces, southsea,cities and counties)    ;
;   to the plot.                                                        ;
;                                                                       ;
;  Prototype                                                            ;
;   load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"             ;
;        function add_china_map(wks,plot,res)                           ; 
;                 wks: workstation object                               ;
;                plot: plot object                                      ;
;                 res: optional resources                               ;
;                                                                       ;
;  Program history                                                      ;
;    2012-12-19 - Written by Liu Pei(CUIT) and Huang Yongjie(IAP/CAS).  ;
;                                                                       ;
;***********************************************************************;
undef("add_china_map")
function add_china_map(wks,plot,CNres)

begin 

ShpDir = "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/"

if (CNres@china) then
 cnres      = True      
 cnres@gsLineThicknessF = 2.0       
 cnres@gsLineColor = "black"
 plotcn1 = gsn_add_shapefile_polylines(wks,plot,ShpDir+"cnmap.shp",cnres)
else 
 plotcn1 = new(1,graphic,"No_FillValue")
end if

if (CNres@river) then
  river     = True
  river@gsLineThicknessF = 2.0       
  river@gsLineColor = "blue"
  plotcn2 = gsn_add_shapefile_polylines(wks,plot,ShpDir+"river.shp",river)
else 
 plotcn2 = new(1,graphic,"No_FillValue")
end if

if (CNres@province) then
  prres=True
  prres@gsLineThicknessF = 2.0       
  prres@gsLineColor = "black"
  plotcn3 = gsn_add_shapefile_polylines(wks,plot,ShpDir+"cnhimap.shp",prres)
else 
 plotcn3 = new(1,graphic,"No_FillValue")
end if

if (CNres@diqu) then
  dqres=True
  dqres@gsLineThicknessF = 0.5       
  dqres@gsLineColor = "black"
  plotcn4 = gsn_add_shapefile_polylines(wks,plot,ShpDir+"diquJie_polyline.shp",dqres)
else 
 plotcn4 = new(1,graphic,"No_FillValue")
end if


if (CNres@nanhai) then
  nhres                       = True
  nhres@gsnFrame              = False
  nhres@gsnDraw               = False
  nhres@pmTickMarkDisplayMode = "Always"
  ;nhres@tmXBLabelFontHeightF  = 0.01 
  ;nhres@mpDataBaseVersion  ="MediumRes"
  nhres@mpOutlineOn       = True

  nhres@mpMinLatF         =   2.0    
  nhres@mpMaxLatF         =  23.0
  nhres@mpMinLonF         = 105.0
  nhres@mpMaxLonF         = 123.0

  nhres@vpHeightF         = 0.18    
  nhres@vpWidthF          = 0.18

  nhres@mpOutlineBoundarySets = "National"   
  nhres@mpLandFillColor         = "White"
  nhres@mpOceanFillColor        = "White"
  nhres@mpInlandWaterFillColor  = "White"

  nhres@tmXBOn = False 
  nhres@tmYLOn  = False 

  map_nanhai = gsn_csm_map(wks,nhres)

  cnres                  = True      
  cnres@gsLineThicknessF = 2.0       
  cnres@gsLineColor      = "black"

  cnres@minlon           = 105.0
  cnres@maxlon           = 123.0
  cnres@minlat           = 2.0
  cnres@maxlat           = 23.0
  plotcn5 = gsn_add_shapefile_polylines(wks,map_nanhai,ShpDir+"cnmap.shp",cnres)

  adres                  = True
  adres@amParallelPosF   = 0.495    ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF = 0.49   ; -0.5 is the top edge of the plot.
  adres@amJust           = "BottomRight" 

 plotnh = gsn_add_annotation(plot,map_nanhai,adres)
else 
 plotcn5 = new(1,graphic,"No_FillValue")
end if

pp1 = array_append_record (plotcn1,plotcn2,0)
pp2 = array_append_record (pp1,plotcn3,0)
pp3 = array_append_record (pp2,plotcn4,0)
pp4 = array_append_record (pp3,plotcn5,0)

return(pp4)
end
