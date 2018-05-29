#!/bin/bash

################################################################################################################################
#
# Trim input sequences using Cutadapt. Part of the MayomicsVC Workflow.
# 
# Usage:
# trim_sequences.sh <adapters.fa> <read1.fq> <read2.fq> <output_directory> </path/to/cutadapt> <threads> </path/to/error_log>
#
################################################################################################################################

## Input and Output parameters with getopts

while getopts ":hs:r:R:A:O:C:t:SE:e:d:" OPT
do
	case ${OPT} in
		h )  # Flag to display usage
			echo " "
			echo "Usage:"
			echo " "
			echo "	bash trim_sequences.sh -h	Display this help message."
			echo "	bash trim_sequences.sh [-s sample_name] [-r <read1.fq>] [-R <read2.fq>] [-A <adapters.fa>] [-O </path/to/output_directory>] [-C </path/to/cutadapt_directory>] [-t threads] [-SE single_end? (true/false)] [-e <error_log>] "
			echo " "
			exit 0;
			;;
		s )  # Sample name. String variable invoked with -s
			SAMPLE=${OPTARG}
			echo ${SAMPLE}
			;;
		r )  # Full path to input read 1. String variable invoked with -r
			INPUT1=${OPTARG}
			echo ${INPUT1}
			;;
		R )  # Full path to input read 2. String variable invoked with -r
			INPUT2=${OPTARG}
			echo ${INPUT2}
			;;
		A )  # Full path to adapters fasta file. String variable invoked with -A
			ADAPTERS=${OPTARG}
			echo ${ADAPTERS}
			;;
		O )  # Output directory. String variable invoked with -O
			OUTDIR=${OPTARG}
			echo ${OUTDIR}
			;;
		C )  # Full path to cutadapt directory. String variable invoked with -C
			CUTADAPT=${OPTARG}
			echo ${CUTADAPT}
			;;
		t )  # Number of threads available. Integer invoked with -t
			THR=${OPTARG}
			echo ${THR}
			;;
		SE )  # Is this a single-end process? Boolean variable [true/false] invoked with -SE
			IS_SINGLE_END=${OPTARG}
			echo ${IS_SINGLE_END}
			;;
		e )  # Full path to error log file. String variable invoked with -e
			ERRLOG=${OPTARG}
			echo ${ERRLOG}
			;;
		d )  # Turn on debug mode. Boolean variable [true/false] which initiates 'set -x' to print all text
			DEBUG=${OPTARG}
			echo ${DEBUG}
			;;
	esac
done

## Turn on Debug Mode to print all code
if [[ ${DEBUG} == true ]]
then
	set -x
fi

SCRIPT_NAME=trim_sequences.sh

## Check if input files, directories, and variables are non-zero
if [[ ! -s ${ADAPTERS} ]]  
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Adapters fasta file ${ADAPTERS} is empty." >> ${ERRLOG} 
	exit 1;
fi
if [[ ! -s ${INPUT1} ]]  
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Input read 1 file ${INPUT1} is empty." >> ${ERRLOG}
	exit 1;
fi
if [[ ${IS_SINGLE_END} == false ]]
then
        if [[ ! -s ${INPUT2} ]]
        then
                echo -e "$0 stopped at line $LINENO. \nREASON=Input read 2 file ${INPUT2} is empty." >> ${ERRLOG}
                exit 1;
        fi
fi
if [[ ! -d ${OUTDIR} ]]
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Output directory ${OUTDIR} does not exist." >> ${ERRLOG}
	exit 1;
fi
if [[ ! -d ${CUTADAPT} ]]
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Cutadapt directory ${CUTADAPT} does not exist." >> ${ERRLOG}
	exit 1;
fi
if (( ${THR} % 2 != 0 ))  ## This is checking if the number of threads is an odd number. If that is the case, we subtract 1 from the integer so the parallel processes can run on equal threads.
then
	THR=$((THR-1))
fi
if [[ ! -f ${ERRLOG} ]]
then
	echo -e "$0 stopped at line $LINENO. \nREASON=Error log file ${ERRLOG} does not exist." >> ${ERRLOG}
	exit 1;
fi

## Parse filename without full path

full1=$INPUT1
full2=$INPUT2
READ1=${full1##*/} # Remove path from variable
READ2=${full2##*/}
read1=${READ1%%.*} # Remove all instances of .* suffixes
read2=${READ2%%.*}
OUT=${OUTDIR}/${SAMPLE}.trimmed.fq.gz
OUT1=${OUTDIR}/${SAMPLE}.read1.trimmed.fq.gz
OUT2=${OUTDIR}/${SAMPLE}.read2.trimmed.fq.gz

## Record start time
START_TIME=`date "+%m-%d-%Y %H:%M:%S"`
echo "[CUTADAPT] START. ${START_TIME}"

## Cutadapt command, run for each fastq and each adapter sequence in the adapter FASTA file.
## Allocates half of the available threads to each process.
if [[ "$IS_SINGLE_END" = true ]]
then
	${CUTADAPT}/cutadapt -a file:${ADAPTERS} --cores=${THR} -o ${OUT} ${INPUT1} >> ${SAMPLE}.cutadapt.log &
	wait
else 
	if [[ $THR = 0 ]]
	then
		${CUTADAPT}/cutadapt -a file:${ADAPTERS} -o ${OUT1} ${INPUT1} >> ${read1}.cutadapt.log &
		${CUTADAPT}/cutadapt -a file:${ADAPTERS} -o ${OUT2} ${INPUT2} >> ${read2}.cutadapt.log &
		wait
	else
		${CUTADAPT}/cutadapt -a file:${ADAPTERS} --cores=$((THR/2)) -o ${OUT1} ${INPUT1} >> ${read1}.cutadapt.log &
		${CUTADAPT}/cutadapt -a file:${ADAPTERS} --cores=$((THR/2)) -o ${OUT2} ${INPUT2} >> ${read2}.cutadapt.log &
		wait
	fi
fi
echo "[CUTADAPT] Trimmed adapters in ${ADAPTERS} from input sequences. CUTADAPT logs: ${OUT}/${read1}.cutadapt.log ${OUT}/${read2}.cutadapt.log"

## Record end of the program execution
END_TIME=`date "+%m-%d-%Y %H:%M:%S"`

## Open read permissions to the user group
if [[ "$IS_SINGLE_END" = true ]]
then
	chmod g+r ${OUT}
else
	chmod g+r ${OUT1}
	chmod g+r ${OUT2}
fi

echo "[CUTADAPT] Finished trimming adapter sequences. Trimmed reads found at ${OUTDIR}/. ${END_TIME}"
