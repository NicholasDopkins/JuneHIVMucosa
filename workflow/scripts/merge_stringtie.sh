# Recording the prompts used to sort and create merged stringtie files based on group
#(in the envs folder)
conda env create -n stringtie -f stringtie.yaml
conda activate stringtie
cd ../../results/stringtie
#the awk should be modified according to the colnumber and the condition wanted
cond_samples=$(cat "../../resources/RunTable_HIV_mucosal.csv" | awk -F "," '{ if ($39 =="HIV-1") print $1}')
echo $cond_samples[1]
declare sam_list=( "${cond_samples[@]/%//transcripts.gtf}" )
echo $sam_list
printf '%s\n' "${hivpos_list[@]}" > {$colnum}_{$cond}.txt
cat {$colnum}_{$cond}.txt
mkdir -p {$colnum}_{$cond}
#better use a screen -S to have it running in the background
stringtie --merge -o {$colnum}_{$cond} -G ../../resources/gencode.v38.annotation.gtf {$colnum}_{$cond}.txt
