library(targets)

## This pipeline fails with N=1,B=1 for tarchetypes < 0.6.0.9000.
## The issue is fixed in version 0.6.0.900.

tar_dir({
  lines <- c(
    "---",
    'title: "Test report"',
    "output: html_document",
    "params:",
    "  dataset: NULL",
    "---",
    "```{r mpg_vs_gear}",
    "params$dataset[[1]] %>% ggplot(aes(mpg,gear)) + geom_point()",
    "```"
  )
  writeLines(lines, "test_report.Rmd")

   tar_script({
    library(tarchetypes)
    tar_option_set(packages = c("dplyr", "purrr", "tibble", "ggplot2"))
    
    N <- 1
    B <- 1

    list(
      ## how many sub-samples from datasets::mtcars
      tar_target(nsamples, N),
      
      ## create the sub-samples
      tar_target(
        datasets,
        map(
          1:nsamples,
          function(i) datasets::mtcars %>% slice_sample(n = 10)
        )
      ),

      ## create the input tibble for tar_render_rep
      tar_target(
        report_tibble,
        tibble::tibble(
          dataset = datasets,
          output_file = paste0(
            "file_",
            1:nsamples, ".html"
          )
        )
      ),
      
      tar_render_rep(report, "test_report.Rmd",
        params = report_tibble,
        batches=B
      )
    )
  })
  tar_make()
})
    