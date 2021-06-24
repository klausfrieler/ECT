ERT_dict_raw <- readxl::read_xlsx("data_raw/ERT_dict.xlsx")
ERT_dict <- psychTestR::i18n_dict$new(ERT_dict_raw)
usethis::use_data(ERT_dict, overwrite = TRUE)
