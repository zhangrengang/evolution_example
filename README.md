
### Prepare data ###
Download and pre-process the example data:
```
git clone https://github.com/zhangrengang/evolution_example
cd evolution_example
chmod +x src/*
find . -name "*gz" | xargs gunzip
cat OrthoFinder/*fasta > pep.faa
cat CDS/* > cds.fa
cat wgdi/*gff > all_species_gene.gff
```
Now, the directory structure like this:
```
$ tree
├── all_species_gene.gff	# all GFF
├── cds.fa			# all CDS sequences
├── pep.faa			# all protein sequences
├── species.design	# speceis list
├── OrthoFinder		# input for OrthoFinder
│   ├── Angelica_sinensis.fasta
│   ├── Apium_graveolens.fasta
│   ├── ......
└── wgdi			# input for WGDI
    ├── Angelica_sinensis-Angelica_sinensis.blast
    ├── Angelica_sinensis-Angelica_sinensis.conf
    ├── Angelica_sinensis-Angelica_sinensis.ctl		# for dotplot
    ├── Angelica_sinensis.gff
    ├── Angelica_sinensis.lens
    ├── ......
 ......
```
**Note**: the GENE ID is needed to label with SPECIES ID (e.g. `Angelica_sinensis|AS01G00001`) for compatibility.

### Run OrthoFinder ###
To infer Orthology:
```
orthofinder -f OrthoFinder/ -M msa -T fasttree -t 60
```

### Run WGDI ###
To detect Synteny:
```
cd wgdi

../src/comb2 `cat ../species.design` | while read LINE
do
	arr=($LINE)
	SP1=${arr[0]}
	SP2=${arr[1]}
	prefix=$SP1-$SP2
	conf=$prefix.conf

	# call synteny
	wgdi -icl $conf

	# dot plot colored by Orthology Index
	soi dotplot -s $prefix.collinearity \
		-g ../all_species_gene.gff -c $prefix.ctl  \
		--xlabel $SP1 --ylabel $SP2 \
		--ks-hist --max-ks 1 -o $prefix.io    \
		--plot-ploidy --gene-axis --number-plots \
		--ofdir ../OrthoFinder/OrthoFinder/Results_*/ \
		--of-color	# add --of-ratio 0.5 to show only orthology

done

cd ..
```

### Run SOI-Phylogenomics ###
To cluster syntenic orthogroups (SOGs) and construct phylogenomic analyses:
```
cd phylogenomics
ls ../wgdi/*.collinearity > collinearity.list

# filter collinearity
soi filter -s collinearity.list -o ../OrthoFinder/OrthoFinder/Results_* -c 0.6 > collinearity.ortho

# cluster SOGs excluding outgroups that do not share the lineage-specific WGD
soi cluster -s collinearity.ortho -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera -prefix cluster
# add outgroups
soi outgroup -s collinearity.ortho -og cluster.mcl -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera > cluster.mcl.plus

# build multi-copy or single-copy gene trees
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -root Vitis_vinifera -pre sog -p 80
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -root Vitis_vinifera -pre sog -sc -concat -p 80

# infer coalescent‐based species tree
astral-pro sog.mc.cds.mm0.4.genetrees > sog.sc.cds.mm0.4.genetrees.astral
astral-pro sog.sc.cds.mm0.4.genetrees > sog.sc.cds.mm0.4.genetrees.astral

# infer concatenation‐based species tree
iqtree2 -s sog.sc.cds.mm0.4.concat.aln -T 60 -B 1000 -mset GTR -o Vitis_vinifera
```

