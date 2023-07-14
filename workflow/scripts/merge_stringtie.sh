#! /bin/bash -l
#SBATCH --partition=panda
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --job-name=StringTieMerge
#SBATCH --time=20:00:00 #HH/MM/SS
#SBATCH --mem=50G

conda activate stringtie
read -p "Enter CSV metadata path" metadata
read -p "Enter column number" colnum
read -p "Enter condition" cond
file_path="/athena/nixonlab/scratch/projects/JuneHIVMucosa/results/stringtie"
cd $file_path
cond_samples=$(cat $metadata | awk -F "," '{ if ($colnum =="{$cond}") print $1}')
sam_list = ( "${cond_samples[@]/%//transcripts.gtf}" )
printf '%s\n' "${hivpos_list[@]}" > {$colnum}_{$cond}.txt
cat {$colnum}_{$cond}.txt
mkdir -p {$colnum}_{$cond}
stringtie --merge -o {$colnum}_{$cond} -G ../../resources/gencode.v38.annotation.gtf {$colnum}_{$cond}.txt
