#!/bin/bash
#
# NomthandazoNsingo_download_Chr.21.sh
#
#===================================================
# Author Nomthandazo Nsingo
#---------------------------------------------------
# Version1 September 2026 
# Description:
#Extract relevant data from an NCBI sequence file
#                   1. Create and navigate through the btec_640 and class_exercises directories using best practices (mkdir, cd, pwd
#                   2. Create Antigen directory within class_exercises, with separate input_file and analysis directories.
#                   3. Download and decompress the human genome annotation GTF file containing data for all chromosomes (curl -o, gunzip).
#                   4. Filter the annotation file to obtain only chromosome 21 data (grep, awk).
#                   5.Extract gene names and accession numbers for chromosome 21.
#                   6.Select 20 genes and download their corresponding sequences from NCBI using a single loop.
#                   7. Create, organize, and document the Bash script containing the commands used.

 mkdir btec_640 #make new directory
 mkdir btec-640 #make new directory under the current directory (made by mistake)
mkdir Class-exercise # make new directory under the current directory(btec-640)
cd btec_640/Class_exercises # move from btec-_640 directory to Class_exercise directory
 mkdir Antigen # make a new directory under Class_exercise directory
mkdir Input_data # make a new directory under Antigen directory
 mkdir -p Antigen/analysis # under Antigen directory, make a new directory called analysis
cd Antigen/input_data/ # move from Antigen directory to Input_data directory

# Download the chromosome 21 file from NCBI 

curl -o hg38.ncbiRefSeq.gtf.gz "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf.gz" #downloading NCBI file using curl command

# Unzip the file downloaded
gunzip hg38.ncbiRefSeq.gtf.gz # Unzip the data into a gtf file
 
# soft link of the unzipped file
ln -s ../input_data/hg38.ncbiRefSeq.gtf #making a soft link of the unzipped file

 # Extracting the names and accession numbers from all the protein-coding genes of chromosome 21 in humans
 grep "chr21" hg38.ncbiRefSeq.gtf #Extracting all lines that contains chr21

 #  Counting line  for a GTF file
  grep -c "chr21" hg38.ncbiRefSeq.gtf # To count lines that contains chr21

  # To save chr21 into a new file
   grep "chr21" hg38.ncbiRefSeq.gtf > chr21.gtf # saving  in a new file named: **chr21.gtf**

    # Extract only the gene name and accession numbers for protein-coding genes.
  grep "NM_" chr21.gtf > refseq_chr21.gtf # search chr21.gtf for all lines containing NM_ and save those lines into a new file called refseq_chr21.gtf 

  # Filtering the fields or columns in the gtf files 
  awk -F '\t' '{print $9}' refseq_chr21.gtf | head # Take refseq_chr21.gtf, split each line into tab-separated columns, extract column 9, and show the first 10 results
  #awk -F'DELIMITER' 'CONDITION{FIELDS}' FILENAME `awk` is for pattern scanning. `-F` is a flag that sets the delimiter used to split each line into fields. Default is whitespace; here our file is tab-separated, so `-F'\t'`. `CONDITION` is checked on every line. If it's true, the line prints. FIELDS are referred to as `$1`, `$2`, `$3`... (`$1` = first column, etc.)
  awk -F '\t' '{print $9}' refseq_chr21.gtf | awk -F '"' '{print $2, $4}' | head # xtract column 9 from the GTF file, then extract specific pieces of information from that column using quotation marks, and display the first 10 results.
  awk -F '\t' '{print $9}' refseq_chr21.gtf  | awk -F'"' '!seen[$2]++ {print $2, $4}' refseq_chr21.gtf > gene_accession.txt # Extract the annotation column (column 9), identify unique gene names, extract the corresponding accession information, and save the results in gene_accession.txt
  
  #Analyzing if data is selected properly
  wc -l gene_accession.txt # means count the number of lines in gene_accession.txt
head gene_accession.txt # means show the first 10 lines of gene_accession.txt
 
 # Download the sequence of 10 genes.
 #Let's pick the first 10 genes to get their corresponding fasta sequences. For this we will use `head`
 head -n 10 gene_accession.txt > 10_genes.txt # This means take the first 10 lines from gene_accession.txt and save them into a new file called 10_genes.txt
cat 10_genes.txt # means display the entire contents of 10_genes.txt in the terminal

#To loop over the gene list and download each one

# `if [ CONDITION ]` checks something. Note the required spaces inside the brackets: `[ CONDITION ]`, not `[CONDITION]`.
# `then` starts what happens if the condition is true.
# `else` (optional) is what happens if it's false.
# `fi` closes the `if` block (it's "if" spelled backwards — bash's convention for closing block keywords).
# `[ -s "$file" ]` is a specific, common condition: "does this file exist **and** is it non-empty" — exactly what you want to check right after a download.
#
#Full loop
while read -r gene accession
do
    curl -o "${gene}.fasta" "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${accession}&rettype=fasta&retmode=text"

done < 10_genes.txt # read each gene/accession pair from 10_genes.txt, use the accession number to retrieve its nucleotide sequence from NCBI, and save each sequence as a separate FASTA file named after the gene.
#Check the results
ls -l *.fasta #list the line on my fasta
