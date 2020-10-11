# nibSV

## Please cite our work -- here is the ICMJE Standard Citation:

### ...and a link to the DOI:

## Awesome Logo

### You can make a free DOI with zenodo <link>

## Website (if applicable)

## Intro statement
Structural variation (SV) are the largest source of genetic variation within the human population. Long read DNA sequencing is becoming the preferred method for discovering structural variants. Structural variation can be longer than a short-read (<500bp) DNA trace, meaning the SV allele is not contained, which causes challanges and problems in the detection. Nevertheless, short reads are the way to go to obtain robust allele frequencies accross a population.

## What's the problem?
These long differences in DNA are harder to detect computationally, due to alignment, and sequence context. Pacifiic Biosciences HiFi reads are long (~10-20kb) and accurate (phred QV > 20). HiFi reads have the ability to identify a wide range of SV because they encapsulate the SV length spectrum. There are a number of good software tools to detect structural variants in HiFi data: Sniffles, PBSV, and others. Using these SV calls as priors we are going to identify kmers that can be used as SV specific markers. Building a database of SV specific kmers will allow us to integrate the large number of short-read datasets.

## Why should we solve it?

Who doesnt like to nibble on SV 
# What is <this software>?

Overview Diagram

# How to use <this software>

# Software Workflow Diagram
Rough workflow  (Eric D):

1. Parse a SV VCF file 
   Reconstitute alleles (adding flank to deletions and insertions)
   Build map/hash/set/vector of kmers that are present in SVs (SVnibs)
2. Parse human reference genome generating another set of kmers (Brent)
3. Remove SVnibs that are in the human reference genome. We cannot quickly type those SVs that are reference derived. This will remove many of the insertions: Alu’s lines ect. 
4. Type. In this stage we will go through novel/new genomes and see if they contain the SVnibs. Account for frequency, and depth. 

How to make this rapid?

Update VCF?

# File structure diagram 
#### _Define paths, variable names, etc_

# Installation options:

We provide two options for installing <this software>: Docker or directly from Github.

### Docker

The Docker image contains <this software> as well as a webserver and FTP server in case you want to deploy the FTP server. It does also contain a web server for testing the <this software> main website (but should only be used for debug purposes).

1. `docker pull ncbihackathons/<this software>` command to pull the image from the DockerHub
2. `docker run ncbihackathons/<this software>` Run the docker image from the master shell script
3. Edit the configuration files as below

### Installing <this software> from Github

1. `git clone https://github.com/NCBI-Hackathons/<this software>.git`
2. Edit the configuration files as below
3. `sh server/<this software>.sh` to test
4. Add cron job as required (to execute <this software>.sh script)

### Configuration

```Examples here```

# Testing

We tested four different tools with <this software>. They can be found in [server/tools/](server/tools/) . 

# Additional Functionality

### DockerFile

<this software> comes with a Dockerfile which can be used to build the Docker image.

  1. `git clone https://github.com/NCBI-Hackathons/<this software>.git`
  2. `cd server`
  3. `docker build --rm -t <this software>/<this software> .`
  4. `docker run -t -i <this software>/<this software>`
  
### Website

There is also a Docker image for hosting the main website. This should only be used for debug purposes.

  1. `git clone https://github.com/NCBI-Hackathons/<this software>.git`
  2. `cd Website`
  3. `docker build --rm -t <this software>/website .`
  4. `docker run -t -i <this software>/website`
  
