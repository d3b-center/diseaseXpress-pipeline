.. |date| date::

******************************
DiseaseXpress RNA-seq Pipeline
******************************

:authors: Komal Rathi, Pichai Raman
:contact: rathik@email.chop.edu
:organization: DBHi, CHOP
:status: This is "work in progress"
:date: |date|

.. meta::
   :keywords: scripts, DiseaseXpress, 2017
   :description: DiseaseXpress rnaseq processing scripts.

Installation
############

Install all software using conda. Depending on your system, you might have to install other pre-requisites.

.. code-block:: bash

	conda create --name rnaseq-env
	source activate rnaseq-env
	conda install -c biobuilds sra-tools=2.5.6
	conda install -c bioconda rsem=1.2.28
	conda install -c bioconda star=2.5.2b

	# R packages to install
	GEOquery
	SRAdb
	DBI

	# Other tools required for faster downloads
	EDirect: https://www.ncbi.nlm.nih.gov/books/NBK179288/
	aspera ascp client: http://downloads.asperasoft.com/en/downloads/50


Pipeline
########


Create Genome Index for STAR and RSEM:
""""""""""""""""""""""""""""""""""""""

.. code-block:: bash

	# This is to be done just once per genome build (hg19, hg38, mm10 etc). 
	snakemake -p -s Snakefile_genome --config freeze=hg19


Get raw fastq files and create a directory structure:
"""""""""""""""""""""""""""""""""""""""""""""""""""""

.. code-block:: bash

	# provide either GEO accession or SRA study ID
	Rscript getSRA.R SRP033200
	Rscript getSRA.R GSE52564

This will create a directory structure like this:

.. code-block:: bash

	# Output directory structure for GSE2564: 

	tree -L /mnt/rnaseq/data/raw/GSE52564/

	├── bam
	│   ├── SRR1033783_Aligned.toTranscriptome.out.bam
	│   ├── SRR1033783_Log.final.out
	│   ├── SRR1033783_Log.out
	│   ├── SRR1033783_Log.progress.out
	│   ├── SRR1033783_SJ.out.tab
	├── fastq
	│   ├── SRR1033783_1.fastq.gz
	│   ├── SRR1033783_2.fastq.gz
	├── quant
	│   ├── SRR1033783.genes.results
	│   ├── SRR1033783.isoforms.results
	│   ├── SRR1033783.stat
	│   │   ├── SRR1033783.cnt
	│   │   ├── SRR1033783.model
	│   │   └── SRR1033783.theta
	└── sra
	    |── SRR1033783.sra

Run snakemake
"""""""""""""

Then run snakemake with three parameters: 

1. -f or --freeze. The genome build (e.g. mm10, hg19 or hg38).
2. -s or --sourcedir. The source directory which is path to the project directory. 
3. -p or --paired. TRUE or FALSE for paired or single-ended reads.

.. code-block:: bash

	# E.g. to process data in /mnt/rnaseq/data/raw/GSE57945
	source activate rnaseq-env
	bash run_snakemake.sh -f=hg38 -s=/mnt/rnaseq/data/raw/GSE57945/ -p=FALSE 


