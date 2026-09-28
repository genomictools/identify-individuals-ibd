process SUBSET {
    tag "${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/subset", mode: 'copy')

    input:
    tuple val(cohort),
          path(bim), path(bed), path(fam), path(log),
	      val(n_samples), val(n_variants)

    output:
    tuple val(cohort),
          path("${cohort}.subset.bim"),
          path("${cohort}.subset.bed"),
          path("${cohort}.subset.fam"),
          path("${cohort}.subset.log"),
	      env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Randomly subset the data to a specified number of SNPs
    RANDOM=42; cat ${bim.baseName}.bim | shuf -n ${params.n_snps} > subset_snps.txt
        plink \
		--make-bed \
		--extract subset_snps.txt \
		--bfile ${bim.baseName} \
		--out ${cohort}.subset
	
	n_samples=\$(wc -l < ${cohort}.subset.fam)
	n_variants=\$(wc -l < ${cohort}.subset.bim)
    """
}
