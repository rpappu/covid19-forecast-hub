## script for processing CU data
## Johannes Bracher
## April 2020


source("code/process_cu_file.R")
# make sure that English names of days and months are used
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

folders_to_process <- list.dirs("data-raw/CU", recursive = FALSE)
forecast_dates <- lapply(folders_to_process, date_from_cu_filepath)

# process only files from 2020-04-12 onwards:
folders_to_process <- folders_to_process[forecast_dates >= as.Date("2020-04-12")]

# different versions of CU forecasts:
scenarios <- c("60contact", "70contact", "80contact", "nointerv")

for(i in seq_along(folders_to_process)) {
  # check if file naming still the same:
  tmp_ls_files <- list.files(paste0(folders_to_process[i], "/cdchosp"))
  if(!all(paste0("state_cdchosp_", scenarios, ".csv") %in% tmp_ls_files)){
    stop("Not all expected files found.")
  }

  # run over different scenarios:
  for(sc in scenarios){
    dir.create(paste0("data-processed/CU-", sc, "/"), showWarnings = FALSE)

    forecast_date_temp <- date_from_cu_filepath(folders_to_process[i])

    tmp_dat <- process_cu_file(
      cu_filepath = folders_to_process[i],
      file = paste0("state_cdchosp_", sc, ".csv"),
      forecast_date = forecast_date_temp)

    write.csv(tmp_dat, paste0("data-processed/CU-", sc, "/",
                              forecast_date_temp,
                              "-CU-", sc, ".csv"), row.names = FALSE)
  }
}

