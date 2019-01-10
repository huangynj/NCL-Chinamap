;***********************************************************************;
; Function : gsn_add_shapefile_polylines                                ;
;                   wks: workstation object                             ;
;                plotid: plot object                                    ;
;                 fname: Name of shapefile ("xxxx.shp")                 ;
;               resources: optional resources                           ;
;                                                                       ;
; This function attaches shapefile polylines to the plot "plotid".      ;
;                                                                       ;
; In version 6.1.0, some code was added to add checks if the lat/lon    ;
; segments are within the range of the map. This works best for a C.E.  ;
; map. You have to set the special min/max/lat/lon attributes for this  ;
; to work.  I won't advertise this yet, because the interface could     ;
; probably be made better.                                              ;
;***********************************************************************;
undef("gsn_add_shapefile_polylines")
function gsn_add_shapefile_polylines(wks,plot,fname:string,lnres)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, npoly, npl
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: gsn_add_shapefile_polylines: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---We can't use this routine to plot point data
  if(.not.any(f@geometry_type.eq.(/"polygon","polyline"/))) then
    print("Error: gsn_add_shapefile_polylines: geometry_type attribute must be 'polygon' or 'polyline'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Create array to hold all polylines
  npoly = sum(geometry(:,geom_numSegs)) 
  poly  = new(npoly,graphic,"No_FillValue")   ; change by Huang Yongjie - 2012-12-19
 ; poly  = new(npoly,graphic)

;---Section to attach polylines to plot.
  lon = f->x
  lat = f->y
  npl = 0     ; polyline counter
;
; Special check for minlat/maxlat/minlon/maxlon attributes.
;
; If set, then each lat/lon segment will be checked if it's
; in the range.  This can speed up plotting, but I need to
; verify this!
; 
  if(isatt(lnres,"minlon").and.isatt(lnres,"maxlon").and.\
     isatt(lnres,"minlat").and.isatt(lnres,"maxlat")) then
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          lat_sub = lat(startPT:endPT)
          lon_sub = lon(startPT:endPT) 
          if(.not.(all(lon_sub.lt.lnres@minlon).or. \
                   all(lon_sub.gt.lnres@maxlon).or. \
                   all(lat_sub.lt.lnres@minlat).or. \
                   all(lat_sub.gt.lnres@maxlat))) then
            poly(npl) = gsn_add_polyline(wks, plot, lon_sub, lat_sub, lnres)
            npl = npl + 1
          end if
          delete([/lat_sub,lon_sub/])
       end do
    end do
  else       ; Don't do any range checking. 
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          poly(npl) = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                       lat(startPT:endPT), lnres)
          npl = npl + 1
       end do
    end do
  end if
  return(poly(0:npl-1))
end

