import axios from "axios";
import { Spinner } from "spin.js";
import baseVenn from "./base_venn.js";

// =============
// config
// =============

const location_names = {
  "Arroyo Seco": "Arroyo Seco",
  "Maywood": "Maywood"
};
let diversityData;
const endpoint = "/api/v1/research_projects/la_river/pa_area_diversity";
const graphEls = document.querySelector("#graph-edna");

// =============
// misc
// =============

function initApp(endpoint) {
  const opts = { color: "#333", left: "50%", scale: 1.75 };
  let spinner1 = new Spinner(opts).spin(graphEls);

  axios
    .get(endpoint)
    .then(res => {
      diversityData = res.data;
      const ednaSets = formatDatasets(diversityData.cal);

      baseVenn.drawVenn(ednaSets, "#graph-edna");

      let tableColumns = ["sets", "size"];
      let tableColumnNames = ["location", "species count"];
      baseVenn.drawTable(
        ednaSets,
        tableColumns,
        tableColumnNames,
        "#table-edna"
      );

      spinner1.stop();
    })
    .catch(err => console.log(err));
}

function formatDatasets(data) {
  return data.locations.map(location => {
    const set_name = location.names.map(location => location_names[location]);
    return { sets: set_name, size: location.count };
  });
}

// =============
// init
// =============

baseVenn.config({
  graphs: graphEls,
  apiEndpoint: endpoint,
  init: initApp,
  chartFilters: []
});
initApp(endpoint);
