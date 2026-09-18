##################################
# CONFIG
##################################

configfile: "config.yaml"

from pathlib import Path

##################################
# FLAGS
##################################

USE_FASTP = config.get("use_fastp", True)
USE_HOST  = config.get("use_host_removal", False)
USE_REPAIR = config.get("use_repair", True)

##################################
# PATHS GLOBAIS
##################################

OUTDIR = Path(config["outdir"])
HOST_FASTA = Path(config["host_fasta"])

RAW_DIR        = OUTDIR / "dados/raw"
FASTQC_RAW_DIR   = OUTDIR / "dados/fastqc/raw"
FASTP_DIR      = OUTDIR / "dados/fastp"
FASTQC_CLEAN_DIR = OUTDIR / "dados/fastqc/clean"
HOST_DIR       = OUTDIR / "dados/host_removed"
TMP_DIR  = OUTDIR / "dados/tmp"
ASSEMBLY_DIR    = OUTDIR / "dados/megahit"
MULTIQC_DIR    = OUTDIR / "dados/multiqc"
REPAIR_DIR = OUTDIR / "dados/repair"
MAPPING_DIR  = OUTDIR / "dados/mapping"
BINNING_DIR  = OUTDIR / "dados/binning"
TIARA_DIR     = OUTDIR / "dados/tiara"
KAIJU_DIR    = OUTDIR / "dados/kaiju"
CAT_BAT_DIR = OUTDIR / "dados/cat_bat"

###########################################################
# SELEÇÃO AUTOMÁTICA DOS READS PARA SINCRONIZAÇÃO DAS READS
###########################################################
def REPAIR_INPUT_R1(wc):
    if USE_FASTP:
        return FASTP_DIR / "read_1_clean.fastq.gz"
    return RAW_DIR / "read_1.fastq.gz"

def REPAIR_INPUT_R2(wc):
    if USE_FASTP:
        return FASTP_DIR / "read_2_clean.fastq.gz"
    return RAW_DIR / "read_2.fastq.gz"

#####################################################
# SELEÇÃO AUTOMÁTICA DOS READS PARA REMOÇÃO DOS HOST 
#####################################################

def HOST_INPUT_R1(wc):
    if USE_REPAIR:
        return REPAIR_DIR / "read_1.fastq.gz"
    if USE_FASTP:
        return FASTP_DIR / "read_1_clean.fastq.gz"
    return RAW_DIR / "read_1.fastq.gz"

def HOST_INPUT_R2(wc):
    if USE_REPAIR:
        return REPAIR_DIR / "read_2.fastq.gz"
    if USE_FASTP:
        return FASTP_DIR / "read_2_clean.fastq.gz"
    return RAW_DIR / "read_2.fastq.gz"


################################################
# SELEÇÃO AUTOMÁTICA DOS READS PARA ASSEMBLY
################################################

def ASSEMBLY_INPUT_R1(wc):
    if USE_HOST:
        return HOST_DIR / "read_1.fastq.gz"
    if USE_REPAIR:
        return REPAIR_DIR / "read_1.fastq.gz"
    if USE_FASTP:
        return FASTP_DIR / "read_1_clean.fastq.gz"
    return RAW_DIR / "read_1.fastq.gz"

def ASSEMBLY_INPUT_R2(wc):
    if USE_HOST:
        return HOST_DIR / "read_2.fastq.gz"
    if USE_REPAIR:
        return REPAIR_DIR / "read_2.fastq.gz"
    if USE_FASTP:
        return FASTP_DIR / "read_2_clean.fastq.gz"
    return RAW_DIR / "read_2.fastq.gz"


################################################
# SELEÇÃO AUTOMÁTICA DOS READS PARA BINNING
################################################

def BINNING_INPUT_R1(wc):
    return ASSEMBLY_INPUT_R1(wc)

def BINNING_INPUT_R2(wc):
    return ASSEMBLY_INPUT_R2(wc)

################################################
# SELEÇÃO DOS SOFTWARES UTILIZADOS
################################################

BINNING_CFG = config.get("binning", {})
BINNING_TOOLS = BINNING_CFG.get("tools", [])

PRIMARY_BINNERS = ["metabat2", "maxbin2"]

SELECTED_PRIMARY = [
    tool for tool in BINNING_TOOLS
    if tool in PRIMARY_BINNERS
]

################################################
# ARQUIVOS DE STATUS DOS BINNERS SELECIONADOS
################################################

def selected_binning_status_files():
    return [
        BINNING_DIR / f"{tool}/status.txt"
        for tool in SELECTED_PRIMARY
    ]

################################################
# CHECKPOINT - RESULTADO DO BINNING
################################################

checkpoint binning_status:
    input:
        selected_binning_status_files()

    output:
        status = BINNING_DIR / "binning_status.txt"

    shell:
        r"""
        mkdir -p $(dirname {output.status})

        rm -f {output.status}

        for status_file in {input}; do
            tool=$(basename $(dirname "$status_file"))
            status=$(cat "$status_file")
            echo "$tool $status" >> {output.status}

        done
        """

#################################################
# Processo decisório
#################################################

def get_tiara_input(wildcards):
    checkpoint_output = checkpoints.binning_status.get().output.status

    successful = []

    with open(checkpoint_output) as f:
        for line in f:
            line = line.strip()

            if not line:
                continue

            tool, status = line.split()

            if status == "SUCCESS":
                successful.append(tool)

    if len(successful) >= 2 and "dastool" in BINNING_TOOLS:
        return BINNING_DIR / "dastool"

    if len(successful) >= 1:
        return BINNING_DIR / successful[0] 

    return ASSEMBLY_DIR / "final.contigs.fa"

##################################################
#Verificar sucesso dos binners
##################################################
def get_cat_bat_successful_binners(wildcards):

    checkpoint_output = checkpoints.binning_status.get().output.status

    successful = []

    with open(checkpoint_output) as f:
        for line in f:
            line = line.strip()

            if not line:
                continue

            tool, status = line.split()

            if status == "SUCCESS":
                successful.append(tool)

    return successful

################################################
# DECISÃO CAT OU BAT
################################################

def get_cat_bat_target(wildcards):

    successful = get_cat_bat_successful_binners(wildcards) 

    if successful:

        return CAT_BAT_DIR / "bat.contig2classification.txt"

    return CAT_BAT_DIR / "cat.contig2classification.txt"

##################################
# RULE ALL
##################################

rule all:
    input:
        ASSEMBLY_DIR / "final.contigs.fa",
        MULTIQC_DIR / "multiqc_report.html",
        TIARA_DIR / "results/tiara.out",
        get_cat_bat_target 
        


##################################
# INCLUDES
##################################

include: "rules/staging.smk"
include: "rules/qc.smk"
include: "rules/fastp.smk"
include: "rules/repair.smk"
include: "rules/host.smk"
include: "rules/kaiju.smk"
include: "rules/assembly.smk"
include: "rules/mapping.smk"
include: "rules/binning.smk"
include: "rules/prepare_tiara.smk"
include: "rules/tiara.smk"
include: "rules/prepare_input_bat.smk"
include: "rules/bat.smk"
include: "rules/cat.smk"
include: "rules/multiqc.smk"
