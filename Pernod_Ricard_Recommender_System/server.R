#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library('xgboost')
library('tidyverse')
library(shiny)
library('fastDummies')
library(data.table)
#setwd('C:/Users/Tom/OneDrive - msqpartners.com/Documents/R Code/Pernod_Ricard_Recommender_System')

model <- xgb.load('xgb_model_R.model')
base_data <- read.csv('shiny_data.csv', na.strings="")
model_results <- readRDS("results.rds")
model_results <- sort(sample(model_results, 1000000))

shinyServer(function(input, output, session) {

  observeEvent(input$video_static,{
    if (input$video_static == 'Static') {
      
    
        updateSelectInput(session,"video_tag_ad_length",
                      choices = c('Not applicable'))
    }
    else {
      updateSelectInput(session,"video_tag_ad_length",
                        choices = c(":05 - :14" = ":05 - :14",
                                    ":15 - :29" = ":15 - :29",
                                    ":30 - :44" = ":3- :44",
                                    ":45 - :59" = ":45 - :59",
                                    ":60 to 2 min" = ":6to 2 min",
                                    ">2 min" = ">2 min"))
    }
  })
  
  
  prediction <- eventReactive(input$submit, {
    rbind(base_data, data.frame("region_code" = input$region_code, 
               "tag_beverage_category" = input$tag_beverage_category,
               "video_static" = input$video_static,
               "general_colours" = input$general_colours,
               "inAd_gender" = input$inAd_gender,
               "tag_intended_tone" = input$tag_intended_tone,
               "activity" = input$activity,
               "video_tag_ad_length" = input$video_tag_ad_length,
               "environment_elements" = input$environment_elements,
               "consumption_products" = input$consumption_products)) %>% 
      dummy_cols(remove_selected_columns = T) %>% 
      tail(n=1) %>% 
      as.matrix(.) %>% 
      predict(model,.)
    }
    )
  
  percentile <- eventReactive(input$submit, {
    1-mean(model_results>prediction())
  })
  
  `%!in%` <- Negate(`%in%`)
    
  percentile_string <- eventReactive(input$submit, {
    if (as.numeric(substr(round(percentile(), 2)*100, 1,2)) %in% c(1,21,31,41,51,61,71,81,91)){
      print(paste(substr(round(percentile(), 2)*100, 1,2), "st", sep = ''))
      return(paste(substr(round(percentile(), 2)*100, 1,2), "st", sep = ''))}
    if (as.numeric(substr(round(percentile(), 2)*100, 1,2)) %in% c(2,22,32,42,52,62,72,82,92)){
      print(paste(substr(round(percentile(), 2)*100, 1,2), "nd", sep = ''))
      return(paste(substr(round(percentile(), 2)*100, 1,2), "nd", sep = ''))}
    if (as.numeric(substr(round(percentile(), 2)*100, 1,2)) %in% c(3,23,33,43,53,63,73,83,93)){
      print(paste(substr(round(percentile(), 2)*100, 1,2), "rd", sep = ''))
      return(paste(substr(round(percentile(), 2)*100, 1,2), "rd", sep = ''))}
    if (as.numeric(substr(round(percentile(), 2)*100, 1,2)) %!in% c(1,21,31,41,51,61,71,81,91,2,22,32,42,52,62,72,82,92,3,23,33,43,53,63,73,83,93)){
      print(paste(substr(round(percentile(), 2)*100, 1,2), "th", sep = ''))
      return(paste(substr(round(percentile(), 2)*100, 1,2), "th", sep = ''))}
    })
    

  ad_class <- eventReactive(input$submit,{
    if (round(percentile(), 2)*100 > 75){
    "Above Expectations"
  } else if (round(percentile(), 2)*100 > 25){
    "Meeting Expectations"
  } else {
    "Below Expectations"
  }
  })
  
  predicted_score <- eventReactive(input$submit, {
    round(prediction(), 2)
  })
  
  prediction_random <- eventReactive(input$submit,{
    
    new_prediction <- 0
    previous_attempts <- c("Not applicable")
    if (input$video_static == 'Static'){
    possible_columns <- c("general_colours",
                          "inAd_gender",
                          "tag_intended_tone",
                          "activity",
                          "environment_elements",
                          "consumption_products")
    }
    else {
      possible_columns <- c("general_colours",
                            "inAd_gender",
                            "tag_intended_tone",
                            "activity",
                            "environment_elements",
                            "consumption_products", 
                            "video_tag_ad_length")      
    }
    for (column in sample(possible_columns)){
      possible_variables <- unique(base_data[column])
      selected_variable <- input[[column]]
      for(i in 1:nrow(possible_variables)) {  
        variable <- possible_variables[i, ]
        if (variable != selected_variable){
           new_variable <- variable
           df <- data.frame(matrix(ncol = 1, nrow = 1))
           colnames(df) <- c(column)
           df_column <- c(new_variable)
           df_new <- rbind(df, df_column) %>% 
             tail(1)
      
           new_row <- tibble("region_code" = input$region_code,
                     "tag_beverage_category" = input$tag_beverage_category,
                     "video_static" = input$video_static,
                     "general_colours" = input$general_colours,
                     "inAd_gender" = input$inAd_gender,
                     "tag_intended_tone" = input$tag_intended_tone,
                     "activity" = input$activity,
                     "video_tag_ad_length" = input$video_tag_ad_length,
                     "environment_elements" = input$environment_elements,
                     "consumption_products" = input$consumption_products)
          
          new_row[column] <- df_new
      
          new_prediction <-  rbind(base_data,new_row)
      
          new_prediction <- dummy_cols(new_prediction, remove_selected_columns = T) %>% 
            tail(n=1) %>% 
            as.matrix(.) %>% 
            predict(model,.)
          new_prediction <- round(new_prediction, 2)
          
          selected_column <- column
          selected_column <- str_to_title(gsub('_',' ', selected_column))
          selected_column <- gsub(' Code','', selected_column)
          selected_column <- gsub('Inad Gender','Gender in Ad', selected_column)
          selected_column <- gsub('Tag ','', selected_column)
          new_variable <- gsub('3-','30 ', new_variable)
          new_variable <- gsub('6to','60 to', new_variable)
          new_variable <- gsub("People", 'Multiple', new_variable)
          if (new_prediction > predicted_score()+0.1){
            
            return(HTML(paste0("<br/>This score can be improved by changing the ", selected_column, " feature to ", new_variable)))
          }
      }
      }
    }
    return(HTML("The advertisement features selected are predicted to return the optimal Behaviour Change score in the Market, Beverage Category, and Media Type chosen."))

  })
  
  output$prediction = renderUI({
  HTML(paste("<br/>The Average Behaviour Change Score you can expect to obtain by producing an ad with the selected attributes is:<br/>", '<p style="font-size:24px;"<b/>',round(prediction(), 2), "<b/><p/>"))
    })
  output$percentile = renderUI({
    HTML(paste("This equates to the ", percentile_string(), " Percentile. As in, there are ", 100-round(percentile(), 2)*100, "% of possible ads that would result in a higher predicted score. The performance of your proposed ad would therefore be classed as:<br/>",'<p style="font-size:22px;"<b/>', ad_class(), "<b/><p/>", sep = ''))
    })
  output$new_prediction = renderUI({
    prediction_random()
  })
  output$hist_plot <- renderPlot({
    par(bg = "#60269e")
    h<-hist(model_results, xlim = c(5,10))
    bin <- cut(round(prediction(), 2), h$breaks)
    clr <- rep("white", length(h$counts))
    clr[bin] <- "#00B2A8"
    plot(h, col=clr,
         yaxt="n", 
         main="Distribution of possible Behaviour Change Scores",
         xlab="Predicted Behaviour Change Score",
         col.main='white',
         col.lab='white',
         col.axis='white')
  })
})
  
