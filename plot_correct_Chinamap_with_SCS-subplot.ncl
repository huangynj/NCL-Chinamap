;***********************************************************;
;                                                           ;
;  This script is a example to plot contours on China map.  ;
;  Written by Huang Yongjie(IAP/CAS), 2016-05-22.           ;
;                                                           ;
;***********************************************************;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  f=addfile("pres.mon.ltm.nc","r")
  pres= f->pres(0,:,:) 

;---------------------------------------------------------------
  wks = gsn_open_wks("x11","Correct_China_boundary") 
  gsn_define_colormap( wks ,"gui_default")  
  
  res                            = True            
  res@gsnMaximize                = True
  res@gsnDraw                    = False
  res@gsnFrame                   = False

;---------------------------------------------------------------
; set for the map 
  res@mpMinLatF                  = 17.
  res@mpMaxLatF                  = 55.
  res@mpMinLonF                  = 72.
  res@mpMaxLonF                  = 136.
   
  res@mpFillOn                   = True
  res@mpDataSetName              = "./database/Earth..4"
  res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
  res@mpAreaMaskingOn            = True
  res@mpMaskAreaSpecifiers       = (/"China"/)
  res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    
  res@mpLandFillColor            = "white"
  res@mpInlandWaterFillColor     = "white"
  res@mpOceanFillColor           = "white"
  res@mpFillBoundarySets         = "NoBoundaries"
  res@mpOutlineBoundarySets      = "NoBoundaries"
  res@mpNationalLineColor        = "black"
  res@mpProvincialLineColor      = "black"
  res@mpGeophysicalLineColor     = "black"
  res@mpNationalLineThicknessF   = 2
  res@mpProvincialLineThicknessF = 1

;---------------------------------------------------------------
; set for the plot

  res@cnFillOn                   = True
  res@cnFillDrawOrder            = "PreDraw"
  res@cnLinesOn                  = False             
  res@cnLevelSpacingF            = 20.             
  res@gsnSpreadColors            = True   
  res@lbLabelAutoStride          = True
  res@pmTickMarkDisplayMode      = "Always"
  res@gsnRightString             = "hPa"

  res@gsnLeftString              = "Surface pressure over part China Map with SCS"
  map = gsn_csm_contour_map(wks,pres,res) 

;--- add South China Sea --- 
  nhres                          = res
  nhres@gsnMaximize              = False

  nhres@vpHeightF                = 0.18    
  nhres@vpWidthF                 = 0.18
    
  nhres@mpMinLatF                =   2.0    
  nhres@mpMaxLatF                =  23.0
  nhres@mpMinLonF                = 105.0
  nhres@mpMaxLonF                = 123.0

  nhres@lbLabelBarOn             = False
  nhres@tmXBOn                   = False 
  nhres@tmXTOn                   = False
  nhres@tmYLOn                   = False
  nhres@tmYROn                   = False
  nhres@gsnLeftString            = ""
  nhres@gsnRightString           = ""

  map_nanhai = gsn_csm_contour_map(wks,pres,nhres)

  adres                          = True
  adres@amParallelPosF           = 0.495 ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF         = 0.49  ; -0.5 is the top edge of the plot.
  adres@amJust                   = "BottomRight"

  plotnh = gsn_add_annotation(map,map_nanhai,adres)

;--- add Changjiang and Huanghe river --- 
  river                          = True
  river@gsLineThicknessF         = 2.0       
  river@gsLineColor              = "blue"
  plotrv = gsn_add_shapefile_polylines(wks,map,"./cnmap_NetCDF/rivers.nc",river)
 ;plotrv = gsn_add_shapefile_polylines(wks,map,"./cnmap/rivers.shp",river)

  draw(map)
  frame(wks)

;--- add City --- 
  city                           = True
  city@gsLineThicknessF          = 1.0       
  city@gsLineColor               = "grey"
  plotct = gsn_add_shapefile_polylines(wks,map,"./cnmap_NetCDF/diquJie_polyline.nc",city)

  draw(map)
  frame(wks)

end  
