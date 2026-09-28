process GENOME {
    tag "${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/ibd", mode: 'copy')

    input:
    tuple val(cohort),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort),
          path("${cohort}.ibd.genome"),
          path("${cohort}.ibd.log")

    script:
    """
    #!/bin/bash
    plink \
      --bfile ${bim.baseName} \
      --genome full \
      --out ${cohort}.ibd
    """
}
