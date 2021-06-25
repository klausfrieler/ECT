get_item_sequence <- function(seed = NULL, num_items){
  #browser()
  if(!is.null(seed)){
    set.seed(seed)
  }
  sample(1:nrow(ECT::ECT_item_bank), num_items)
}

scoring <- function(){
  psychTestR::code_block(function(state,...){
    results <- psychTestR::get_results(state = state,
                                       complete = FALSE,
                                       add_session_info = FALSE) %>% as.list()
    sum_score <- sum(purrr::map_lgl(results$ECT, function(x) x$correct))
    total_score <- sum(purrr::map_dbl(results$ECT, function(x) x$total_score))
    num_same <- sum(purrr::map_dbl(results$ECT, function(x) as.numeric(x$correct_answer == 2)))
    num_questions <- length(results$ECT)
    max_score <- 2 * num_questions - num_same
    perc_correct <- sum_score/num_questions
    psychTestR::save_result(place = state,
                 label = "score",
                 value = perc_correct)
    psychTestR::save_result(place = state,
                             label = "num_questions",
                             value = num_questions)
    psychTestR::save_result(place = state,
                            label = "total_score",
                            value = total_score)
    psychTestR::save_result(place = state,
                            label = "max_score",
                            value = max_score)

  })
}

get_prompt <- function(item_number, num_items, practice_page = FALSE) {
  key <- "PROGRESS_TEXT"
  if(practice_page){
    key <- "SAMPLE_PROGRESS_TEXT"
  }
  shiny::div(
    shiny::h4(
      psychTestR::i18n(
        key,
        sub = list(num_question = item_number,
                   test_length = if (is.null(num_items))
                     "?" else
                       num_items)),
      style  = "text_align:center"
    ),
    shiny::p(
      psychTestR::i18n("ITEM_PROMPT"),
      style = "margin-left:20%;margin-right:20%;text-align:center")
  )
}



# main_test <- function(num_items,
#                       audio_dir,
#                       dict = ECT::ECT_dict,
#                       ...) {
#
#   elts <- c()
#   item_bank <- ECT::ECT_item_bank
#   item_sequence <- sample(1:nrow(item_bank), num_items)
#   for(i in 1:length(item_sequence)){
#     item <- ECT::ECT_item_bank[item_sequence[i],]
#     messagef("Added item %d, stimulus = %s, correct= %d", item_sequence[i], item[1,]$audio_file, item[1,]$correct)
#     item_page <- ECT_item(label = sprintf("q%d", i),
#                           correct_answer = item[1,]$correct,
#                           prompt = get_prompt(i, num_items, practice_page = FALSE),
#                           audio_file = item$audio_file[1],
#                           audio_dir = audio_dir,
#                           save_answer = TRUE)
#     elts <- psychTestR::join(elts, item_page)
#   }
#   elts
# }
#
create_test_pages <- function(num_items = 20L, audio_dir = "https://media.gold-msi.org/test_materials/ECT") {
  ret <- psychTestR::code_block(function(state, ...){
    seed <-  psychTestR::get_session_info(state, complete = F)$p_id %>%
      digest::sha1() %>%
      charToRaw() %>%
      as.integer() %>%
      sum()
    item_sequence = get_item_sequence(seed, num_items)
    print(item_sequence)
    psychTestR::set_local(key = "item_sequence", value = item_sequence, state = state)
    psychTestR::set_local(key = "item_number", value = 1L, state = state)

  })
  for(i in 1:num_items){

    #printf("Created item with %s, %d", correct_answer, nchar(correct_answer))
    #browser()
    item <- psychTestR::reactive_page(function(state, ...) {
      #browser()
      item_sequence <- psychTestR::get_local("item_sequence", state)
      item_number <- psychTestR::get_local("item_number", state)
      #messagef("Current item number: %d", item_number)
      item <- ECT::ECT_item_bank[item_sequence[item_number],]
      messagef("Added item #%d with id = %d, stimulus = %s, correct= %d",
               item_number,
               item_sequence[item_number],
               item[1,]$audio_file,
               item[1,]$correct)
      item_page <- ECT_item(label = sprintf("q%d", item_number),
                            correct_answer = item[1,]$correct,
                            prompt = get_prompt(item_number, num_items, practice_page = FALSE),
                            audio_file = item$audio_file[1],
                            audio_dir = audio_dir,
                            save_answer = TRUE)
      item_page
    })
    ret <- c(ret, item)

  }
  #browser()

  ret
}

main_test <- function(num_items = 20L,
                      audio_dir = "https://media.gold-msi.org/test_materials/ECT") {
  elts <- create_test_pages(num_items, audio_dir = audio_dir)
  return(elts)
}

ECT_welcome_page <- function(dict = ECT::ECT_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
    body = shiny::div(
      shiny::h4(psychTestR::i18n("WELCOME")),
      # shiny::div(psychTestR::i18n("INTRO_TEXT"),
      #          style = "margin-left:0%;display:block")
    ),
    button_text = psychTestR::i18n("CONTINUE")
  ), dict = dict)
}

ECT_finished_page <- function(dict = ECT::ECT_dict){
  psychTestR::new_timeline(
    psychTestR::one_button_page(
      body =  shiny::div(
        shiny::h4(psychTestR::i18n("THANKS")),
        psychTestR::i18n("COMPLETED"),
                         style = "margin-left:0%;display:block"),
      button_text = psychTestR::i18n("CONTINUE")
    ), dict = dict)
}

ECT_final_page <- function(dict = ECT::ECT_dict){
  psychTestR::new_timeline(
    psychTestR::final_page(
      body = shiny::div(
        shiny::h4(psychTestR::i18n("THANKS")),
        shiny::div(psychTestR::i18n("COMPLETED"),
                   style = "margin-left:0%;display:block"),
        button_text = psychTestR::i18n("CONTINUE")
      )
    ), dict = dict)
}

# show_item <- function(audio_dir) {
#   function(item, ...) {
#     #stopifnot(is(item, "item"), nrow(item) == 1L)
#     item_number <- psychTestRCAT::get_item_number(item)
#     num_items <- psychTestRCAT::get_num_items_in_test(item)
#     emotion <- psychTestR::i18n(item[1,]$emotion_i18)
#     messagef("Showing item %s", item_number)
#     ECT_item(
#       label = paste0("q", item_number),
#       emotion = emotion,
#       audio_file = item$audio_file,
#       correct_answer = item$answer,
#       prompt = get_prompt(item_number, num_items, emotion),
#       audio_dir = audio_dir,
#       save_answer = TRUE,
#       get_answer = NULL,
#       on_complete = NULL,
#       instruction_page = FALSE
#     )
#   }
# }
