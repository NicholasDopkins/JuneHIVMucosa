#! /bin/bash -l

conda activate stringtie
read -p "Enter CSV metadata path" metadata
read -p "Enter column number" colnum
read -p "Enter condition" cond
file_path="/athena/nixonlab/scratch/projects/JuneHIVMucosa/results/stringtie"
cd $file_path
cond_samples=$(cat $metadata | awk -F "," '{ if ($colnum =="{$cond}") print $1}')
echo $cond_samples
sam_list=$( "${cond_samples[@]/%//transcripts.gtf}" )
echo $sam_list
printf '%s\n' "${hivpos_list[@]}" > {$colnum}_{$cond}.txt
cat {$colnum}_{$cond}.txt
mkdir -p {$colnum}_{$cond}
srun bash -c 'stringtie --merge -o {$colnum}_{$cond} -G ../../resources/gencode.v38.annotation.gtf {$colnum}_{$cond}.txt'
