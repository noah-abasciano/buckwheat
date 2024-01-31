#!/bin/bash

#Set working directory and output directory
cd $1

#GBS-SNP-CROP Step 1:
# Parsing Paired-End (PE) reads:
echo "Begin parsing reads..."
perl /path_to_GBS-SNP-CROP/GBS-SNP-CROP-1.pl -d PE -b BarcodeID.txt -fq FileNameSeed -s 1 -e 20 -enz1 TGCA -enz2 CGG -t 10
echo "Step 1 complete."

#GBS-SNP-CROP Step 2:
# Trimming Paired-End (PE) reads:
echo "Begin trimming reads..."
perl GBS-SNP-CROP-2.pl -tm /usr/local/bin/trimmomatic-0.39.jar -d PE -fq FileNameSeed -t 10 -ph 33 -ad TruSeq3-PE.fa:2:30:10 -l 30 -sl 4:30 -tr 30 -m 32
echo "Step 2 complete."

#GBS-SNP-CROP Step 3:
# Demultiplexing Paired-End (PE) reads:
echo "Begin demultiplexing..."
perl GBS-SNP-CROP-3.pl -d PE -b BarcodeID.txt -fq FileNameSeed
echo "Step 3 complete."

#GBS-SNP-CROP Step 4:
#Cluster reads and assemble Mock Reference Paired-End (PE) reads:
echo "Begin assembling mock reference..."
perl GBS-SNP-CROP-4.pl -pr /usr/local/bin/pear -vs /usr/local/bin/vsearch -d PE -b BarcodeID.txt -rl 150 -p 0.01 -pl 32 -t 10 -cl consout -id 0.93 -db 1 -min 32 -MR GSC.MR
echo "Step 4 complete."

#GBS-SNP-CROP Step 5:
#Align with BWA-mem and process with SAMtools Paired-End (PE) reads:
echo "Begin aligning sequences..."
perl GBS-SNP-CROP-5.pl -bw /usr/local/bin/bwa -st /usr/local/bin/samtools -d PE -b BarcodeID.txt -ref GSC.MR.Genome.fa -Q 30 -q 0 -F 2308 -f 2 -t 10 -opt "-m1 -s156"
echo "Step 5 complete."

#GBS-SNP-CROP Step 6:
# Identifying SNPs only:
echo "Begin parsing mpileup ourputs..."
perl GBS-SNP-CROP-6.pl -b BarcodeID.txt -out GSC.MasterMatrix.txt -t 10 
echo "Step 6 complete."

#GBS-SNP-CROP Step 7:
# Calling SNPs only:
echo "Begin filtering variants..."
perl GBS-SNP-CROP-7.pl -in GSC.MasterMatrix.txt -out GSC.GenoMatrix.txt -mnHoDepth0 5 -mnHoDepth1 20 -mnHetDepth 3 -altStrength 0.8 -mnAlleleRatio 0.25 -mnCall 0.75 -mnAvgDepth 3 -mxAvgDepth 200
echo "Step 7 complete."

