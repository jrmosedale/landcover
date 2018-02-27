# Using WMS tiles within Leaflet

# Test 
leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 4) %>%  addWMSTiles(
  "http://sedac.ciesin.columbia.edu/geoserver/wms",
  layers = "energy:energy-pop-exposure-nuclear-plants-locations_plants",
  options = WMSTileOptions(format = "image/png", transparent = TRUE),
  tileOptions(tms = TRUE),
  attribution = "")

# Flood warning areas
leaflet() %>% addTiles() %>% setView(map,lng=-5.0, lat = 50.2, zoom = 7)  %>%  addWMSTiles(
  "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
  layers = "ea_wms_risk_of_flooding_from_surface_water_suitability",
  options = WMSTileOptions(format = "image/png", transparent = TRUE),
  tileOptions(tms = TRUE),
  attribution = "")



# # Surface water flooding
leaflet() %>% addTiles() %>% setView(map,lng=-5.0, lat = 50.2, zoom = 7)  %>%  addWMSTiles(
  "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
  layers = "ea_wms_risk_of_flooding_from_surface_water_extent_3_3_percent_annual_chance",
  options = WMSTileOptions(format = "image/png", transparent = TRUE),
  tileOptions(tms = TRUE),
  attribution = "", group="SWF")


# Display extent of 3 probabilities of surface water flooding
#
# Surface water flooding
leaflet() %>% addTiles() %>% setView(map,lng=-5.0, lat = 50.2, zoom = 7)  %>%  
  addWMSTiles(
    "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
    layers = "ea_wms_risk_of_flooding_from_surface_water_extent_3_3_percent_annual_chance",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    tileOptions(tms = TRUE),
    attribution = "", group="SWF_3") %>%
  addWMSTiles(
  "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
  layers = "ea_wms_risk_of_flooding_from_surface_water_extent_1_percent_annual_chance",
  options = WMSTileOptions(format = "image/png", transparent = TRUE),
  tileOptions(tms = TRUE),
  attribution = "", group="SWF_1") %>%  
  addWMSTiles(
    "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
    layers = "ea_wms_risk_of_flooding_from_surface_water_extent_0_1_percent_annual_chance",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    tileOptions(tms = TRUE),
    attribution = "", group="SWF_01") %>%
  addLayersControl(overlayGroups=c("SWF_3","SWF_1","SWF_01"))




# Surface water flooding
leaflet() %>% addTiles() %>% setView(map,lng=-5.0, lat = 50.2, zoom = 7)  %>%  addWMSTiles(
  "http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590",
  layers = "ea_wms_risk_of_flooding_from_surface_water_extent_0_1_percent_annual_chance",
  options = WMSTileOptions(format = "image/png", transparent = TRUE),
  tileOptions(tms = TRUE),
  attribution = "", group="SWF")




http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--92912a4f-d465-11e4-8687-f0def148f590
http://environment.data.gov.uk/ds/wms?SERVICE=WMS&INTERFACE=ENVIRONMENT--87e5d78f-d465-11e4-9343-f0def148f590

ea_wms_risk_of_flooding_from_surface_water_direction_2m_1_percent_annual_chance