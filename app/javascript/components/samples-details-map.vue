<template>
  <div>
    <spinner v-if="showSpinner" />
    <div id="mapid"></div>
    <map-layers-modal />
  </div>
</template>

<script>
import axios from "axios";

import Spinner from "./shared/spinner";
import MapLayersModal from "./shared/map-layers-modal";

import baseMap from "../packs/base_map.js";
import { mapMixins } from "../mixins";

export default {
  name: "SamplesDetail-Map",
  components: {
    Spinner,
    MapLayersModal,
  },
  mixins: [mapMixins],
  data() {
    return {
      map: null,
      endpoint: `/api/v1${window.location.pathname}`,
      showSpinner: false,
    };
  },
  created() {
    this.fetchSamples(this.endpoint);
  },
  mounted() {
    this.map = baseMap.createMap();
    this.addMapOverlays(this.map);
  },
  methods: {
    //================
    // fetch samples
    //================
    fetchSamples(url) {
      this.showSpinner = true;
      axios
        .get(url)
        .then((response) => {
          const data = baseMap.formatSamplesData(response.data.sample.data);

          if (data.lat && data.lng) {
            baseMap.createCircleMarker(data).addTo(this.map);
            this.map.panTo(new L.LatLng(data.lat, data.lng));
          }

          this.showSpinner = false;
        })
        .catch((e) => {
          console.error(e);
        });
    },
  },
};
</script>
