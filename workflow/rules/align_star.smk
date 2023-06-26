#! /usr/bin/env python
# -*- coding: utf-8 -*-

rule star_align_multi:
    input:
        fastq = 'results/original_fastq/{sample_id}.fastq.gz',
        genomeDir = config['star_align_multi']['genomeDir']
    output:
        "results/align_multi/{sample_id}/Aligned.out.bam",
        "results/align_multi/{sample_id}/ReadsPerGene.out.tab",
        "results/align_multi/{sample_id}/Log.final.out",
        "results/align_multi/{sample_id}/SJ.out.tab"
    conda:
        "../envs/star.yaml"
    threads: snakemake.utils.available_cpu_count()
    shell:
        '''
tdir=$(mktemp -d {config[tmp]}/{rule}.{wildcards.sample_id}.XXXXXX)  

STAR\
  --runThreadN {threads}\
  --genomeDir {input.genomeDir}\
  --readFilesIn {input.fastq}\
  --outSAMattributes NH HI NM MD AS XS\
  --outSAMtype BAM Unsorted\
  --outFileNamePrefix $(dirname {output[0]})/\
  --quantMode GeneCounts\
  --readFilesCommand zcat\
  --outSAMstrandField intronMotif\
  --outFilterMultimapNmax {config[star_align_multi][outFilterMultimapNmax]}\
  --winAnchorMultimapNmax {config[star_align_multi][winAnchorMultimapNmax]}\
  --outSAMunmapped Within KeepPairs

rm -rf $tdir
        '''

rule samtools_bam_cram:
    input:
        bam = "results/align_multi/{sample_id}/Aligned.out.bam",
        ref = config['genome_fasta']
    output:
        "results/align_multi/{sample_id}/Aligned.out.cram",
    conda:
        "../envs/utils.yaml"
    threads: 2
    shell:
        '''
samtools view -C -T {input.ref} {input.bam} > {output[0]}
        '''


