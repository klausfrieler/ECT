ECT_dict_raw <- readxl::read_xlsx("data_raw/ECT_dict.xlsx")
ECT_dict <- psychTestR::i18n_dict$new(ECT_dict_raw)
usethis::use_data(ECT_dict, overwrite = TRUE)
