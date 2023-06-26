#!/usr/bin/env python
# -*- coding: utf-8 -*-

def pref_command(wc):
    SRR = META.loc[wc.sample_id][config['SOURCE']]
    return SRR

rule download_bam_tcga:
    # download the files from SRA
    output:
        "results/original_fastq/{sample_id}.fastq.gz"
    conda:
        "envs/"
    params:
        cmd = pref_command
    wildcard_constraints:
        sample_id = "SRR[0-9]+"
    threads: 4
    resources:
        tmpdir = config['tmp']
    shell:
        '''
mkdir -p results
mkdir -p results/original_fastq
prefetch {params.cmd} -O runs/{wildcards.sample_id} -X 9999999999999
fastq-dump runs/{wildcards.sample_id}/{params.cmd}/{params.cmd}.sra | gzip > {output}
        '''

localrules: download_raw
rule download_raw:
    input:
        expand("results/original_fastq/{sample_id}.fastq.gz", sample_id=samples)
