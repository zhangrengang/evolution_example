
### Prepare data ###

```
git clone https://github.com/zhangrengang/evolution_example
cd evolution_example
chmod +x src/*
find . -name "*gz" | xargs gunzip
cat OrthoFinder/*fasta > pep.faa
cat CDS/* > cds.fa
cat wgdi/*gff > all_species_gene.gff
```

### Run OrthoFinder ###
```
orthofinder -f OrthoFinder/ -M msa -T fasttree -t 60
```

### Run WGDI ###
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
	--ofdir ../OrthoFinder/OrthoFinder/Results_*/ --of-color

done

cd ..
```

### Run SOI-Phylogenomics ###
```
cd phylogenomics
ls ../wgdi/*.collinearity > collinearity.list

# filter collinearity
soi filter -s collinearity.list -o ../OrthoFinder/OrthoFinder/Results_* -c 0.6 > collinearity.ortho

# cluster SOGs excluding outgroups
soi cluster -s collinearity.ortho -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera -prefix cluster
# add outgroups
soi outgroup -s collinearity.ortho -og cluster.mcl -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera > cluster.mcl.plus

# build gene multi-copy or single-copy trees
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -root Vitis_vinifera -pre mc-sog -concat -p 80
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -root Vitis_vinifera -pre sc-sog -sc -concat -p 80

# infer coalescent‐based species tree
astral-pro mc-sog.0.4.cds.genetrees > sc-sog.0.4.cds.genetrees.astral
astral-pro sc-sog.0.4.cds.genetrees > sc-sog.0.4.cds.genetrees.astral

# infer concatenation‐based species tree
iqtree2 -s sc-sog.cds.mm0.4.concat.aln -T 60 -B 1000 -mset GTR -o Vitis_vinifera
```

