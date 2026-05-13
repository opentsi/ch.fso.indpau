#' Process FSO BAPAU Data
#'
#' Fetches all time series in the ch.fso.bapau collection from the KOF
#' Time Series Database and writes each to its key.csv
#'
#' @importFrom tsdbapi read_dataset_keys set_config read_ts
#' @param key API key for the KOF Time Series Database.
#' @return Invisibly returns a character vector of output file paths.
#' @export
process_data <- function(key = key) {
  set_config(api_key = key)

  keys <- read_dataset_keys("ch.fso.indpau")
  tsl <- read_ts(keys)

  out_paths <- lapply(names(tsl), function(k) {
    ts_obj <- tsl[[k]]
    # remove prefix so it matches with current data
    k <- sub("^ch\\.fso\\.indpau\\.", "", k)
    print(k)

    output_path <- file.path("data-raw", "csv", paste0(k, ".csv"))

    ts_time <- time(ts_obj)
    freq <- frequency(ts_obj)
    values <- as.numeric(ts_obj)

    # ch.fso.bapau is 4, nut here 12c 
    if (freq == 12) {
      years <- floor(ts_time)
      quarters <- round((ts_time - years) * 4) + 1
      months <- (quarters - 1L) * 3L + 1L
      ts_dates <- as.Date(sprintf("%d-%02d-01", years, months))
    } else {
      stop(sprintf("Unsupported frequency: %d", freq))
    }

    ts_df <- data.frame(time = ts_dates, value = values)
    write.csv(ts_df, file = output_path, row.names = FALSE, quote = FALSE)
    message(sprintf("Written: %s", output_path))
    output_path
  })

  invisible(unlist(out_paths))
}

# test with key -.
key <- "8faea36fd76782e88f552f6f2eed360bcea9965c2eac6c76880e425c8823f710"
process_data(key)
