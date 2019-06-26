source activate rnaseq-env
snakemake -p -s Snakefile_genome --config freeze=hg19
snakemake -p -s Snakefile_genome --config freeze=hg38
