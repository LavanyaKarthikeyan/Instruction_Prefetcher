#!/bin/bash
echo "Starting Regression Run ..." ;
start=`date +%s`;
count=50;
for trace in ipc1_public/spec*; 
do 
    ./run_champsim.sh hashed_perceptron-FNL-MMA280520-next_line-spp_dev-no-lru-1core 50 50 ${trace##*/} &   
    
done
wait

for trace in ipc1_public/server*; 
do 
    ./run_champsim.sh hashed_perceptron-FNL-MMA280520-next_line-spp_dev-no-lru-1core 50 50 ${trace##*/} &   
    
done
wait

for trace in ipc1_public/client*; 
do 
    ./run_champsim.sh hashed_perceptron-FNL-MMA280520-next_line-spp_dev-no-lru-1core 50 50 ${trace##*/} &   
    
done
wait



end=`date +%s`;
runtime=$((end-start)) ;
echo "Simulation Run Over. Time: $runtime" ;
 
log_csv=./results_50M/FNL-016kb-main_log_file.csv;
`rm -rf $log_csv` ;
`echo "TRACE,IPC,INSTRUCTIONS,CYCLES,L1I_MISS_LATENCY,L1I_ACCESS,L1I_MISS,L2C_ACCESS,L1I_LOAD_MISS,L1I_LOAD_ACCESS,L1I_PREFETCH_REQ,L1I_PREFETCH_USEFUL,L1I_PREFETCH_USELESS" >> $log_csv`;
# `echo "\n" >> $log_csv`;
for results in results_50M/*.xz-hashed_perceptron-FNL-MMA280520-next_line-spp_dev-no-lru-1core_016kb.txt ;
do 
    
    PERF=`grep -r $results -e "CPU 0 cumulative IPC"`;
    
    if [[ $PERF =~ IPC\:([^\i]+) ]] ;  then 
        IPC="${BASH_REMATCH[1]}"      
    fi
    if [[ $PERF =~ instructions\:([^\c]+) ]] ;  then 
        INSTRUCTIONS="${BASH_REMATCH[1]}"      
    fi
    if [[ $PERF =~ cycles\:([^\n]+) ]] ;  then 
        CYCLES="${BASH_REMATCH[1]}"      
    fi
 
    L1I_latency=`grep -r $results -e "L1I AVERAGE MISS LATENCY"`;
    if [[ $L1I_latency =~ LATENCY\:([^\c]+) ]] ;  then 
        L1I_latency="${BASH_REMATCH[1]}"      
    fi

    L1I_total=`grep -r $results -e "L1I TOTAL"` ;
    if [[ $L1I_total =~ ACCESS\:([^\H]+) ]] ;  then 
        L1I_ACCESS="${BASH_REMATCH[1]}"      
    fi
    if [[ $L1I_total =~ MISS\:([^\n]+) ]] ;  then 
        L1I_MISS="${BASH_REMATCH[1]}"      
    fi

    L1I_load=`grep -r $results -e "L1I LOAD"` ;
    if [[ $L1I_load =~ ACCESS\:([^\H]+) ]] ;  then 
        L1I_LOAD_ACCESS="${BASH_REMATCH[1]}"      
    fi
    if [[ $L1I_load =~ MISS\:([^\n]+) ]] ;  then 
        L1I_LOAD_MISS="${BASH_REMATCH[1]}"      
    fi

    
   
    L1I_PREFETCH_REQ=`grep -r $results -e "L1I PREFETCH  REQUESTED" | cut '-d:' '-f2' | xargs | cut '-d ' '-f1'` ;
    L1I_PREFETCH_USEFUL=`grep -r $results -e "L1I PREFETCH  REQUESTED" | cut '-d:' '-f4' | xargs | cut '-d ' '-f1'` ;
    L1I_PREFETCH_USELESS=`grep -r $results -e "L1I PREFETCH  REQUESTED" | cut '-d:' '-f5' | xargs ` ;
    L2C_ACCESS=`grep -r $results -e "L2C TOTAL" | cut '-d:' '-f2' | xargs | cut '-d ' '-f1'` ;
   

    results=${results##*/}
    echo "${results%%.*},$IPC,$INSTRUCTIONS,$CYCLES,$L1I_latency,$L1I_ACCESS,$L1I_MISS,$L2C_ACCESS,$L1I_LOAD_MISS,$L1I_LOAD_ACCESS,$L1I_PREFETCH_REQ,$L1I_PREFETCH_USEFUL,$L1I_PREFETCH_USELESS" >> $log_csv;


done
