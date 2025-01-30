library(dotenv)
library(shiny)
library(shinychat)
library(bslib)
library(ellmer)

ui <- page_sidebar(
  sidebar = sidebar(
    radioButtons(
      inputId = "language",
      label = "Select Language",
      choices = list(
        "Python" = 1,
        "R" = 2
      )
    )
  ),

  chat_ui("chat")
)

server <- function(input, output, session) {
  # Initialize chat with default system prompt (you can choose either Python or R as default)
  default_prompt <- paste(readLines("prompt-r.md"), collapse = "\n")
  chat_obj <- chat_claude(
    model = "claude-3-5-sonnet-latest",
    system_prompt = default_prompt
  )

  # Create reactive chat object
  chat <- reactiveVal(chat_obj)

  # Update chat when language changes
  observeEvent(input$language, {
    new_prompt <- if (input$language == 1) {
      paste(readLines("prompt-py.md"), collapse = "\n")
    } else {
      paste(readLines("prompt-r.md"), collapse = "\n")
    }

    # Create new chat instance with new prompt
    new_chat <- chat_claude(
      model = "claude-3-5-sonnet-latest",
      system_prompt = new_prompt
    )
    chat(new_chat)
  })

  observeEvent(input$chat_user_input, {
    chat_append("chat", chat()$stream_async(input$chat_user_input))
  })

  chat_append(
    "chat",
    "👋 Hi, I'm **Pointblank Assistant**! I'm here to answer questions about [pointblank in R](https://github.com/rstudio/pointblank/) and [pointblank in Python](https://github.com/rich-iannone/pointblank), or to generate code for you."
  )
}

shinyApp(ui, server)