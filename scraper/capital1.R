c1URL <- read_html('https://www.capitalone.com/credit-cards/compare/')

writeLines(sprintf("var url ='https://www.capitalone.com/credit-cards/compare/';
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
                   }"), con="scrape.js")

system("phantomjs scrape.js")

pg <- read_html("1.html")

# Card Names
c1CardName <- pg %>%
  html_nodes(xpath="//*[@class='cardtitle']/h3/a") %>%
  html_text()
c1CardName <- gsub('[^A-z&-+\']', ' ', c1CardName)
c1CardName <- str_trim(gsub('\\s{2,}', ' ', c1CardName))

# Card Offer
c1CardIntro <- pg %>%
  html_nodes(xpath="//*[@class='primary']") %>%
  html_text()
c1CardIntro <- c1CardIntro[-1]
c1CardIntro <- gsub('\\s{2,}', ' ', c1CardIntro)

# Card Links
c1Links <- pg %>%
  html_nodes(xpath="//*[@class='cardtitle']/h3/a") %>%
  html_attr("href")
c1Links <- paste0('https://www.capitalone.com', c1Links)

# Create Data Frame
c1 <- data.frame(CardName = c1CardName,
                    Issuer = 'Capital One',
                    Program = 'Capital One',
                    Link = c1Links,
                    IntroOffer = c1CardIntro, stringsAsFactors = FALSE)

# Intro Reward Types
c1$Cash   <- as.numeric(ifelse(grepl('one-time \\$\\d{2,3} ', c1CardIntro), 
                                  gsub('.*one-time \\$(\\d{2,3}) .*$', '\\1', c1CardIntro), 0))
c1$Points <- as.numeric(ifelse(grepl(' \\d{1,3},\\d{3} ', c1CardIntro), 
                                  gsub('.*? (\\d{1,3}),(\\d{3}).*', '\\1\\2', c1CardIntro), 0))
c1$Nights <- ifelse(grepl('nights', c1CardIntro), 
                       2, 0)

c1$Credit <- 0

c1CardFee <- pg %>%
  html_nodes(xpath="//*[@class='fee']/p/span") %>%
  html_text()

c1$FeeWaived1stYr <- ifelse(grepl('\\$0.*first year', c1CardFee), 1, 0)

c1CardFee <- gsub('\\$0', '', c1CardFee)
c1CardFee <- gsub('\\D', '\\1', c1CardFee)


c1$Fee <- 0
c1$Fee <- as.numeric(ifelse(grepl('\\d', c1CardFee), 
                               gsub('\\D', '', c1CardFee), c1$Fee))

c1$Spend <- gsub(',', '', c1CardIntro)
c1$Spend <- as.numeric(ifelse(grepl('spend \\$(\\d{3,4})', c1$Spend),
                                 gsub('.*?spend \\$(\\d{3,4}).*', '\\1', c1$Spend), 0))

c1IMG <- pg %>%
  html_nodes(xpath="//*[@class='cardimage']/a/img") %>%
  html_attr("src")
c1$img <- paste0('https://www.capitalone.com', c1IMG)

for(p in rates[,1]){
  c1$Program <- ifelse(grepl(p, c1$CardName), p, c1$Program)
}



