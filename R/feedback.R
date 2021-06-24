#' ERT feedback (with score)
#'
#' Here the participant is given textual feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' ERT_demo(feedback = ERT_feedback_with_score())}

ERT_feedback_with_score <- function(dict = ERT::ERT_dict) {
    psychTestR::new_timeline(
      psychTestR::reactive_page(function(state, ...) {
        #browser()
        results <- psychTestR::get_results(state = state,
                                           complete = TRUE,
                                           add_session_info = FALSE) %>% as.list()
        text_finish <- psychTestR::i18n("FEEDBACK",
                                        html = TRUE,
                                        sub = list(num_questions = results$ERT$num_questions,
                                                   num_correct = round(results$ERT$score * results$ERT$num_questions),
                                                   total_score = results$ERT$total_score,
                                                   max_score = results$ERT$max_score))
        psychTestR::page(
          ui = shiny::div(
            shiny::p(text_finish, style ="width:60%;text-align:justify"),
          )
        )
      }
      ),
    dict = dict
  )
}

ERT_feedback_graph_normal_curve <- function(perc_correct, x_min = 40, x_max = 160, x_mean = 100, x_sd = 15) {
  q <-
    ggplot2::ggplot(data.frame(x = c(x_min, x_max)), ggplot2::aes(x)) +
    ggplot2::stat_function(fun = stats::dnorm, args = list(mean = x_mean, sd = x_sd)) +
    ggplot2::stat_function(fun = stats::dnorm, args=list(mean = x_mean, sd = x_sd),
                           xlim = c(x_min, (x_max - x_min) * perc_correct + x_min),
                           fill = "lightblue4",
                           geom = "area")
  q <- q + ggplot2::theme_bw()
  #q <- q + scale_y_continuous(labels = scales::percent, name="Frequency (%)")
  #q <- q + ggplot2::scale_y_continuous(labels = NULL)
  x_axis_lab <- sprintf(" %s %s", psychTestR::i18n("TESTNAME"), psychTestR::i18n("VALUE"))
  title <- psychTestR::i18n("SCORE_TEMPLATE")
  fake_IQ <- (x_max - x_min) * perc_correct + x_min
  main_title <- sprintf("%s: %.0f", title, round(fake_IQ, digits = 0))

  q <- q + ggplot2::labs(x = x_axis_lab, y = "")
  q <- q + ggplot2::ggtitle(main_title)
  plotly::ggplotly(q, width = 600, height = 450)
}
#' ERT feedback (with graph)
#'
#' Here the participant is given textual and graphical feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' ERT_demo(feedback = ERT_feedback_with_score())}
ERT_feedback_with_graph <- function(dict = ERT::ERT_dict) {
  psychTestR::new_timeline(
      psychTestR::reactive_page(function(state, ...) {
        #browser()
        results <- psychTestR::get_results(state = state,
                                           complete = TRUE,
                                           add_session_info = FALSE) %>% as.list()
        x_min <- 40
        x_max <- 160
        total_score <- results$ERT$total_score/results$ERT$max_score
        fake_IQ <- (x_max - x_min) * results$ERT$total_score/results$ERT$max_score + x_min
        text_finish <- psychTestR::i18n("FEEDBACK",
                                        html = TRUE,
                                        sub = list(num_questions = results$ERT$num_questions,
                                                   num_correct = round(results$ERT$score * results$ERT$num_questions),
                                                   total_score = fake_IQ,
                                                   max_score = x_max))
        norm_plot <- ERT_feedback_graph_normal_curve(total_score)
        psychTestR::page(
          ui = shiny::div(
            shiny::p(text_finish, style ="width:60%;text-align:justify"),
            shiny::p(norm_plot),
            shiny::p(psychTestR::trigger_button("next", psychTestR::i18n("CONTINUE")))
          )
        )
      }
      ),
    dict = dict
  )

}
