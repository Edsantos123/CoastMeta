# CoastMeta

**CoastMeta** is a computational workflow for coastal environmental metagenomics, designed to support the analysis of microbial communities and the generation of data products for ecological monitoring of coastal ecosystems.

The project is being developed as a modular and reproducible workflow based on **Snakemake** and **Docker**, integrating multiple tools for quality control, preprocessing, assembly, binning, taxonomic classification, and downstream metagenomic analyses.

> **Project status:** CoastMeta is currently under development. Some components of the workflow are implemented and being tested, while additional functional annotation and visualization modules are planned.

---

## Objectives

The main objective of CoastMeta is to facilitate the processing and analysis of environmental metagenomic data from coastal ecosystems through a reproducible computational workflow.

The project aims to:

* Automate common steps in environmental metagenomic analysis;
* Integrate quality control, preprocessing, assembly, binning, and taxonomic classification;
* Support functional annotation of metagenomic data;
* Generate structured outputs for ecological interpretation and environmental monitoring;
* Facilitate reproducible analyses through containerized software;
* Provide a modular framework that can be expanded with additional tools and analytical modules.

---

## Workflow

The current workflow is organized into modular stages:

```text
Raw reads
    │
    ▼
Quality control
    │
    ▼
Read preprocessing
    │
    ▼
Assembly
    │
    ▼
Read mapping
    │
    ▼
Genome binning
    │
    ├── MetaBAT2
    ├── MaxBin2
    └── DAS Tool
    │
    ▼
Bin refinement / classification
    │
    └── Tiara
    │
    ▼
Taxonomic classification
    │
    ├── CAT/BAT
    └── Kaiju
    │
    ▼
Functional annotation
    │
    ├── Prokka
    ├── eggNOG-mapper
    ├── DeepARG
    └── Eukulele
    │
    ▼
Ecological interpretation
    │
    └── Environmental monitoring
```

Some stages shown above are planned or currently being integrated.

---

## Main tools

| Stage                           | Tools                 |
| ------------------------------- | --------------------- |
| Quality control                 | FastQC, MultiQC       |
| Read preprocessing              | fastp, BBTools        |
| Read repair                     | BBTools               |
| Host removal                    | BWA, Samtools         |
| Assembly                        | MEGAHIT               |
| Read mapping                    | BWA, Samtools         |
| Genome binning                  | MetaBAT2, MaxBin2     |
| Bin refinement                  | DAS Tool              |
| Domain/organelle classification | Tiara                 |
| Taxonomic classification        | CAT/BAT, Kaiju        |
| Functional annotation           | Prokka, eggNOG-mapper |
| Additional functional analyses  | DeepARG, Eukulele     |
| Workflow management             | Snakemake             |
| Software environments           | Docker                |

---

## Repository structure

```text
CoastMeta/
├── images/
│   ├── Dockerfile_fastqc
│   ├── Dockerfile_fastp
│   ├── Dockerfile_megahit
│   ├── Dockerfile_metabat2
│   ├── Dockerfile_maxbin2
│   ├── Dockerfile_dastool
│   ├── Dockerfile_tiara
│   ├── Dockerfile_cat_bat
│   ├── Dockerfile_kaiju
│   └── ...
│
├── rules/
│   ├── qc.smk
│   ├── fastp.smk
│   ├── assembly.smk
│   ├── mapping.smk
│   ├── binning.smk
│   ├── metabat2.smk
│   ├── maxbin2.smk
│   ├── dastool.smk
│   ├── tiara.smk
│   ├── cat.smk
│   ├── kaiju.smk
│   └── ...
│
├── orquestrador.smk
├── config.yaml
├── .gitignore
└── README.md
```

The `rules/` directory contains the individual Snakemake modules, while `images/` contains the Dockerfiles used to build the software environments.

---

## Reproducibility

CoastMeta uses **Docker** to isolate software dependencies and **Snakemake** to organize and execute the analysis workflow.

This approach aims to improve:

* Reproducibility;
* Dependency management;
* Workflow organization;
* Portability across computational environments;
* Modularity of the analysis pipeline.

---

## Environmental monitoring applications

CoastMeta is being designed with applications in the monitoring of coastal ecosystems, including environments such as **mangroves and restingas**.

Potential analytical targets include:

* Microbial community composition;
* Taxonomic diversity;
* Functional potential;
* Microorganisms associated with biogeochemical cycles;
* Organic matter degradation;
* Nitrogen, carbon, and sulfur cycling;
* Antibiotic resistance genes (ARGs);
* Potential ecological indicators and bioindicators.

The interpretation of these outputs is intended to support ecological monitoring rather than replace conventional environmental assessments.

---

## Input data

CoastMeta is designed to process paired-end metagenomic sequencing data.

Example:

```text
sample_R1.fastq.gz
sample_R2.fastq.gz
```

Reference databases required by individual tools are not included in this repository.

Large sequencing datasets, databases, intermediate files, and workflow outputs are excluded from version control through `.gitignore`.

---

## Running the workflow

The workflow is currently under development, and execution parameters may change as new modules are integrated.

A typical execution using Snakemake is:

```bash
snakemake -s orquestrador.smk --cores 4
```

Configuration parameters are provided through:

```text
config.yaml
```

Before running CoastMeta, the required Docker images and reference databases must be available and correctly configured.

---

## Citation

If you use CoastMeta in your research, please cite the project repository:

Powell, E. CoastMeta: A computational workflow for coastal environmental metagenomics. GitHub repository. Available at: https://github.com/Edsantos123/CoastMeta

---

## License

CoastMeta is released under the MIT License. See the LICENSE file for the full license text.

---

## Acknowledgements

This project is being developed as part of research and development activities involving environmental metagenomics and computational approaches for ecological monitoring of coastal ecosystems.
