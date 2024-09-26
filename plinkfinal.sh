#!/bin/bash
#SBATCH --job-name=CichStep2
#SBATCH --account=gely031204
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --cpus-per-task=1
#SBATCH --time=100:00:00
#SBATCH --mem=50000M

cd /user/work/be23726/

export TMPDIR=local

 module load apps/plink/1.90

#Example code for doing a GWAS with a continuous response variable, using a variant call file (vcf)

#Prune the vcf file, here we are using Example.vcf. In this example we are asking plink to identify the variants that will be used in the later analyses. The dataset will be pruned so that in 2kb windows, every 2kb, remove loci in strong linkage disequilibrium (r2>0.3) wil be removed, focussing only one. This is not absolutely essential, but it will reduce the size of dataset and therefore increase power to detect variants of interest.

plink --vcf allsample_genotype_2.g.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:#  --indep-pairwise 2 2 0.3 --out Example

#Make a PCA and a bed file with only the pruned data, note we have asked the pca to only output one eigenvector PC1, as this is the main axis of population genetic structure

plink --vcf allsample_genotype_2.g.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract Example.prune.in --make-bed --pca 1 --out Example

#Make the reponse variable phenotype data. This is done by making a new tab delimited datafile with three columns. The first column is the name of the samples, the second column is also the name of the samples, the third column is the size data. There is no header row. The format is the same as in Example.eigenvec which is generated in the previous step. Here, in this example the data is called Example.pheno

#Do the analysis

plink --bfile Example --pheno phenofilefinal.sh --assoc --linear --allow-no-sex --allow-extra-chr --covar Example.eigenvec --adjust --out ExampleSizeAnalysis

The key output here is: ExampleSizeAnalysis.assoc.linear.adjusted