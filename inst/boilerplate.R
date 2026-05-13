library(deloRean)
library(opentimeseries)


## Example Step 1, Init Archive, once generated make sure
# the newly created archive is your working dir
# outcommented because by the time you read this in boilerplate.R
# you've already created the archive.
# archive_init("ch.kof.globalbaro", parent_dir = )



## Example Step 2, Generate History


library(tsdbapi)
keys <- read_dataset_keys("ch.fso.indpau")
length(keys)
all_vintages <- read_ts_history(keys)

# read_ts_history returns names as key_YYYYMMDD; convert to key.YYYY-MM
# so that create_vintage_dt can strip the .YYYY-MM suffix to recover the key
vintage_date_str <- sub(".+_([0-9]{8})$", "\\1", names(all_vintages))
vintage_dates <- as.Date(vintage_date_str, format = "%Y%m%d")
names(all_vintages) <- sub("_([0-9]{4})([0-9]{2})[0-9]{2}$", ".\\1-\\2", names(all_vintages))
# remove the dataset prefix so keys match the relative key structure in the archive
names(all_vintages) <- sub("^ch\\.fso\\.indpau\\.", "", names(all_vintages))
class(all_vintages) <- c(class(all_vintages), "tslist")


## Step 3: Create vintages data.table
vintages_dt <- create_vintage_dt(vintage_dates, all_vintages)
head(vintages_dt, n = 100)
# View(vintages_dt)


setwd("~/KOF_Lab/opentsi/ch.fso.indpau")
archive_import_history(vintages_dt, repository_path = ".")


## Step 5: Write & Validate Metadata

# check if info is available via api
indpau_meta <- read_dataset_ts_metadata("ch.fso.indpau") # returns named list()...
# so i fetched the metadata from swissdata...


render_metadata()
meta <- read_meta(".")
validate_metadata(meta) # TRUE


## Step 6: Seal Archive
devtools::load_all()
library(digest)
checksum_input <- generate_checksum_input()
archive_seal(checksum_input)


## Step 7: Final Checks & Automation
devtools::load_all()
handle_update()

library(devtools)
check()
install()


