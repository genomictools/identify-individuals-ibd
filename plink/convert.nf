process CONVERT {
    tag "${cohort}:${key}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/plink", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(level),
          path(file)

    output:
    tuple val(cohort), val(key), val("plink"),
          path("${cohort}.${key}.bim"),
          path("${cohort}.${key}.bed"),
          path("${cohort}.${key}.fam"),
          path("${cohort}.${key}.log")

    script:
    """
    #!/bin/bash
    plink \
		--make-bed \
        --biallelic-only strict \
    	--exclude <(echo "\\.") \
		--allow-no-sex \
		--double-id \
		--vcf ${file[0]} \
		--out ${cohort}.${key}
    """
}
