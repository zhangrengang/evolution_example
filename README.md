## Table of Contents

   * [Prepare data](#Prepare-data)
   * [Installation](#Installation)
   * [Run OrthoFinder for orthology](#Run-OrthoFinde-for-orthology)
   * [Run WGDI for synteny](#Run-WGDI-for-synteny)
   * [Run SOI for orthologous synteny and species tree](#Run-SOI-for-orthologous-synteny-and-species-tree)

### Prepare data ###
Download and pre-process the example data:
```
# git-lfs has been installed
git lfs clone https://github.com/zhangrengang/evolution_example
cd evolution_example

chmod +x src/*
find . -name "*gz" | xargs gunzip
cat OrthoFinder/*fasta > pep.faa
cat CDS/* > cds.fa
cat wgdi/*gff > all_species_gene.gff
```
If it is hard to download from GitHub, altenatively you can try to download from [BaiduYun](https://pan.baidu.com/s/1Qz-GjO0KQ1Ao2zw7vvwihg?pwd=a83p).
Now, the directory structure like this:
```
$ tree
├── all_species_gene.gff        # all GFF
├── cds.fa                      # all CDS sequences
├── pep.faa                     # all protein sequences
├── species.design              # speceis list
├── OrthoFinder                 # input for OrthoFinder
│   ├── Angelica_sinensis.fasta
│   ├── Apium_graveolens.fasta
│   ├── ......
└── wgdi                        # input for WGDI
    ├── Angelica_sinensis-Angelica_sinensis.blast
    ├── Angelica_sinensis-Angelica_sinensis.conf
    ├── Angelica_sinensis-Angelica_sinensis.ctl   # for `soi dotplot`
    ├── Angelica_sinensis.gff
    ├── Angelica_sinensis.lens
    ├── ......
 ......
```
**Note**: the GENE ID is needed to label with SPECIES ID (e.g. `Angelica_sinensis|AS01G00001`) for 
uniqueness and compatibility (legacy from OrthoMCL). 
The CHROMosome ID should also be unique (e.g. `As1`, `As2`) to avoid conflicts (legacy from MCscanX).
The IDs can be easily labeled for your own data; for example: 
```
SP=Angelica_sinensis
# using OrthoMCL command for fasta files:
orthomclAdjustFasta $SP $SP.pep 1
# or using sed:
sed 's/>/>'$SP'|/' $SP.pep > $SP.fasta  # always using the separator '|'

SP2=As
# using awk for MCscanX/WGDI gff files:
awk -v sp=$SP -v OFS="\t" '{$2=sp"|"$2;print $0}' $SP.gff0 | perl -pe 's/^\D+/'$SP2'/' > $SP.gff
```
`SP` and `SP2` can be the same.
### Installation ###
If you have installed [OrthoIndex](https://github.com/zhangrengang/orthoindex#installation), 
all the commands used in this pipeline should have been installed.

### Run OrthoFinder for orthology ###
To infer 'orthology' using [OrthoFinder2](https://github.com/davidemms/OrthoFinder):
```
orthofinder -f OrthoFinder/ -M msa -t 60
```
`orthofinder` can by replaced by [Proteinortho6](https://gitlab.com/paulklemm_PHD/proteinortho), 
[Broccoli](https://github.com/rderelle/Broccoli) and 
[SonicParanoid2](https://gitlab.com/salvo981/sonicparanoid2).

### Run WGDI for synteny ###
To detect 'synteny' by [WGDI](https://github.com/SunPengChuan/wgdi), with visualization by `SOI` :
```
cd wgdi

../src/comb2 `cat ../species.design` | while read LINE
do
    arr=($LINE)
    SP1=${arr[0]}
    SP2=${arr[1]}
    prefix=$SP1-$SP2
    conf=$prefix.conf

    # blast
    diamond blastp -q ../OrthoFinder/$SP1.pep -d ../OrthoFinder/$SP2.pep -o $prefix.blast --more-sensitive -p 10 --quiet -e 0.001

    # call synteny
    wgdi -icl $conf

    # dot plot colored by Orthology Index
    soi dotplot -s $prefix.collinearity \
        -g ../all_species_gene.gff -c $prefix.ctl  \
        --xlabel $SP1 --ylabel $SP2 \
        --ks-hist --max-ks 1 -o $prefix.io    \
        --plot-ploidy --gene-axis --number-plots \
        --ofdir ../OrthoFinder/OrthoFinder/Results_*/ \
        --of-color

    # to show only orthology
    soi dotplot -s $prefix.collinearity \
        -g ../all_species_gene.gff -c $prefix.ctl  \
        --xlabel $SP1 --ylabel $SP2 \
        --ks-hist --max-ks 1 -o $prefix.io    \
        --plot-ploidy --gene-axis --number-plots \
        --ofdir ../OrthoFinder/OrthoFinder/Results_*/ \
        --of-color --of-ratio 0.6

done

cd ..
```

If you also need Ks-based visualization:
```
cd wgdi

../src/comb2 `cat ../species.design` | while read LINE
do
    arr=($LINE)
    SP1=${arr[0]}
    SP2=${arr[1]}
    prefix=$SP1-$SP2
    conf=$prefix.conf

    # calculate Ks
    wgdi -ks $conf

    # dot plot colored by Ks
    soi dotplot -s $prefix.collinearity \
        -g ../all_species_gene.gff -c $prefix.ctl  \
        --kaks $prefix.collinearity.ks \
        --xlabel $SP1 --ylabel $SP2 \
        --ks-hist --max-ks 1.5 -o $prefix     \
        --plot-ploidy --gene-axis --number-plots

    # to show only orthology
    soi dotplot -s $prefix.collinearity \
        -g ../all_species_gene.gff -c $prefix.ctl  \
        --kaks $prefix.collinearity.ks \
        --xlabel $SP1 --ylabel $SP2 \
        --ks-hist --max-ks 1.5 -o $prefix     \
        --plot-ploidy --gene-axis --number-plots \
        --ofdir ../OrthoFinder/OrthoFinder/Results_*/ \
        --of-ratio 0.6       # filtering by OI

done

cd ..
```
`wgdi` can be replaced by [JCVI](https://github.com/tanghaibao/jcvi) and
[MCscanX](http://chibba.pgml.uga.edu/mcscan2).

### Run SOI for orthologous synteny and species tree ###
To cluster syntenic orthogroups (SOGs) and construct phylogenomic analyses:
```
cd phylogenomics

# to filter collinearity
soi filter -s ../wgdi/*.collinearity -o ../OrthoFinder/OrthoFinder/Results_*/ -c 0.6 > collinearity.ortho

# to cluster SOGs excluding outgroups that do not share the lineage-specific WGD
soi cluster -s collinearity.ortho -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera -prefix cluster
# to add outgroups
soi outgroup -s collinearity.ortho -og cluster.mcl -outgroup Lonicera_japonica Ilex_polyneura Vitis_vinifera > cluster.mcl.plus

# to build multi-copy or single-copy gene trees
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -pre sog -mm 0.4 -p 80 -tmp tmp.mc.0.4
soi phylo -og cluster.mcl.plus -pep ../pep.faa -cds ../cds.fa -both -pre sog -mm 0.2 -p 80 -tmp tmp.sc.0.2 -sc -concat -trimal_opts " -gappyout" -iqtree_opts " -B 1000"

# to infer coalescent‐based species tree
astral-pro --root Vitis_vinifera sog.mc.cds.mm0.4.genetrees > sog.mc.cds.mm0.4.genetrees.astral
astral-hybrid --root Vitis_vinifera sog.sc.cds.mm0.2.genetrees > sog.sc.cds.mm0.2.genetrees.astral

# to infer concatenation‐based species tree
iqtree2 -s sog.sc.cds.mm0.2.concat.aln -T 60 -B 1000 -mset GTR -o Vitis_vinifera
```
Note: although we set a unified cutoff (0.6) in the pipeline, users should manually check the resulted dot plots for confirmation, 
and some extremely complex cases showing unexpected patterns need to be investigated on a case-by-case basis.
