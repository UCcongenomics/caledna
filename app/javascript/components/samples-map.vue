<template>
  <div>
    <spinner v-if="showSpinner" />
    <div class="taxa-markers">
      <div>
        <svg height="30" width="30" @click="toggleTaxonLayer">
          <circle
            cx="15"
            cy="15"
            r="7"
            stroke="#222"
            stroke-width="2"
            fill="#5aa172"
          />
        </svg>
        {{ taxonSamplesCount }} {{ "site" | pluralize(taxonSamplesCount) }}
      </div>
      <div class="filters-list" v-show="currentFiltersDisplay">
        filters: {{ currentFiltersDisplay }}
        <a class="btn btn-default reset-search" @click="resetFilters">
          Reset search
        </a>
      </div>
    </div>

    <div class="samples-menu">
      <div class="row">
        <div class="col-md-8">
          <form class="input-group search-form" @submit.prevent="submitFilters">
            <div class="input-group-btn">
              <div
                class="btn btn-default dropdown-toggle"
                data-toggle="dropdown"
              >
                {{ searchMeta[searchType]["label"] }}
                <span class="caret"></span>
              </div>
              <ul class="dropdown-menu">
                <li class @click="searchType = 'sites'">Sites</li>
                <li class @click="searchType = 'taxa'">Organisms</li>
              </ul>
            </div>
            <input
              type="text"
              class="form-control"
              :placeholder="searchMeta[searchType]['placeholder']"
              v-model="store.state.currentFilters.keyword"
            />

            <div class="input-group-btn">
              <button class="btn btn-primary" type="submit">
                <i class="fas fa-search"></i>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div class="samples-menu">
      <map-table-toggle
        :active-tab="activeTab"
        @active-tab-event="setActiveTab"
      />
      <filters-layout
        :store="store"
        @reset-filters="resetFilters"
        @submit-filters="submitFilters"
      />
    </div>

    <div id="mapid" v-show="activeTab === 'map'"></div>

    <div v-show="activeTab === 'table'">
      <vue-good-table
        :pagination-options="{
          enabled: true,
          mode: 'records',
          perPage: 25,
          position: 'bottom',
          perPageDropdown: [25, 50],
          dropdownAllowAll: false,
        }"
        :columns="columns"
        :rows="rows"
      >
        <template slot="table-row" slot-scope="props">
          <span v-if="props.column.field == 'barcode'">
            <a v-bind:href="`/samples/${props.row.id}`">{{
              props.row.barcode
            }}</a>
          </span>
          <span v-else-if="props.column.field == 'location'">
            {{ props.row.location }}
            <br />
            <br />
            {{ props.row.coordinates }}
          </span>
          <span v-else>{{ props.formattedRow[props.column.field] }}</span>
        </template>
      </vue-good-table>
    </div>
    <map-layers-modal />
  </div>
</template>

<script>
import { VueGoodTable } from "vue-good-table";
import "vue-good-table/dist/vue-good-table.css";
import axios from "axios";
import pluralize from "pluralize";

import Spinner from "./shared/spinner";
import MapTableToggle from "./shared/map-table-toggle";
import FiltersLayout from "./shared/filters/all-samples";
import MapLayersModal from "./shared/map-layers-modal";

import { formatQuerystring } from "../utils/data_viz_filters";
import baseMap from "../packs/base_map.js";
import { samplesTableColumns, samplesDefaultFilters } from "../constants";
import { mapMixins, searchMixins, taxonLayerMixins } from "../mixins";
import { allSamplesStore } from "../stores/stores";

