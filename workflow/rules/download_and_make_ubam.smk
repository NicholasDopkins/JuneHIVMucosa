#!/usr/bin/env python
# -*- coding: utf-8 -*-

### Metadata needs merging. Please run the .rmd script in "scripts/Metadata Merge Pre-Snakemake.Rmd"
rule download_bam_tcga:
    # download BAM from GDC for TCGA data
    input:
        config['GDC_token']
    output:
        temp('results/original_bam/{sample_id}.bam')
    params:
        uuid = lambda wc: gdc_file.loc[wc.sample_id][config['tcga_file_id']],
        md5sum = lambda wc: gdc_file.loc[wc.sample_id]['md5']
    wildcard_constraints:
        sample_id = "TCGA\\-..\\-[A-Z]...\\-..[A-Z]"
    threads: 4
    resources:
        tmpdir = config['tmp']
    shell:
        '''
mkdir -p results
mkdir -p results/original_bam
token=$(cat {input[0]})
curl -H "X-Auth-Token: $token"\
 -o {output[0]} -s\
 https://api.gdc.cancer.gov/data/{params.uuid}
echo {params.md5sum} {output[0]} | md5sum -c -
chmod 600 {output[0]}
        '''

# Default SAM attributes cleared by RevertSam
attr_revertsam = ['NM', 'UQ', 'PG', 'MD', 'MQ', 'SA', 'MC', 'AS']
# SAM attributes output by STAR
attr_star = ['NH', 'HI', 'NM', 'MD', 'AS', 'nM', 'jM', 'jI', 'XS', 'uT']
# Additional attributes to clear
ALN_ATTRIBUTES = list(set(attr_star) - set(attr_revertsam))

rule revert_and_mark_adapters:
    """ Create unmapped BAM (uBAM) from aligned BAM
    """
    input:
        "results/original_bam/{sample_id}.bam"
    output:
        "results/ubam/{sample_id}.bam"
    wildcard_constraints:
        sample_id = "TCGA\\-..\\-[A-Z]...\\-..[A-Z]"
    conda:
        "../envs/utils.yaml"
    params:
        attr_to_clear = expand("--ATTRIBUTE_TO_CLEAR {a}", a=ALN_ATTRIBUTES),
        tmpdir = config['tmp']
    shell:
        '''
picard RevertSam\
 -I {input[0]}\
 -O {output[0]}\
 --SANITIZE true\
 --COMPRESSION_LEVEL 0\
 {params.attr_to_clear}\
 --TMP_DIR {params.tmpdir}
chmod 600 {output[0]}
        '''

localrules: make_tcga_ubams
rule make_tcga_ubams:
    input:
        expand("results/ubam/{sample_id}.bam", sample_id=tcga_samples)
