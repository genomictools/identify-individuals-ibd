#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { align_genotypes } from './subworkflows/align_genotypes.nf'
include { run_ibd }         from './subworkflows/run_ibd.nf'

cohorts_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, row.key, row.level, file(row.file) ] }

workflow {
    genotypes = align_genotypes(cohorts_ch)
    run_ibd(genotypes)
}
