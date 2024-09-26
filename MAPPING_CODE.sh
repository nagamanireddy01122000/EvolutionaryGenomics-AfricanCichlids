Step 1

Identify the sequence read archive accession code. As a test, here is a small accession SRR2183018.

Step 2

Use SRA explorer to obtain the script to download the files.

To use this, place the accession code in the search box, then enter (magnifying glass button). Tick the box, press blue box to add "to collection". Then enter the cart (saved datasets blue box), and press "Bash script for downloading FastQ files". Copy the script.

Step 3

Past script into a text editor, save as "Download.sh"

Step 4.

Enter the terminal, enter the correct folder (using the cd command).

Step 5. 

type the following

bash Download.sh


#!/bin/bash

#SBATCH --job-name=CichStep1
#SBATCH --account=xxxxxxxx
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

export TMPDIR=local

module load apps/bwa/0.7.17

module load apps/samtools/1.9

module load apps/gatk/4.1.9

#make reference file indices

#include in the folder GCA_900246225.5_fAstCal1.3_genomic.fna.gz

#include in the folder GCA_900246225.5_fAstCal1.3_genomic.fna

bwa index GCA_900246225.5_fAstCal1.3_genomic.fna.gz

gatk CreateSequenceDictionary -R GCA_900246225.5_fAstCal1.3_genomic.fna

samtools faidx GCA_900246225.5_fAstCal1.3_genomic.fna

#end of Step 1

#!/bin/bash

#SBATCH --job-name=CichStep2
#SBATCH --account=xxxxxxxx
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

export TMPDIR=local

module load apps/bwa/0.7.17

module load apps/samtools/1.9

#include in the folder your read files, in this example ERR266492_1.fastq.gz and ERR266492_2.fastq.gz

#include in the folder your genome and index files as listed below

#GCA_900246225.5_fAstCal1.3_genomic.fna.gz
#GCA_900246225.5_fAstCal1.3_genomic.fna
#GCA_900246225.5_fAstCal1.3_genomic.fna.fai
#GCA_900246225.5_fAstCal1.3_genomic.dict
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz.sa
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz.pac
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz.ann
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz.amb
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz.bwt

#map your reads and convert from sam to bam format

bwa mem GCA_900246225.5_fAstCal1.3_genomic.fna.gz ERR266492_1.fastq.gz ERR266492_2.fastq.gz > ERR266492.sam

samtools view -S -b ERR266492.sam > ERR266492.bam

#end of Step 2

#!/bin/bash

#SBATCH --job-name=CichStep3
#SBATCH --account=xxxxxxxx
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

export TMPDIR=local

module load apps/samtools/1.9

#include in the folder your output mapped bam files, in this example ERR266492.bam

#collate, sort, mark duplicates, add the read groups and finally index your bam files

samtools collate -o ERR266492_namecollate.bam ERR266492.bam

samtools fixmate -m ERR266492_namecollate.bam ERR266492_fixmate.bam

samtools sort -o ERR266492_sorted.bam ERR266492_fixmate.bam

samtools markdup ERR266492_sorted.bam ERR266492_sorted_MD.bam

samtools addreplacerg -r ID:ERR266492 -r LB:ERR266492 -r SM:ERR266492 -o ERR266492_sorted_named.bam ERR266492_sorted_MD.bam

samtools index ERR266492_sorted_named.bam

#end of Step 3
#!/bin/bash

#SBATCH --job-name=CichStep4
#SBATCH --account=bisc020142
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

export TMPDIR=local

module load apps/gatk/4.1.9

#include in the folder your processed bam files, in this example ERR266492_sorted_named.bam and the associated index file

#include in the folder your genome and index files as listed below
#GCA_900246225.5_fAstCal1.3_genomic.fna.gz
#GCA_900246225.5_fAstCal1.3_genomic.fna
#GCA_900246225.5_fAstCal1.3_genomic.fna.fai
#GCA_900246225.5_fAstCal1.3_genomic.dict

#get SNP calling, the output in this example will be ERR266492.vcf.gz and an associated index called ERR266492.vcf.gz.tbi

#I recall the -ERC GVCF is important!

gatk HaplotypeCaller -O ERR266492.g.vcf -I ERR266492_sorted_named.bam -R GCA_900246225.5_fAstCal1.3_genomic.fna -ERC GVCF
gatk HaplotypeCaller -O SRR7662377.g.vcf -I SRR7662377_sorted_named.bam -R GCA_900246225.5_fAstCal1.3_genomic.fna -ERC GVCF

#end of Step 4
#!/bin/bash

#SBATCH --job-name=CichStep5
#SBATCH --account=bisc020142
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

#Make intervals file

module load apps/gatk/4.1.9

module load apps/samtools/1.9

awk 'OFS="\t"{print $1, "0", $2}' GCA_900246225.5_fAstCal1.3_genomic.fna.fai > GCA_900246225.5_fAstCal1.3.bed

#Make folder /user/work/bzmjg/g.vcf_files
#Put all the g.vcf files into the folder g.vcf_files
#Put all the g.vcf.idx index into the folder g.vcf_files
#Make one -V line of code for every sample
#If you are running this for a second time, make sure you delete my_database from your folder

gatk GenomicsDBImport \
-V g.vcf_files/YOURSAMPLE1.g.vcf \
-V g.vcf_files/YOURSAMPLE2.g.vcf \
--genomicsdb-workspace-path my_database \
-L GCA_900246225.5_fAstCal1.3.bed

#Joint genotyping

gatk GenotypeGVCFs -R GCA_900246225.5_fAstCal1.3_genomic.fna -V gendb://my_database -O allsample_genotype.g.vcf.gz


GWAS analysis
