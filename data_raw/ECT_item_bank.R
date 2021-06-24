library(tidyverse)
ERT_item_bank <- readxl::read_xlsx("data_raw/ERT_item_bank.xlsx") %>%
  select(item_number:audio_file) %>%
  select(-song) %>%
  mutate(correct_2 = as.numeric(correct_2)) %>%
  mutate(correct = case_when(is.na(correct_2) ~ 2, correct_2 == 2 ~ 3, TRUE ~ 1)) %>%
  mutate(audio_file = gsub("5.mp3", "05.mp3", audio_file, fixed = TRUE))
usethis::use_data(ERT_item_bank, overwrite = TRUE)
