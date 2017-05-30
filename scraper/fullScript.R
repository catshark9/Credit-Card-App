rm(list = ls())

setwd('C:/Users/Jon Kelley/Documents/Apps/CreditCard-App/scraper')

suppressMessages(library(rvest))
suppressMessages(library(stringr))
suppressMessages(library(xlsx))
suppressMessages(library(dplyr))
suppressMessages(library(readr))

options(stringsAsFactors = FALSE)

source('part 1.R') 
source('chase.R')
source('barclay.R')
source('citi.R')
source('amex.R')
source('amexbus.R')
source('BOA.R')
source('US.R')
source('part 2.R')
source('email.R')