;***********************************************************************;
; Function : gsn_add_shapefile_polygons                                 ;
;                   wks: workstation object                             ;
;                plotid: plot object                                    ;
;                 fname: Name of shapefile ("xxxx.shp")                 ;
;               resources: optional resources                           ;
;                                                                       ;
; This function attaches shapefile polygons to the plot "plotid".       ;
;                                                                       ;
; In version 6.1.0, some code was added to add checks if the lat/lon    ;
; segments are within the range of the map. This works best for a C.E.  ;
; map. You have to set the special min/max/lat/lon attributes for this  ;
; to work.  I won't advertise this yet, because the interface could     ;
; probably be made better.                                              ;
;***********************************************************************;
undef("gsn_add_shapefile_polygons")
function gsn_add_shapefile_polygons(wks,plot,fname:string,gnres)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, npoly, npl
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: gsn_add_shapefile_polygons: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---We can't use this routine to plot point data
  if(f@geometry_type.ne."polygon") then
    print("Error: gsn_add_shapefile_polygon: geometry_type attribute must be 'polygon'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---Get the number of colors
  if(.not.gnres.or..not.isatt(gnres,"gsFillColor")) then
    set_fill_color = True
    getvalues wks
      "wkColorMapLen"  : cmap_len
    end getvalues
  else
    set_fill_color = False
  end if

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Create array to hold all polylines
  npoly = sum(geometry(:,geom_numSegs)) 
  poly  = new(npoly,graphic)

;---Section to attach polygons to plot.
  lon = f->x
  lat = f->y
  npl = 0     ; polyline counter
;
; Special check for minlat/maxlat/minlon/maxlon attributes.
;
; If set, then each lat/lon segment will be checked if it's
; in the range.  This can speed up plotting, but I need to
; verify this!
; 
  if(isatt(gnres,"minlon").and.isatt(gnres,"maxlon").and.\
     isatt(gnres,"minlat").and.isatt(gnres,"maxlat")) then
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          lat_sub = lat(startPT:endPT)
          lon_sub = lon(startPT:endPT) 
          if(set_fill_color) then
;---Pick a random color 
            gnres@gsFillColor = toint(random_uniform(2,cmap_len-2,1))
          end if
          if(.not.(all(lon_sub.lt.gnres@minlon).or. \
                   all(lon_sub.gt.gnres@maxlon).or. \
                   all(lat_sub.lt.gnres@minlat).or. \
                   all(lat_sub.gt.gnres@maxlat))) then
;---Attach the line segment
            poly(npl) = gsn_add_polygon(wks, plot, lon_sub, lat_sub, gnres)
            npl = npl + 1
          end if
          delete([/lat_sub,lon_sub/])
       end do
    end do
  else
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          if(set_fill_color) then
;---Pick a random color 
            gnres@gsFillColor = toint(random_uniform(2,cmap_len-2,1))
          end if
;---Attach the line segment
          poly(npl) = gsn_add_polygon(wks, plot, lon(startPT:endPT),  \
                                      lat(startPT:endPT), gnres)
          npl = npl + 1
       end do
    end do
  end if
  return(poly)
end

;***********************************************************************;
; Function : gsn_add_shapefile_polymarkers                              ;
;                   wks: workstation object                             ;
;                plotid: plot object                                    ;
;                 fname: Name of shapefile ("xxxx.shp")                 ;
;               resources: optional resources                           ;
;                                                                       ;
; This function attaches shapefile point data to the plot "plotid".     ;
;                                                                       ;
; In version 6.1.0, some code was added to add checks if the lat/lon    ;
; segments are within the range of the map. This works best for a C.E.  ;
; map. You have to set the special min/max/lat/lon attributes for this  ;
; to work.  I won't advertise this yet, because the interface could     ;
; probably be made better.                                              ;
;***********************************************************************;
undef("gsn_add_shapefile_polymarkers")
function gsn_add_shapefile_polymarkers(wks,plot,fname:string,mkres)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, npoly, npl
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: gsn_add_shapefile_polymarkers: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---We can't use this routine to plot point data
  if(f@geometry_type.ne."point") then
    print("Error: gsn_add_shapefile_polymarkers: geometry_type attribute must be 'point'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Create array to hold all polymarkers
  npoly = sum(geometry(:,geom_numSegs)) 
  poly  = new(npoly,graphic)

;---Section to attach polymarkers to plot.
  lon = f->x
  lat = f->y
  npl = 0     ; polyline counter
;
; Special check for minlat/maxlat/minlon/maxlon attributes.
;
; If set, then each lat/lon segment will be checked if it's
; in the range.  This can speed up plotting, but I need to
; verify this!
; 
  if(isatt(mkres,"minlon").and.isatt(mkres,"maxlon").and.\
     isatt(mkres,"minlat").and.isatt(mkres,"maxlat")) then
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          lat_sub = lat(startPT:endPT)
          lon_sub = lon(startPT:endPT) 
          if(.not.(all(lon_sub.lt.mkres@minlon).or. \
                   all(lon_sub.gt.mkres@maxlon).or. \
                   all(lat_sub.lt.mkres@minlat).or. \
                   all(lat_sub.gt.mkres@maxlat))) then
;---Attach the markers
            poly(npl) = gsn_add_polymarker(wks, plot, lon_sub, lat_sub, mkres)
            npl = npl + 1
           end if
           delete([/lat_sub,lon_sub/])
         end do
    end do
  else       ; Don't do any range checking. 
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
;---Attach the markers
          poly(npl) = gsn_add_polymarker(wks, plot, lon(startPT:endPT),  \
                                         lat(startPT:endPT), mkres)
          npl = npl + 1
       end do
    end do
  end if
  return(poly(0:npl-1))
end

;***********************************************************************;
; Function : gsn_add_shapefile_text                                     ;
;                   wks: workstation object                             ;
;                plotid: plot object                                    ;
;                 fname: Name of shapefile ("xxxx.shp")                 ;
;                 vname: Name of string variable containing text strings;
;               resources: optional resources                           ;
;                                                                       ;
; This function attaches shapefile text strings to the plot "plotid".   ;
; The assumption is that there are "num_features" text strings, and this;
; routine gets the approximate mid lat/lon area for each text string.   ;
;***********************************************************************;
undef("gsn_add_shapefile_text")
function gsn_add_shapefile_text(wks,plot,fname[1]:string,vname[1]:string,txres)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, ntxt, \
minlat, maxlat, minlon, maxlon
begin
;---Open the shapefile
  f = addfile(fname,"r")
  if(.not.isfilevar(f,vname))
    print("Error: gsn_add_shapefile_text: '" + vname + "' is not a variable")
    print("       in file '" + fname + "'.")
    return(new(1,graphic))
  end if
;---Error checking
  if(ismissing(f)) then
    print("Error: gsn_add_shapefile_text: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Create array to hold all text
  text  = new(numFeatures,graphic)

;---Section to attach text to plot.
  lon = f->x
  lat = f->y
  ntxt = 0     ; text counter
;
; Special check for minlat/maxlat/minlon/maxlon attributes.
;
; If set, then each lat/lon segment will be checked if it's
; in the range.  This can speed up plotting, but I need to
; verify this!
;
  if(isatt(txres,"minlon").and.isatt(txres,"maxlon").and.\
     isatt(txres,"minlat").and.isatt(txres,"maxlat")) then
    do i=0, numFeatures-1
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       minlat = new(1,typeof(lat))
       maxlat = new(1,typeof(lat))
       minlon = new(1,typeof(lon))
       maxlon = new(1,typeof(lon))
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          lat_sub = lat(startPT:endPT)
          lon_sub = lon(startPT:endPT)
          if(.not.(all(lon_sub.lt.txres@minlon).or. \
                   all(lon_sub.gt.txres@maxlon).or. \
                   all(lat_sub.lt.txres@minlat).or. \
                   all(lat_sub.gt.txres@maxlat))) then
            if(any((/ismissing(minlat),ismissing(maxlat), \
                     ismissing(minlon),ismissing(maxlon)/))) then
              minlat = min(lat_sub)
              maxlat = max(lat_sub)
              minlon = min(lon_sub)
              maxlon = max(lon_sub)
            else
              minlat = min((/minlat,min(lat_sub)/))
              maxlat = max((/maxlat,max(lat_sub)/))
              minlon = min((/minlon,min(lon_sub)/))
              maxlon = max((/maxlon,max(lon_sub)/))
            end if
          end if
          delete([/lat_sub,lon_sub/])
       end do
;---Attach the text string
       if(.not.any((/ismissing(minlat),ismissing(maxlat), \
                     ismissing(minlon),ismissing(maxlon)/))) then
         avglat = (minlat+maxlat)/2.
         avglon = (minlon+maxlon)/2.
         print("Text = '" + f->$vname$(i) + "'")
         print("Location = " + avglat + "/" + avglon)
         text(ntxt) = gsn_add_text(wks, plot,f->$vname$(i),avglon,avglat,txres)
         ntxt = ntxt + 1
       end if
    end do
  else
    do i=0, numFeatures-1  
       startSegment = geometry(i, geom_segIndex)
       numSegments  = geometry(i, geom_numSegs)
       minlat = new(1,typeof(lat))
       maxlat = new(1,typeof(lat))
       minlon = new(1,typeof(lon))
       maxlon = new(1,typeof(lon))
       do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          if(any((/ismissing(minlat),ismissing(maxlat), \
                   ismissing(minlon),ismissing(maxlon)/))) then
            minlat = min(lat(startPT:endPT))
            maxlat = max(lat(startPT:endPT))
            minlon = min(lon(startPT:endPT))
            maxlon = max(lon(startPT:endPT))
          else
            minlat = min((/minlat,min(lat(startPT:endPT))/))
            maxlat = max((/maxlat,max(lat(startPT:endPT))/))
            minlon = min((/minlon,min(lon(startPT:endPT))/))
            maxlon = max((/maxlon,max(lon(startPT:endPT))/))
          end if
       end do
;---Attach the text string
       if(.not.any((/ismissing(minlat),ismissing(maxlat), \
                     ismissing(minlon),ismissing(maxlon)/))) then
         avglat = (minlat+maxlat)/2.
         avglon = (minlon+maxlon)/2.
         text(ntxt) = gsn_add_text(wks,plot,f->$vname$(i),avglon,avglat,txres)
         ntxt = ntxt + 1
       end if
    end do
  end if
  return(text)
end