export default {
  name: "SamplesMapTable",
  components: {
    VueGoodTable,
    MapTableToggle,
    FiltersLayout,
    Spinner,
    MapLayersModal,
  },
  mixins: [mapMixins, searchMixins, taxonLayerMixins],
  filters: {
    pluralize,
  },
  data() {
    return {
      activeTab: "map",
      columns: samplesTableColumns,
      rows: [],
      map: null,
      endpoint: `/api/v1/samples`,
      store: allSamplesStore,
      currentFiltersDisplay: null,
      showSpinner: false,

      taxonSamplesCount: null,
      taxonLayer: null,
      showTaxonLayer: true,
      taxonSamplesData: [],
      initialTaxonSamplesData: [],
      searchType: "sites",
      searchMeta: {
        sites: { label: "Sites", placeholder: "Search site and project names" },
        taxa: {
          label: "Organisms",
          placeholder:
            "Search organisms by Latin or common names (e.g. Canis lups, wolf)",
        },
      },
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
    setActiveTab(event) {
      this.activeTab = event;
    },

    addTaxonLayer() {
      const samples = this.taxonSamplesData.filter(function (sample) {
        return sample.latitude && sample.longitude;
      });

      this.taxonLayer = baseMap.renderClusterLayer(samples, this.map);
    },

    //================
    // handle filters
    //================
    resetFilters() {
      this.showTaxonLayer = true;
      this.store.state.currentFilters.keyword = null;
      this.taxonSamplesCount = null;
      this.store.state.currentFilters = { ...samplesDefaultFilters };
      this.fetchSamples(this.endpoint);
      this.currentFiltersDisplay = null;
    },

    submitFilters() {
      if (this.searchType == "sites") {
        if (this.store.state.currentFilters.keyword) {
          this.filterSamplesBackend();
        } else {
          this.filterSamplesFrontend();
        }
        this.currentFiltersDisplay = this.formatCurrentFiltersDisplay(
          this.store.state.currentFilters
        );
      } else {
        this.handleTaxaSearch();
      }
    },

    filterSamplesFrontend() {
      let filters = this.store.state.currentFilters;
      let samples = this.initialTaxonSamplesData;
      this.taxonSamplesData = this.filterSamples(filters, samples);

      this.prepareSamplesDisplay();
    },

    filterSamplesBackend() {
      let queryString = formatQuerystring(this.store.state.currentFilters);
      let url = queryString ? `${this.endpoint}?${queryString}` : this.endpoint;
      this.fetchSamples(url);
    },

    handleTaxaSearch() {
      window.location = `/taxa_search?query=${this.store.state.currentFilters.keyword}`;
    },

    //================
    // config table
    //================
    formatTableData(samples) {
      this.rows = samples.map((sample) => {
        const {
          id,
          barcode,
          latitude,
          longitude,
          location,
          status,
          primer_names,
          substrate,
          collection_date,
          taxa_count,
        } = sample;

        const formatDateString = (dateString) => {
          if (dateString) {
            let date = new Date(dateString);
            return date.toLocaleDateString();
          }
        };

        return {
          id,
          barcode,
          coordinates: `${latitude}, ${longitude}`,
          location,
          status: status && status.replace("_", " "),
          primers: primer_names ? primer_names.join(", ") : "",
          substrate: substrate,
          taxa_count: taxa_count ? taxa_count : 0,
          collection_date: formatDateString(collection_date),
        };
      });
    },

    //================
    // fetch samples
    //================
    fetchSamples(url) {
      this.showSpinner = true;
      axios
        .get(url)
        .then((response) => {
          const mapData = baseMap.formatMapData(response.data);
          if (this.initialTaxonSamplesData.length == 0) {
            this.initialTaxonSamplesData = mapData.taxonSamplesData;
          }
          this.taxonSamplesData = mapData.taxonSamplesData;

          this.prepareSamplesDisplay();

          this.showSpinner = false;
        })
        .catch((e) => {
          console.error(e);
        });
    },
    prepareSamplesDisplay() {
      this.formatTableData(this.taxonSamplesData);
      this.taxonSamplesCount = this.taxonSamplesData.length;

      this.removeTaxonLayer();
      if (this.showTaxonLayer) {
        this.addTaxonLayer();
      }
    },
  },
};
</script>

<style scoped>
.dropdown-menu li {
  padding: 3px 20px;
  white-space: nowrap;
}

.dropdown-menu li:hover {
  text-decoration: none;
  background-color: #e8e8e8;
}
</style>
