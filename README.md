# Hammer Lab, Summer '17

Summary of (most of) my work at [Hammer Lab](http://www.hammerlab.org), during the summer of 2017.

## Bladder Cohort

For most of my summer, I analyzed data originally analyzed in [this](http://journals.plos.org/plosmedicine/article?id=10.1371/journal.pmed.1002309) manuscript.

To summarize what the paper says – this cohort consists of 29 patients with locally advanced or metastatic urothelial carcinoma treated at Memorial Sloan Kettering Cancer Center on an anti-PDL1 drug called atezolizumab. For most patients, we have TCR-seq, RNA expression, PD-L1 IHC, and tumor assessment data.

For the remainder of this notebook, we refer to this cohort as the "bladder cohort".

## Early Research Questions

I came into the summer with only a basic understanding of cancer, the immune system, and immunotherapy, on top of my limited statistical knowledge (I understood most concepts from the few statistics-related classes I had taken, but had yet to apply those concepts in practice).

Thus, I began the summer with lots of learning (by reading papers on the state-of-the-art in immuno-oncology, watching videos about survival analysis, and coding in R). Throughout this learning process, I developed a series of preliminary questions, one of which I hoped to explore more fully for the rest of the summer. Below are some of the questions I asked.

1. Why do anti-PDL1 immunotherapies work for patients with PD-L1 negative tumors?
2. More generally, why do patients with low TCR clonality prior to treatment, lack of TCR expansion post treatment, or lower TIL proportion ever respond to therapy? (In general, these three biomarkers are associated with clinical benefit.)
3. Is it possible that certain biomarkers, like PD-L1 levels, TCR clonality, and post-treatment TCR expansion, are results of other, confounding factors like tumor sample type and location, age, previous therapy, or other patient characteristics?
4. How do different approaches to survival analysis vary? (There are a variety of approaches to survival analysis, including cox proportional-hazard models, bayesian models, and deep learning models.)
5. Are more trunk mutations (over branch mutations) associated with clinical benefit?
6. Are adverse events (negatively) correlated with durable clinical benefit from therapy? That is, if you are more likely to respond to therapy, are you more or less likely to experience an adverse event to said therapy? Or are the two uncorrelated?

## Primary Research Question

I chose to explore the first question more thoroughly, which I call the "PD-L1 paradox":

 > Why do patients with low PD-L1 levels respond to anti-PDL1 immunotherapies? Does the full immune contexture provide any information as to why this occurs?
 
## Background

Adaptive technologies, a biotechnology company that runs a proprietary TCR-seq techonology, provided us with a T-cell fraction (TCF) for each patients' tumor sample. The TCF is the proportion of T-cells in the sample. Adaptive claims that the TCF they calculate corresponds well with IHC data; thus, we might treat the TCF as a sort of "gold standard." Although higher TCF is associated with clinical benefit, TCF alone does not explain how or why patients with low PD-L1 levels respond to therapy.

On the other hand, a fuller picture of the immune contexture might help to explain this so-called "PD-L1 paradox." Although we don't have immune cell composition data for patients in the bladder cohort, we can run a variety of computational tools on patients' RNA-seq data that attempt to quantify proportions of different immune cells in the tumor.

## Outline

This project consists of two main components:

1. A preliminary analysis which attempts to show correspondence between the computational tools described above and Adaptive's TCF.
2. A primary analysis which utilizes output from one of these computational tools to try and explain the PD-L1 paradox.

# Preliminary Analysis

The code for running the computational tools is located in [here](RunTILTools.ipynb).

The notebook which compares tools with Adaptive's TCF and with one another is [here](TILToolComparisons.ipynb). The notebook also provides an overview of each computational tool. Note that TIL (tumor-infiltrating lymphocytes) and TCF (T-cell fraction) are the same in this context.

# Primary Analysis

The notebook for the primary analysis is [here](PDL1SurvivalAnalysis.ipynb).

I also played around with some *very* basic Stan models [here](StanModels.ipynb). Their purpose was more to learn some Stan than to come up with any interesting results.
