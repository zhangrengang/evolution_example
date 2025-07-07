#!/bin/bash
SP1=$1
SP2=$2

echo "
[dotplot]
blast = $SP1-$SP2.blast
gff1 =  $SP1.gff
gff2 =	$SP2.gff
lens1 = $SP1.lens
lens2 = $SP2.lens
genome1_name =  $SP1
genome2_name =  $SP2
multiple  = 1
score = 100
evalue = 1e-5
repeat_number = 10
position = order
blast_reverse = false
ancestor_left = none
ancestor_top = none
markersize = 1
figsize = 10,10
savefig = $SP1-$SP2.dotplot.png

[collinearity]
blast = $SP1-$SP2.blast
gff1 =  $SP1.gff
gff2 =  $SP2.gff
lens1 = $SP1.lens
lens2 = $SP2.lens
blast_reverse = false
multiple  = 1
process = 8
evalue = 1e-5
score = 100
grading = 50,40,25
mg = 40,40
repeat_number = 10
positon = order
savefile = $SP1-$SP2.collinearity

[ks]
cds_file = ../../cds.fa
pep_file = ../../pep.faa
align_software = muscle
pairs_file = ../$SP1-$SP2.collinearity
ks_file = ../$SP1-$SP2.collinearity.ks

[blockinfo]
blast = $SP1-$SP2.blast
gff1 =  $SP1.gff
gff2 =  $SP2.gff
lens1 = $SP1.lens
lens2 = $SP2.lens
collinearity = $SP1-$SP2.collinearity.ortho
score = 100
evalue = 1e-5
repeat_number = 10
position = order
ks = $SP1-$SP2.collinearity.ks
ks_col = ks_NG86
savefile = $SP1-$SP2.blockinfo.csv

[correspondence]
blockinfo =  $SP1-$SP2.blockinfo.csv
lens1 = $SP1.lens
lens2 = $SP2.lens
tandem = false
tandem_length = 200
pvalue = 0.2
block_length = 10
multiple  = 1
homo = 0.5,1
savefile = $SP1-$SP2.blockinfo.new.csv

[blockks]
lens1 = $SP1.lens
lens2 = $SP2.lens
genome1_name =  $SP1
genome2_name =  $SP2
blockinfo = $SP1-$SP2.blockinfo.csv
#blockinfo = $SP1-$SP2.blockinfo.new.csv
pvalue = 0.2
tandem = true
tandem_length = 200
markersize = 1
area = -1,1
block_length =  5 
figsize = 8,8
savefig = $SP1-$SP2.blockks.png

[ancestral_karyotype]
gff = $SP1.gff
pep_file = $SP1.pep
ancestor = ak.txt
mark = ak
ancestor_gff =  ak.gff
ancestor_lens =  ak.lens
ancestor_pep =  ak.pep
ancestor_file =  ak.ancestor.txt

[ancestral_karyotype_repertoire]
blockinfo =  $SP1-$SP2.blockinfo.csv
# blockinfo: processed *.csv
blockinfo_reverse = False
gff1 =  $SP1.gff
gff2 =  $SP2.gff
gap = 5
mark = aak1s
ancestor = ak.txt
ancestor_new =  ak-$SP2.txt
ancestor_pep =  ../pep.faa
ancestor_pep_new =  ak-$SP2.pep
ancestor_gff =  ak-$SP2.gff
ancestor_lens =  ak-$SP2.lens

[polyploidy classification]
blockinfo = $SP1-$SP2.blockinfo.csv
ancestor_left = ak.txt
ancestor_top = $SP2.ancestor.edit.txt
classid = class1,class2
savefile = $SP1-$SP2.blockinfo.classification.csv

[karyotype_mapping]
blast = $SP1-$SP2.blast
gff1 =  $SP1.gff
gff2 =  $SP2.gff
blast_reverse = false
score = 100
evalue = 1e-5
repeat_number = 10
ancestor_left = ak.txt
the_other_lens = $SP2.lens
blockinfo = $SP1-$SP2.blockinfo.csv
limit_length = 8
the_other_ancestor_file =  $SP2.ancestor.txt

[alignment]
gff2 =  $SP2.gff
gff1 =  $SP1.gff
lens2 = $SP2.lens
lens1 = $SP1.lens
genome2_name =  $SP2
genome1_name =  $SP1
ancestor_top = $SP2.ancestor.edit.txt
ancestor_left = ak.txt
markersize = 1
ks_area = -1,1
position = order
colors = red,blue,green,orange
figsize = 10,10
savefile = $SP1-$SP2.alignment.csv
savefig= $SP1-$SP2.alignment.png
blockinfo = $SP1-$SP2.blockinfo.classification.csv
blockinfo_reverse = false
classid =  class2

[alignmenttrees]
alignment = $SP1-$SP2.alignment.csv
gff = all.gff
lens = $SP1.lens
dir = tree
sequence_file = ../pep.faa
cds_file = ../cds.fa
codon_positon = 1,2,3
trees_file =  trees.nwk
align_software = mafft
tree_software =  iqtree
model = MFP
trimming =  trimal
minimum = 4
delete_detail = true

[retain]
alignment = $SP1-$SP2.alignment.csv
gff = $SP1.gff
lens = $SP1.lens
colors = red,blue,green,orange
refgenome = ref
figsize = 10,12
step = 50
ylabel = Retained genes
savefile = $SP1-$SP2.alignment.retain
savefig = $SP1-$SP2.alignment.retain.png

[circos]
gff =  all.gff
lens =  $SP1.lens
radius = 0.5
angle_gap = 0.1
ring_width = 0.1
colors  = Fx1:c,Fx2:m,Fx3:blue,Fx4:gold,Fx5:red,6:lawngreen,7:darkgreen,8:k,9:darkred,10:gray,11:#FFFF33,12:#FFB6C1,13:#CCFF33,14:gold,15:red,16:#CC99FF,17:#FAFAD2,18:#FF1493,19:#00FFFF
alignment = $SP1-$SP2.alignment.csv
ancestor = ref.anc.alignment
ancestor_location = $SP2.ancestor.edit.txt
chr_label = ref
figsize = 10,10
label_size = 15
column_names = 1,2,3,4
savefig = $SP1-$SP2.circos.png
"
