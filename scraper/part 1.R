programs <- read_csv("data/programs.csv")

url <- read_html('https://thepointsguy.com/category/points-valuations/')
url <- url %>%
  html_nodes(xpath='/html/body/div[1]/div[3]/section[2]/div/div[1]/div[2]/a') %>%
  html_attr("href")


writeLines(sprintf("var url ='%s';
  var page = new WebPage()
                     var fs = require('fs');
                     
                     
                     page.open(url, function (status) {
                     just_wait();
                     });
                     
                     function just_wait() {
                     setTimeout(function() {
                     fs.write('1.html', page.content, 'w');
                     phantom.exit();
                     }, 2500);
                     }", url), con="scrape.js")

system("phantomjs scrape.js")

url <- read_html("1.html")

rates <- url %>%
  html_nodes('table') %>%
  html_table(header=TRUE)
rates<-rates[[1]]
rates <- rates[-4]
names(rates) <- c('Program', 'This_Month', 'Last_Month', 'Notes')


rates[,2] <- str_trim(rates[,2])
rates[,2] <- as.numeric(ifelse(grepl('-', rates[,2]),
       (as.numeric(gsub('(.*?)-.*', '\\1', rates[,2])) + as.numeric(gsub('.*?-(.*)', '\\1', rates[,2])))/2,
       rates[,2]))
names(rates)[1] <- 'Program'
rates[,1] <- gsub('Miles', '', rates[, 1])
rates[,1] <- gsub(' & More', 'Miles & More', rates[, 1])
rates[,1] <- gsub('-', ' ', rates[, 1])
rates[,1] <- gsub('AAdvantage', '', rates[,1])
rates[,1] <- gsub('Guest Rewards', '', rates[,1])
rates[,1] <- gsub('Avios', '', rates[,1])
rates[,1] <- gsub('SkyMiles', '', rates[,1])
rates[,1] <- gsub('Sky', '', rates[,1])
rates[,1] <- gsub('Starpoints', '', rates[,1])
rates[,1] <- gsub('Korean Air', 'SKYPASS', rates[,1])
rates[,1] <- str_trim(rates[,1])
rates <- rates[!is.na(rates[,2]), ]

rates <- merge(x=rates, y=programs, by='Program', all=TRUE)
rates$This_Month[is.na(rates$This_Month)] <- 1.0
rates$Notes[is.na(rates$Notes)] <- ''

write.csv(rates, 'data/rates.csv', row.names = FALSE)
