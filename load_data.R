library(dplyr)
library(readr)
library(stringr)

setwd("data")

# Loads CIBERSORT data and computes CIBERSORT's TIL.
load_cibersort_data <- function() {
    tcell.columns = c(
        'T.cells.CD8',
        'T.cells.CD4.naive',
        'T.cells.CD4.memory.resting',
        'T.cells.CD4.memory.activated',
        'T.cells.follicular.helper',
        'T.cells.regulatory..Tregs.',
        'T.cells.gamma.delta'
    )

    cibersort <-
        read_tsv("cibersort-output.tsv", comment=">") %>%
        as.data.frame %>%
        rename(SampleName = "Sample Name") %>%
        select(-P.value, -Pearson.Correlation, -RMSE)

    cibersort_til <-
        cibersort %>%
        column_to_rownames("SampleName") %>%
        select(tcell.columns) %>%
        rowSums %>%
        as.data.frame %>%
        rename(cibersort = ".") %>%
        rownames_to_column("SampleName") %>%
        as.data.frame
}

# Bulk of the code here. Loads all (currently) relevant patient data.
load_patient_data <- function() {
    # 29 patients
    genentech_ids <-
        read_csv("genentech_to_msk_id_map.csv") %>%
        rename(PatientId = `Sample ID`) %>%
        mutate(PatientId = str_replace_all(PatientId, "[^0-9]", "")) %>%
        mutate(PatientId = ifelse(PatientId == "2397", "2937", PatientId)) %>%  # genentech mistake!
        as.data.frame

    # 29 patients
    patient_ids <-
        read_tsv("2850417_Neoantigen_RNA_bams.csv", col_names = c("MGI DNA Name", "BAM Name")) %>%
        rename(SampleName = `BAM Name`) %>%

        # This extracts the part of the BAM Name we want to match.
        # We deal with periods only throughout the pipeline, for simplicity.
        # (Some tools convert _/- automatically, so it's easier to always use the period.)
        mutate(SampleName = str_replace_all(str_extract(SampleName, "(gerald[^\\.]+)"), "-|_", ".")) %>%

        left_join(read_csv("sequencing_manifest.csv"), by = "MGI DNA Name") %>%

        # Patient IDs are numbers here, but are padded strings in other files.
        mutate(PatientId = str_pad(`Individual Name`, 4, pad="0")) %>%
        select(SampleName, PatientId) %>%

        right_join(genentech_ids, by = "PatientId") %>%  # We want all 29 patient IDs.

        as.data.frame

    # 24 patients w/ TCR sequencing
    tcr_master <-
        read_csv("tcr_master.csv") %>%
        mutate(PatientId = str_replace(`Subject ID`, "-[A-Z]$", "")) %>%
        filter(`Time Point` == "A", `Sample Type` == "Tumor")

    # 29 patients in total
    clinical_updated <-
        read_csv("clinical_updated.csv", skip = 1) %>%
        rename(PatientId = ID)


    keep_ihc_sample = function(id, location) {
        !(id %in% c(1022, 1023, 1026, 1184, 1202, 1232)) |
            (id == 1022 & location == "BLADDER") |
            (id == 1023 & location == "BLADDER") |
            (id == 1026 & location == "BLADDER RADICAL CYSTECTOMY") |
            (id == 1184 & location == "LYMPHNODES") |
            (id == 1202 & location == "BLADDER URETUS BILATERAL TUBES") |
            (id == 1232 & location == "BLADDER")
    }

    # 29 patients with PD-L1 IHC
    tcga_subtypes <-
        read_csv("tcga_subtypes.csv", skip = 1) %>%
        filter(keep_ihc_sample(`Patient Enrolled ID`, Location))

    cohort <-
        patient_ids %>%
        left_join(clinical_updated, by = "PatientId") %>%

        left_join(tcr_master, by = "PatientId") %>%
        left_join(tcga_subtypes, by = c(`Genentech Pt ID` = "Patient Enrolled ID")) %>%

#         left_join(cibersort_til, by = "SampleName") %>%

        mutate(
            is_deceased = `Alive Status` == "N",
            is_progressed = `Ongoing Responder RECIST 1.1` == "N",
            is_progressed_or_deceased = is_deceased | is_progressed) %>%

        select(
            SampleName,
            PatientId,
            GenentechPatientId = `Genentech Pt ID`,
            Time = `Time Point`,
            TIL = `T-cell fraction`,
            IC.PDL1 = `PD-L1`,
            PDL1 = `Raw ICp`,
            mPFS = `PFS (mRECIST 1.1) in days`,
            PFS = `PFS (RECIST 1.1) in days`,
            OS = `OS in days`,
            is_deceased,
            is_progressed,
            is_progressed_or_deceased) %>%
        mutate(DCB = as.integer(PFS) > 182) %>%

        as.data.frame

    # # 29 patients in total.
    # stopifnot(nrow(cohort) == 29)

    # # 24 patients w/ TCRseq data.
    # stopifnot(nrow(
    #     cohort %>%
    #         filter(!is.na(TIL)))
    #     == 24)

    # # 26 patients w/ RNAseq data.
    # stopifnot(nrow(
    #     cohort %>%
    #         filter(!is.na(cibersort)))
    #     == 26)

    colnames(cohort)
    nrow(cohort)
    cohort %>% arrange(PatientId)
}

load_patient_data()
