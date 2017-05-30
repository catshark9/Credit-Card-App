
writeLines(sprintf("var url ='https://www.usbank.com/credit-cards/compare.html?filter3=Rewards+cards$Travel';
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


usCardName <- pg %>% 
  html_nodes(xpath="//*[@class='productDetails clear']/div[1]/div[3]/h2/a") %>%
  html_text()
usCardName <- gsub('\\.', '', usCardName)
usCardName <- gsub('[^A-z&-+\']', ' ', usCardName)
usCardName <- str_trim(gsub('\\s{2,}', ' ', usCardName))


usLinks <- pg %>%
  html_nodes(xpath="//*[@class='h2text']/a") %>%
  html_attr("href")

usLinks <- ifelse(!grepl('http', usLinks), paste0('https://www.usbank.com', usLinks), usLinks)

usFee <- pg %>% 
  html_nodes(xpath="//*[@class='rowBorderTop']/td[3]/a") %>%
  html_text()
if(length(usFee)<length(usCardName)){
  usFee <- c(rep(0, length(usCardName)-length(usFee)), usFee)
}


usIMG <- pg %>%
  html_nodes(xpath="//*[@class='floatLeft append-right-20px']") %>%
  html_attr("src")
usIMG <- paste0('https://www.usbank.com/', usIMG)


us <- data.frame(CardName = usCardName,
                  Issuer = 'US',
                  Program = 'FlexPoints',
                  Link = usLinks, stringsAsFactors = FALSE)


usIntroBonus <- c()
usCash <- c()
usPoints <- c()
usNights <- c()
usCredit <- c()
usSpend <- c()
i<-1
for (l in us$Link){
  writeLines(paste0(i))
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
                     }, 10000);
                     }", l), con="scrape.js")

  system("phantomjs scrape.js")
  
  pg <- read_html("1.html")
  
  if(grepl('mycard', l)){
    intro <- pg %>% 
      html_nodes(xpath='//*[@class="col-right hidden-xs"]/p') %>%
      html_text()
    if(length(intro)==0){
      intro <- pg %>% 
        html_nodes(xpath='//*[@class="col-right"]/p') %>%
        html_text()
    }
  } else {
    intro <- pg %>% 
      html_nodes(xpath='//*[@class="prepend-top-5px push-bottom-15px cc-product-banner-p"]') %>%
      html_text()
    if(length(intro)==0){
      intro <- pg %>% 
        html_nodes(xpath='//*[@class="col-right"]/p') %>%
        html_text()
    }
  }
  if(grepl('rei-mastercard', l)){
    intro <- pg %>% 
      html_nodes(xpath='//*[@class="push-bottom-10px cc-product-banner-p"]') %>%
      html_text()
  }
  if(grepl('club-carlson', l)){
    if(l=='https://www.usbank.com/credit-cards/club-carlson-premier-rewards-visa-signature-credit-card.html'){
      intro <- 'Earn 85,000 Bonus Gold Points after you spend $2,500 on your card in the first 90 days'
    } else if(l=='https://www.usbank.com/credit-cards/club-carlson-rewards-visa-signature-credit-card.html'){
      intro <- 'Earn 60,000 Bonus Gold Points after you spend $1,500 on your card in the first 90 days'
    } else {
      intro <- 'Earn 30,000 Bonus Gold Points after you spend $1,000 on your card in the first 90 days'
    }
  }
  
  intro <- str_trim(gsub('\\s{2,}', ' ', intro))
  intro <- ifelse(length(intro)==0, 'delete', intro)
  
  spend <- ifelse(grepl('\\$\\d(,)?\\d{2,3}', intro), 
                  gsub('.*?\\$(\\d(,)?\\d{2,3}).*', '\\1', intro), 0)
  spend <- as.numeric(gsub(',', '', spend))
  spend <- ifelse(length(spend)==0, 0, spend)
  
  cash <- intro[grepl(' \\$[0-9]{3} ', intro)][1]
  cash <- ifelse(!is.na(cash), 
                 as.numeric(gsub('.*?\\$([0-9]{3}).*', '\\1', intro)), 0)
  points <- intro[grepl('[0-9]{1,3},[0-9]{3}', intro)][1]
  points   <- ifelse(!is.na(points), 
                     gsub('.*? ([0-9]{1,3},[0-9]{3}).*', '\\1', intro), 0)
  points <- as.numeric(gsub(',','', points))
  nights <- intro[grepl('nights', intro)][1]
  nights <- ifelse(!is.na(nights), 2, 0)
  
  credit <- intro[grepl('[C|c]redit', intro)|grepl('[S|s]tatement', intro)][1]
  credit <- ifelse(!is.na(credit), 1, 0)
  

  
  
  
  usIntroBonus <- c(usIntroBonus, intro)
  usCash <- c(usCash, cash)
  usPoints <- c(usPoints, points)
  usNights <- c(usNights, nights)
  usCredit <- c(usCredit, credit)
  usSpend <- c(usSpend, spend)
  
  writeLines(paste0(i, ' ', spend))
  i<-i+1
}

us$IntroOffer <- usIntroBonus
us$Cash <- usCash
us$Points <- usPoints
us$Nights <- usNights
us$Credit <- usCredit

us$FeeWaived1stYr <- ifelse(grepl('\\$0.*first 12 months', usFee), 1, 0)
usFee <- gsub(' \\$0', '', usFee)
us$Fee <- as.numeric(ifelse(grepl('\\$(\\d{2,3})', usFee),
                            gsub('.*?\\$(\\d{2,3}).*', '\\1', usFee), 0))

us$Spend <- usSpend
us$img <- usIMG

us <- us[!duplicated(us$CardName), ]

for(p in rates[,1]){
  us$Program <- ifelse(grepl(p, us$CardName), p, us$Program)
}
for(p in rates[,1]){
  us$Program <- ifelse(grepl(p, us$IntroOffer), p, us$Program)
}



write.csv(us, 'us.csv')

