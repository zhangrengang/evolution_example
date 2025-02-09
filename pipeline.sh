# preparation
git clone https://github.com/zhangrengang/orthoindex.git
(cd orthoindex

# install
conda env create -f OrthoIndex.yaml
conda activate OrthoIndex
python3 setup.py install
)

chmod +x src/*
find . -name "*gz" | xargs gunzip
cat OrthoFinder/*fasta > pep.faa
cat CDS/* > cds.fa
cat wgdi/*gff > all_species_gene.gff

# orthology
orthofinder -f OrthoFinder/ -M msa -t 60

# synteny
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

# phylogenomics
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

