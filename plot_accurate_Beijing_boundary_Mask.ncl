;***********************************************************;
;                                                           ;
;  This script is a example to plot contours in Beijing.    ;
;  Written by Huang Yongjie(IAP/CAS), 2016-05-27.           ;
;                                                           ;
;***********************************************************;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  f=addfile("pres.mon.ltm.nc","r")
  pres= f->pres(0,:,:) 

;---------------------------------------------------------------
  wks = gsn_open_wks("x11","accurate_Beijing_boundary_Mask") 
  gsn_define_colormap( wks ,"gui_default")  
  
  res                            = True            
  res@gsnMaximize                = True
  res@gsnDraw                    = False
  res@gsnFrame                   = False

;---------------------------------------------------------------
; Mask Beijing plot

; set for the map 
  res@mpMinLatF                  = 39.4
  res@mpMaxLatF                  = 41.15
  res@mpMinLonF                  = 115.25
  res@mpMaxLonF                  = 117.6
   
  res@mpFillOn                   = True
  res@mpDataSetName              = "./database/Earth..4"
  res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"

  res@mpAreaMaskingOn            = True
  res@mpOutlineSpecifiers        = "Beijing Shi"
  res@mpMaskAreaSpecifiers       = "Beijing Shi"
    
  res@mpLandFillColor            = "white"
  res@mpProvincialLineColor      = "red"
  res@mpProvincialLineThicknessF = 2.

  res@mpShapeMode                = "FreeAspect"
  res@mpFillDrawOrder            = "PostDraw"

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
  res@gsnLeftString              = "Surface pressure in Beijing with NCL Mask"

  map4 = gsn_csm_contour_map(wks,pres,res) 

;--- add shp file boundaries to test whether the border overlap---
  ShpDir = "./cnmap/" ;"$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/"
  cnres                       = True
  cnres@gsLineThicknessF      = 1.5
  cnres@gsLineColor           = "blue"

  getvalues map4
    "mpMinLatF" : cnres@minlat
    "mpMaxLatF" : cnres@maxlat
    "mpMinLonF" : cnres@minlon
    "mpMaxLonF" : cnres@maxlon
  end getvalues

  plotshp = gsn_add_shapefile_polylines(wks,map4,ShpDir+"county_2004.shp",cnres)

;---------------------------------------------------------------
  draw(map4)
  frame(wks)

end  
