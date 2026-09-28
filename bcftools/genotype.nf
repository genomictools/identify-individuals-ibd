process GENOTYPE {
    tag "${cohort}:${key}:${type}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/vcf", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(type),
          path(file)

    output:
    tuple val(cohort), val(key), val("vcf"),
          path("${cohort}.${key}.vcf.gz{,.tbi}")

    script:
    """
    #!/bin/bash
    set -euo pipefail

    # Prepare illumina manifest and sample sheet for conversion
    awk -F',' -v snp_name="${params.snp_name},Name" -v chr="${params.chr}" -f ${projectDir}/bin/extract_manifest_snps.awk ${file(params.manifest)} | sort -u > manifest_snp_names.txt
    awk -F'\t' -v sample_id="${key}" -v snp_name="${params.snp_name}" -v chr="${params.chr}" -v position="${params.position}" -v allele_ab_a="${params.allele_ab_a}" -v allele_ab_b="${params.allele_ab_b}" -v allele_a="${params.allele_a}" -v allele_b="${params.allele_b}" -f ${projectDir}/bin/convert_report_to_matrix.awk ${file} > gtc2vcf_input.tsv

    awk 'NR==FNR { keep[\$1]=1; next }
         FNR==1 { print; next }
         (\$1 in keep) { print }
    ' manifest_snp_names.txt gtc2vcf_input.tsv > gtc2vcf_input.filtered.tsv

    awk -f ${projectDir}/bin/update_positions_from_pfb.awk ${file(params.pfb)} gtc2vcf_input.filtered.tsv > gtc2vcf_input.position_updated.tsv

    # Convert to VCF using bcftools plugin       
    bcftools +gtc2vcf \
        --genome-studio gtc2vcf_input.position_updated.tsv \
        --fasta-ref ${file(params.fasta)} \
        --csv ${file(params.manifest)} | \
    awk 'BEGIN { FS=OFS="\t" }
         /^#/ { print; next }
         { gsub(/[\001-\010\013\014\016-\037\177]/, "", \$0); sub(/^GSA-/, "", \$3); print }
    ' | \
    bcftools sort -Oz --output ${cohort}.${key}.vcf.gz

    bcftools index -t ${cohort}.${key}.vcf.gz
    """
}


