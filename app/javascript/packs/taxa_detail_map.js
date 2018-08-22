import baseMap from './base_map.js';

var apiEndpoint = `/api/v1${window.location.pathname}`;
var map = baseMap.createMap()
baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var markerClusterLayer =
    baseMap.createMarkerCluster(data.samplesData, baseMap.createCircleMarker)
  map.addLayer(markerClusterLayer);
  baseMap.renderBasicIndividualMarkers(data.baseSamplesData, map)
})