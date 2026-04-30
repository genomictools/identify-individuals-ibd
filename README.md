# identify-individuals-ibd

This workflow identifies related individuals within cohorts by:

1. Accepting cohort inputs as either `vcf` or Illumina `report`
2. Converting non-VCF inputs to VCF
3. Preparing and indexing all VCFs
4. Merging all VCFs belonging to the same cohort
5. Converting merged cohort VCFs to PLINK binary files using common variants only
6. Running `plink --genome` to calculate pairwise IBD estimates

## Input

Provide a CSV file in `params.cohorts` with the following columns:

```text
cohort,key,level,file
cohort1,sample1,vcf,/path/to/sample1.vcf.gz
cohort1,sample2,report,/path/to/sample2_report.txt
```

- `cohort`: cohort identifier used for grouping
- `key`: sample or file identifier
- `level`: `vcf` or `report`
- `file`: path to the input file

## Outputs

- `results/converted/`: report-derived VCFs
- `results/vcf/`: normalized input VCFs
- `results/merged/`: cohort-merged VCFs
- `results/plink/`: PLINK common-variant datasets
- `results/ibd/`: PLINK `.genome` IBD outputs
