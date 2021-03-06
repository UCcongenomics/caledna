<template>
  <div
    class="modal fade"
    id="map-layer-modal"
    tabindex="-1"
    role="dialog"
    aria-labelledby="exampleModalLabel"
  >
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
          <h4 class="modal-title" id="exampleModalLabel">Map Layers</h4>
        </div>
        <div class="modal-body">
          <p>
            <b>HyspIRI</b>
            <br />Flight path of NASA's Hyperspectral Infrared Imager (HyspIRI) airborne
            campaign. The mission uses imaging spectroscopy to study Earth's ecosystem.
          </p>
          <p>
            <b>UC Reserves</b>
            <br />The University of California Natural Reserve System is a network of
            protected natural areas throughout California.
          </p>
          <p>
            <b>bldfie - Bulk Density (Fine Earth fraction) in kg / cubic cm</b>
            <br />(Hengl et al., 2014)
            <br />BLDFIE represents the density of the soil in kilograms per cubic centimeter.
            The fine earth fraction generally defines particle sizes to be less than
            2 mm. The darker the shade of purple is, the greater the density and
            compaction of the soil.
          </p>

          <p>
            <b>clyppt - Clay Mass Fraction in %</b>
            <br />(Hengl et al., 2014)
            <br />CLYPPT represents the percentage of clay within the soil. Soil is a
            mixture of clay, silt, and sand, and soil texture composition affects its
            physical and chemical properties. Clay is defined as particles between
            the sizes of 0 - 2 micometers. A zero value (white) shows very little
            clay amounts in the soil. A 100 value (dark purple) shows that the soil
            is mostly composed of clay. Clay amounts should have a negative
            correlation with sand amounts.
          </p>

          <p>
            <b>sltppt - Silt Mass Fraction in %</b>
            <br />(Hengl et al., 2014)
            <br />SLTPPT represents the percentage of silt within the soil. Soil is a
            mixture of clay, silt, and sand, and soil texture composition affects its
            physical and chemical properties. A zero value (white) shows very little
            silt amounts in the soil. A 100 value (dark purple) shows that the soil
            is mostly composed of silt. Silt is defined as particles between the
            sizes of 2 - 50 micometers.
          </p>

          <p>
            <b>sndppt - Sand Mass Fraction in %</b>
            <br />(Hengl et al., 2014)
            <br />SNDPPT represents the percentage of sand within the soil. Soil is a
            mixture of clay, silt, and sand, and soil texture composition affects
            its physical and chemical properties. Sand is defined as particles between
            the sizes of 50 - 200 micometers. A zero value (white) shows very little
            sand amounts in the soil. A 100 value (dark purple) shows that the soil
            is mostly composed of sand. Sand amounts should have a negative
            correlation with clay amounts.
          </p>

          <p>
            <b>hii - Human Footprint in %</b>
            <br />(Wildlife Conservation Society, 2005)
            <br />Human Footprint is the relative human influence (hii) in percent,
            normalized by biome and realm. The human influence index considers human
            population density, land-use and infrastructure, and human transportation
            and access. A zero value (green) represents the least human influenced
            (the most wild) part of the biome. A 100 value (red) represents the most
            human influenced (least wild) part of the biome.
          </p>

          <p>
            <b>Elevation in m</b>
            <br />(Farr et al., 2007)
            <br />The altitude or elevation is in units of meters, relative to sea level.
            Values less than 0 (green) are below sea level. As color values transition
            from yellow to brown to red, elevation increases. Values in white are the
            highest points in California.
          </p>

          <p>
            <b>Annual Precipitation in mm</b>
            <br />(Fick & Hijmans, 2017)
            <br />The average annual precipitation is in units of millimeters. Areas in
            green receive very little average precipitation throughout the year,
            while areas in red receive the highest average annual precipitation.
          </p>

          <p>
            <b>Population Density in persons / sq. km</b>
            <br />(Center for International Earth Science Information Network, 2017)
            <br />Human population density is the number of persons per square kilometer,
            estimated for the year 2015. These numbers were estimated by national
            censuses for the years 2000, 2005, 2010, 2015, and 2020. Note that not
            every area has a determined value, as these areas are less inhabited.
            This may be due to the variable landscape in California, such as
            agriculture and mountainous ranges. Also note that much of California
            shows very sparse people (yellow) with less than 50 people/sq.km, while
            the very densest cities (red) may have values up to 40,000 people/sq.km.
          </p>

          <h3>References</h3>
          <p>
            Center for International Earth Science Information Network - CIESIN -
            Columbia University. 2017. Gridded Population of the World, Version 4
            (GPWv4): Population Density, Revision 10. Palisades, NY: NASA
            Socioeconomic Data and Applications Center (SEDAC).
            <a
              href="https://doi.org/10.7927/H4DZ068D"
            >https://doi.org/10.7927/H4DZ068D</a>.
            Accessed 21 Aug 2018.
          </p>
          <p>
            Fick, S.E. and R.J. Hijmans. 2017. Worldclim 2: New 1-km spatial
            resolution climate surfaces for global land areas. International
            Journal of Climatology.
          </p>
          <p>
            Hengl, T., de Jesus, J.M., MacMillan, R.A., Batjes, N.H., Heuvelink,
            G.B.M., et al. (2014) SoilGrids1km — Global Soil Information Based on
            Automated Mapping. PLoS ONE 9(8): e105992.
            doi:10.1371/journal.pone.0105992 ISRIC – World Soil Information, 2013.
          </p>
          <p>
            Farr, T.G., Rosen, P.A., Caro, E., Crippen, R., Duren, R., Hensley,
            S., Kobrick, M., Paller, M., Rodriguez, E., Roth, L., Seal, D., Shaffer,
            S., Shimada, J., Umland, J., Werner, M., Oskin, M., Burbank, D., Alsdorf,
            D. (2007), The Shuttle Radar Topography Mission, Rev. Geophys., 45,
            RG2004.
            <a href="https://doi.org/10.1029/2005RG000183">https://doi.org/10.1029/2005RG000183</a>
          </p>
          <p>
            Wildlife Conservation Society - WCS, and Center for International
            Earth Science Information Network - CIESIN - Columbia University. 2005.
            Last of the Wild Project, Version 2, 2005 (LWP-2): Global Human
            Footprint Dataset (Geographic). Palisades, NY: NASA Socioeconomic
            Data and Applications Center (SEDAC).
            <a
              href="http://dx.doi.org/10.7927/H4M61H5F"
            >http://dx.doi.org/10.7927/H4M61H5F</a>.
            Accessed 21 Aug 2018.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
