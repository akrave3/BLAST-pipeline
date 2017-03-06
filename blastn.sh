#!/bin/bash
source blastn.cfg
#parse tool parameters from blastn.cfg

eval $(grep "^Fastx=" blastn.cfg)
eval $(grep "^Samtools=" blastn.cfg)
eval $(grep "^Blast=" blastn.cfg)
eval $(grep "^PATH_input=" blastn.cfg)

#parse quality parameters from blastn.cfg
eval $(grep "^QualityScore=" blastn.cfg)
eval $(grep "^PercentImplemented=" blastn.cfg)

#input

Input=$1
InputGenome=$2

echo "Filtering..."

$Fastx/fastq_quality_filter -Q33 -q $QualityScore -p $PercentImplemented -i $Input  -o QualityFiltered.fastq

echo "The reads have been filtered."
echo "Trimming..."

$Fastx/fastq_quality_trimmer -Q33 -t 20 -l $TrimLength -i QualityFiltered.fastq -o Trimmed.fastq -v

print"The reads have been trimmed."

$Fastx/fastx/fastq_to_fasta -i Trimmed.fastq -o BlastPipe.fasta

echo "The quality of the query has been secured." 
echo "Blasting..."

$Blast/makeblastdb -in BlastPipe.fasta -input_type fasta -dbtype $DbType -out {$InputGenome}.db

echo -e "Input BlastN command line"

$Blast/blastn -db {$InputGenome}.db -query BlastPipe.fasta -outfmt $Outfmt -out MappedReads.fasta -perc_identity $Perc_identity

awk '{FS= " "} ; {print $1}'  > MappedReads.fasta

xargs $Samtools/samtools faidx BlastPipe.fasta < MappedReads.fasta > ReadIdsIndex.fa 
