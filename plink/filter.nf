process FILTER {
    tag "${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/filtered", mode: 'copy')

    input:
    tuple val(cohort),
          path(bim), path(bed), path(fam), path(log),
	      val(n_samples), val(n_variants)

    output:
    tuple val(cohort),
          path("${cohort}.filtered.bim"),
          path("${cohort}.filtered.bed"),
          path("${cohort}.filtered.fam"),
          path("${cohort}.filtered.log"),
	      env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    plink \
		--make-bed \
		--snps-only just-acgt \
        --biallelic-only strict \
		--maf ${params.maf} \
		--geno ${params.geno} \
		--bfile ${bim.baseName} \
		--out ${cohort}.filtered
	
	n_samples=\$(wc -l < ${cohort}.filtered.fam)
	n_variants=\$(wc -l < ${cohort}.filtered.bim)
    """
}
