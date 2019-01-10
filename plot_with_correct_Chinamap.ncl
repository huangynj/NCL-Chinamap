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
  res@mpMinLatF                  = 0.                         
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
  res@cnLineLabelsOn             = False
  res@cnLevelSelectionMode       = "ExplicitLevels"
  res@cnLevels                   = ispan(520,1080,20)
  res@cnFillPalette              = "gui_default"
  res@lbLabelAutoStride          = True
  res@pmTickMarkDisplayMode      = "Always"
  res@gsnRightString             = "hPa"

;---------------------------------------------------------------
; plot the full China map
  res@gsnLeftString              = "Surface pressure over full China Map"
  map = gsn_csm_contour_map(wks,pres,res) 
  draw(map)
  frame(wks)

;---------------------------------------------------------------
; plot one part of China map with South China Sea subplot
  res@mpMinLatF                  = 17.
  res@gsnLeftString              = "Surface pressure over part China Map with SCS"
  map1 = gsn_csm_contour_map(wks,pres,res) 

;--- add South China Sea --- 
  nhres                          = True
  nhres@gsnFrame                 = False
  nhres@gsnDraw                  = False
      
  nhres@vpHeightF                = 0.18    
  nhres@vpWidthF                 = 0.18
    
  nhres@mpMinLatF                =   2.0    
  nhres@mpMaxLatF                =  23.0
  nhres@mpMinLonF                = 105.0
  nhres@mpMaxLonF                = 123.0

  getvalues map1
    "mpDataSetName"              : nhres@mpDataSetName
    "mpDataBaseVersion"          : nhres@mpDataBaseVersion
    "mpFillOn"                   : nhres@mpFillOn
    "mpFillDrawOrder"            : nhres@mpFillDrawOrder
    "mpAreaMaskingOn"            : nhres@mpAreaMaskingOn
    "mpMaskAreaSpecifiers"       : nhres@mpMaskAreaSpecifiers 
    "mpOutlineSpecifiers"        : nhres@mpOutlineSpecifiers
    "mpOutlineBoundarySets"      : nhres@mpOutlineBoundarySets
    "mpLandFillColor"            : nhres@mpLandFillColor       
    "mpOceanFillColor"           : nhres@mpOceanFillColor      
    "mpInlandWaterFillColor"     : nhres@mpInlandWaterFillColor
    "mpNationalLineColor"        : nhres@mpNationalLineColor   
    "mpProvincialLineColor"      : nhres@mpProvincialLineColor 
  end getvalues

  getvalues map1@contour
    "cnFillOn"                   : nhres@cnFillOn
    "cnLevelSelectionMode"       : nhres@cnLevelSelectionMode
    "cnLevels"                   : nhres@cnLevels
    "cnFillColors"               : nhres@cnFillColors
    "cnFillDrawOrder"            : nhres@cnFillDrawOrder
    "cnLinesOn"                  : nhres@cnLinesOn
    "cnLineLabelsOn"             : nhres@cnLineLabelsOn
  end getvalues

  nhres@lbLabelBarOn             = False
  nhres@tmXBOn                   = False 
  nhres@tmYLOn                   = False
  nhres@tmYROn                   = False
  nhres@tmXTOn                   = False
  nhres@gsnLeftString            = ""
  nhres@gsnRightString           = ""

  map_nanhai = gsn_csm_contour_map(wks,pres,nhres)

  adres                          = True
  adres@amParallelPosF           = 0.495 ; -0.5 is the left edge of the plot.
  adres@amOrthogonalPosF         = 0.49  ; -0.5 is the top edge of the plot.
  adres@amJust                   = "BottomRight"

  plotnh = gsn_add_annotation(map1,map_nanhai,adres)
  draw(map1)
  frame(wks)

;---------------------------------------------------------------
; Mask Xinjiang plot
  res@mpMaskAreaSpecifiers       = "Xinjiang Uygur"
  res@gsnLeftString              = "Surface pressure in Xinjiang with NCL Mask"
  map2 = gsn_csm_contour_map(wks,pres,res) 

;---------------------------------------------------------------
; Mask Xizang plot
  res@mpMaskAreaSpecifiers       = "Xizang"
  res@gsnLeftString              = "Surface pressure in Xizang with NCL Mask"
  map3 = gsn_csm_contour_map(wks,pres,res) 

;---------------------------------------------------------------
; Mask Beijing plot
  res@mpOutlineSpecifiers       := "Beijing Shi"
  res@mpMaskAreaSpecifiers       = "Beijing Shi"
  res@mpMinLatF                  = 39.4
  res@mpMaxLatF                  = 41.15
  res@mpMinLonF                  = 115.25
  res@mpMaxLonF                  = 117.6
  res@mpShapeMode                = "FreeAspect"
  res@gsnLeftString              = "Surface pressure in Beijing with NCL Mask and shp boundaries"
  res@gsnRightString             = ""
  map4 = gsn_csm_contour_map(wks,pres,res) 

;--- add shp file boundaries ---
  ShpDir = "./cnmap/" ;"$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/"
  cnres                       = True
  cnres@gsLineThicknessF      = 2.0
  cnres@gsLineColor           = "red"

  getvalues map4
    "mpMinLatF" : cnres@minlat
    "mpMaxLatF" : cnres@maxlat
    "mpMinLonF" : cnres@minlon
    "mpMaxLonF" : cnres@maxlon
  end getvalues

  plotshp = gsn_add_shapefile_polylines(wks,map4,ShpDir+"cnhimap.shp",cnres)

;---------------------------------------------------------------

  gsn_panel(wks,(/map1,map2,map3,map4/),(/2,2/),True)

end  
