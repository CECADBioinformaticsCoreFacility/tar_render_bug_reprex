library(targets)
library(tarchetypes)

tar_option_set(packages = c("dplyr", "purrr", "tibble", "ggplot2"))

## This pipeline fails with N=1,B=1 for tarchetypes < 0.6.0.9000.
## The issue is fixed in version 0.6.0.900.

N <- 3
B <- 1
list(
    ## how many sub-samples from datasets::mtcars
    tar_target(nsamples, N),
    
    tar_target(datasets,
               map(1:nsamples,
                   function(i) datasets::mtcars %>% slice_sample(n=10))
    ),
    
    ## create the input tibble for tar_render_rep
    tar_target(report_tibble,
               tibble::tibble(dataset = datasets,
                              output_file = paste0("file_", 1:nsamples, ".html"))
    ),
    
    ## produce report(s) -- 
    ## NOTE: If one of the output file NAMES already exists, 
    ##       the file is not re-created, although the content could be different.
    ## BUT: in reality the content is NOT different,
    ##      because each target has a fixed random seed.
    tar_render_rep(report, "test_report.Rmd",
                   params = report_tibble,
                   batches=B
    )
)
