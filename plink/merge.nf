process MERGE {
    tag "${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/merged", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(type),
          path(bim), path(bed), path(fam), path(log)

    output:
    tuple val(cohort),
          path("${cohort}.merged.bim"),
          path("${cohort}.merged.bed"),
          path("${cohort}.merged.fam"),
          path("${cohort}.merged.log"),
		  env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    set -euo pipefail

    # Collect file names
    paste -d ' ' \
    	<(echo "${bed.join('\n')}") \
      	<(echo "${bim.join('\n')}") \
      	<(echo "${fam.join('\n')}") | \
      	sort -V > allfiles.txt

    # First-pass merge
    if ! plink \
		--make-bed \
		--merge-list allfiles.txt \
		--allow-no-sex \
		--out ${cohort}.merged; then
      # One fallback pass: exclude missnp sites and retry merge
      [[ -s ${cohort}.merged-merge.missnp ]] || exit 1

      : > filtered_allfiles.txt
      idx=0
      while read -r bed_file bim_file fam_file; do
        prefix="\${bed_file%.bed}"
        out_prefix="filtered.\${idx}"

        plink \
			--bfile "\${prefix}" \
			--exclude ${cohort}.merged-merge.missnp \
			--make-bed \
			--allow-no-sex \
			--out "\${out_prefix}"

        printf '%s %s %s\n' "\${out_prefix}.bed" "\${out_prefix}.bim" "\${out_prefix}.fam" >> filtered_allfiles.txt
        idx=\$((idx + 1))
      done < allfiles.txt

      plink \
		--make-bed \
		--merge-list filtered_allfiles.txt \
		--allow-no-sex \
		--out ${cohort}.merged
    fi

    [[ -s ${cohort}.merged.bed ]] || exit 3
	n_samples=\$(wc -l < ${cohort}.merged.fam)
	n_variants=\$(wc -l < ${cohort}.merged.bim)
    """
}

