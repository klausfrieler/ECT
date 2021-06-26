library(tidyverse)
ECT_item_bank <- readxl::read_xlsx("data_raw/ECT_item_bank.xlsx") %>%
  select(item_number:time, first = exp, second = comp) %>%
  mutate(correct_2 = as.numeric(correct_2)) %>%
  mutate(correct = case_when(is.na(correct_2) ~ 2, correct_2 == 2 ~ 3, TRUE ~ 1)) %>%
  mutate(audio_file = gsub("5.mp3", "05.mp3", audio_file, fixed = TRUE),
         same = is.na(correct_2),
         order = sign(first - second))
usethis::use_data(ECT_item_bank, overwrite = TRUE)
