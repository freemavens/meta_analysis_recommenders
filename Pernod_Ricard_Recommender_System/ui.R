#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
par(bg = "#60269e")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$head(
    # Note the wrapping of the string in HTML()
    tags$style(HTML("
      body {
      background-color: #60269e;
      color: white;
      }
      h2 {
      font-family: Helvetica;
      margin-bottom: 40px;
      font-size: 34px;
      text-decoration: bold;
      }
      a {
      color: white;
      }
      #submit {
      margin-top: 20px;
      margin-bottom: 20px;
      vertical-align: middle;
      font-size: 16px;
      }
      #percentile {
      font-size: 20px;
      text-align: center;
      color: #white;
      }
      #prediction {
      font-size: 20px;
      text-align: center;
      color: #white;
      }
      #new_prediction{
      font-size: 20px;
      text-align: center;
      color: #white;
      }
      .input_dropdown {
      font-size: 20px;
      }
      .selectize-input {
      height: 14px; 
      font-size: 16px;
      }
      .shiny-input-container {
      text-align: center;
      color: #white;
      }"))
  ),
  
  # Application title
  titlePanel(
    fluidRow(
      column(6, align="center", style="margin-top:35px;", "Perfect Blend: Ad Testing Predictive Service"), 
      column(2, img(height = 100, width = 240, src = "PR Logo.png")),
    )
    ),
  
  fluidRow(
    column(3, 
           tags$div(id='region_dropdown',
                    class='input_dropdown',
                    selectInput("region_code", "Region:", 
                                c("APAC" = "APAC",
                                  "EU" = "EU",
                                  "AFR" = "AFR",
                                  "NA" = "NA",
                                  "LATAM" = "LATAM")
                    )
           )),
    column(3,
           tags$div(id='bevcat_dropdown',
                    class='input_dropdown',
                    selectInput("tag_beverage_category", "Beverage Category:", 
                                c("Whisk(e)y" = "Whisk(e)y",
                                  "Liqueur" = "Liqueur",
                                  "Rum" = "Rum",
                                  "Cognac" = "Cognac",
                                  "Vodka" = "Vodka",
                                  "Gin" = "Gin",
                                  "Vermouth" = "Vermouth",
                                  "Wine" = "Wine",
                                  "Champagne" = "Champagne",
                                  "Beer" = "Beer",
                                  "Cider" = "Cider",
                                  "Coffee" = "Coffee",
                                  "Anise-flavoured Aperitif" = "Anise-flavoured Aperitif",
                                  "Tequila" = "Tequila",
                                  "Brandy" = "Brandy")
                    )
           )),
    column(3, 
           tags$div(id='video_static_dropdown',
                    class='input_dropdown',
                    selectInput("video_static", "Media Type:", 
                                c("Video" = "Video",
                                  "Static" = "Static")
                    )
           )),
    column(3,
           tags$div(id='video_length_dropdown',
                    class='input_dropdown',
                    selectInput("video_tag_ad_length", "Video Ad Length:", 
                                c("Not applicable" = "Not applicable",
                                  ":05 - :14" = ":05 - :14",
                                  ":15 - :29" = ":15 - :29",
                                  ":30 - :44" = ":3- :44",
                                  ":45 - :59" = ":45 - :59",
                                  ":60 to 2 min" = ":6to 2 min",
                                  ">2 min" = ">2 min")
                    )
           )),
  ),
  fluidRow(
    column(3,
           tags$div(id='inAd_gender_dropdown',
                    class='input_dropdown',
                    selectInput("inAd_gender", "Gender in Ad:", 
                                c("None/Not Applicable" = "Not applicable",
                                  "Male" = "Men",
                                  "Female" = "Female",
                                  "Multiple" = "People")
                    )
           )),
    column(3,
           tags$div(id='tone_dropdown',
                    class='input_dropdown',
                    selectInput("tag_intended_tone", "Tone:", 
                                c("Friendship" = "Friendship",
                                  "Artistic" = "Artistic",
                                  "Educational" = "Educational",
                                  "Classy" = "Classy",
                                  "Liberated" = "Liberated",
                                  "Calm/Relaxed" = "Calm / relaxed",
                                  "Funny" = "Funny",
                                  "Happy" = "Happy",
                                  "Informative" = "Informative")
                    )
           )),
    column(3,
           tags$div(id='activity_dropdown',
                    class='input_dropdown',
                    selectInput("activity", "Activity:", 
                                c("Not applicable" = "Not applicable",
                                  "Drinks with friends" = "Drinks with friends",
                                  "Party" = "Party",
                                  "Passions and hobbies" = "Passions and hobbies")
                    )
           )),
    column(3,
           tags$div(id='colour_dropdown',
                    class='input_dropdown',
                    selectInput("general_colours", "General Colours:", 
                                c("Tropical" = "Tropical",
                                  "Bright" = "Bright",
                                  "Cold" = "Cold",
                                  "Light" = "Light",
                                  "Green" = "Green",
                                  "Blue" = "Blue",
                                  "Dark" = "Dark",
                                  "Black" = "Black",
                                  "Gold" = "Gold",
                                  "Red" = "Red",
                                  "Brown" = "Brown",
                                  "Orange" = "Orange")
                    )
           )),
  ),
  fluidRow(
    column(3, offset = 3,
           tags$div(id='environment_dropdown',
                    class='input_dropdown',
                    selectInput("environment_elements", "Environment Elements:", 
                                c("Not applicable" = "Not applicable",
                                  "Pub" = "Pub",
                                  "Club" = "Club",
                                  "City" = "City",
                                  "Nature - Countryside" = "Nature - Countryside",
                                  "Nature - Summer village" = "Nature - Summer village",
                                  "Nature - Sea" = "Nature - Sea", 
                                  "Outdoors drinks" = "Outdoors drinks")
                    )
           )),
    column(3,
           tags$div(id='consumption_dropdown',
                    class='input_dropdown',
                    selectInput("consumption_products", "Consumption Type:", 
                                c("Not applicable" = "Not applicable",
                                  "Cocktail(s)" = "Cocktails",
                                  "Drink(s)" = "Drinks")
                    )
           ))
  ),
  fluidRow(
    column(4, offset = 5,
           actionButton("submit", ("Submit"), width='50%')
    )
  )
  ,
  
  
  
  mainPanel(
    fluidRow(column(8, offset=2, htmlOutput("prediction"))),
    fluidRow(column(8, offset=2, htmlOutput("percentile"))),
    fluidRow(column(8, offset=2,plotOutput("hist_plot"))),
    fluidRow(column(8, offset=2, htmlOutput("new_prediction"))),
    fluidRow(column(2, offset=10, tags$a(href="https://freemavens.com/","Powered by Freemavens"))),
    width='100%'

    
  )))


# RANGE IS 4.98 - 10 (tested all ~27 MILLION possible combinations)
# Buckets:
# 5-6: 32147
# 6-7: 3078758
# 7-8: 14220989
# 8-9: 9051636
# 9-10: 573203



