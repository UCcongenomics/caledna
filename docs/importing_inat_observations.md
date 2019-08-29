import csv

```bash
bin/rake inat_taxa:create_la_river_inat_taxa[file path]

bin/rake inat_obs:create_la_river_inat_observations[file path]
```

==

create higher taxa in inat_taxa

```bash
bin/rake inat_taxa:create_higher_ranks
```

==

add inat data to inat_taxa using inat api

```bash
bin/rake inat_taxa:update_existing_taxa
```

check if every inat_taxa is in external_resources

```sql
select *
from external.inat_taxa as inat_taxa
left join external_resources
on external_resources.inaturalist_id = inat_taxa.taxon_id
where inaturalist_id is null;

SELECT canonical_name, taxon_id
FROM external.inat_taxa
left join external_resources
on external_resources.inaturalist_id = inat_taxa.taxon_id
WHERE external_resources.inaturalist_id IS NULL
GROUP BY canonical_name, taxon_id;
```

add external resources for inat taxa

```bash
bin/rake external_resources:create_resources_for_inat_taxa
```

==
r script
add ncbi_id to external_resources for inat taxa

status rank division scientificname commonname uid genus species subsp
1 active order vertebrates Crocodylia alligators and others 1294634
2 active superorder lizards Lepidosauria lepidosaurs 8504
3 active order turtles Testudines turtles 8459

==
update inat_id for ncbi taxa where canonical_name matches

```bash
bin/rake external_resources:update_inat_id_for_ncbi_taxa
```

==

clean up external_resources so inat taxa and ncbi taxa make sense

find external_resources where ncbi taxa and inat taxa have different
canonical names or kingdoms

```sql
select inat_taxa.rank as inat_rank, ncbi_nodes.rank as ncbi_rank,
inat_taxa.taxon_id as inat_taxon_id, ncbi_nodes.taxon_id as ncbi_taxon_id,
inat_taxa.kingdom as inat_kingdom, ncbi_divisions.name as ncbi_kingdom,
inat_taxa.canonical_name as inat_name,
ncbi_nodes.canonical_name as ncbi_name,
external_resources.created_at, source
from external_resources
join external.inat_taxa as inat_taxa
on external_resources.inaturalist_id = inat_taxa.taxon_id
join ncbi_nodes on external_resources.ncbi_id = ncbi_nodes.taxon_id
join ncbi_divisions on ncbi_divisions.id = ncbi_nodes.cal_division_id
where inat_taxa.canonical_name != ncbi_nodes.canonical_name
or inat_taxa.kingdom != ncbi_divisions.name
order by external_resources.created_at desc;
```

manually update ncbi_id or inat_id in external_resources

```bash
bin/rake external_resources:manually_update_inat_taxa
```

check every inat taxa that doesn't have ncbi_id

```sql
select inat_taxa.*
from external_resources
join external.inat_taxa as inat_taxa on inat_taxa.taxon_id = external_resources.inaturalist_id
where external_resources.ncbi_id is null
order by rank;
```

manually update ncbi_id or inat_id in external_resources

```bash
bin/rake external_resources:manually_update_inat_taxa
```

==

add inaturlist_id to ncbi taxa in external_resources

add inat api data for ncbi taxa that do not have inaturlist_id

```bash
bin/rake external_resources:add_inat_id_to_ncbi_taxa
```

manually edit payload with multiple records

add inaturalist_id to ncbi taxa

```sql
 update external_resources set inaturalist_id = foo.inaturalist_id from (
 select (payload ->> 'id')::integer as inaturalist_id, id from external_resources  where source = 'foo'
 ) as foo
 where external_resources.id = foo.id ;
```

create inat_taxa using inaturalist_id that aren't in inat_taxa

```sql
 select inaturalist_id
 from external_resources
left join external.inat_taxa as inat_taxa on inat_taxa.taxon_id = external_resources.inaturalist_id
 where source = 'foo'
 and  inat_taxa.taxon_id is null ;
```

connect to inat api to fill in taxa info

create new inat_taxa for ids that aren't in inat_taxa

connect to inat api to fill in taxa info

==
misc

reimport external_resources table from csv

```
\copy external_resources from 'external_resources.csv' csv header;
```

reset id after csv import

```sql
ALTER SEQUENCE external_resources_id_seq1 RESTART WITH 451464;
```

==

clean up nbci_nodes

delete bad taxa

```bash
bin/rake ncbi:delete_bad_imported_taxa
```

add missing nbci_id to ncbi_nodes

```bash
 bin/rake ncbi:add_ncbi_id_to_ncbi_nodes
```

==

add source to inat_taxa

```bash
bin/rake inat_taxa:add_source
```

==

clean up external_resources

add missing search term

```bash
bin/rake external_resources:fill_in_missing_search_term
```

==

update cal_division_id from superkingdom to order

```sql
-- change kingdoms for nbci

select  ncbi_divisions.name,
 ncbi_nodes.hierarchy_names ->> 'superkingdom' as superkingdom,
ncbi_nodes.hierarchy_names ->> 'kingdom' as kingdom,
ncbi_nodes.hierarchy_names ->> 'phylum' as phylum,
ncbi_nodes.hierarchy_names ->> 'class' as class,
ncbi_nodes.hierarchy_names ->> 'order' as order,
ncbi_nodes.hierarchy ->> 'phylum',
ncbi_nodes.hierarchy ->> 'class',
ncbi_nodes.hierarchy ->> 'order'

from ncbi_nodes
join ncbi_divisions on ncbi_divisions.id = ncbi_nodes.cal_division_id
where (ncbi_nodes.hierarchy_names ->> 'superkingdom')::Text = 'Eukaryota'
and name != 'Environmental samples'

group by ncbi_divisions.name,
ncbi_nodes.hierarchy_names ->> 'superkingdom',
ncbi_nodes.hierarchy_names ->> 'kingdom' ,
ncbi_nodes.hierarchy_names ->> 'phylum',
ncbi_nodes.hierarchy_names ->> 'class',
ncbi_nodes.hierarchy_names ->> 'order' ,
ncbi_nodes.hierarchy ->> 'phylum',
ncbi_nodes.hierarchy ->> 'class',
ncbi_nodes.hierarchy ->> 'order'
;
```

```bash
bin/rake ncbi:update_cal_division_up_to_order
```

==