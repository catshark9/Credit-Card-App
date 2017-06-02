cards <- rbind(chase, bc, citi, amex, abus, boa, us, c1)
cards$Credit <- ifelse(cards$Credit==1, 0, cards$Credit)

cards$Credit <- ifelse(cards$Points>0 & cards$Cash > 0, cards$Cash, cards$Credit)
cards$Cash <- ifelse(cards$Points>0 & cards$Cash > 0, 0, cards$Cash)


cards <- merge(x = cards, y = rates[1:2], by = "Program", all.x = TRUE)
names(cards)[length(cards)] <- 'Rate'
cards$Rate <- cards$Rate/100
cards$Rate[is.na(cards$Rate)] <- 0.01

cards$Value <- cards$Points*cards$Rate + cards$Cash + cards$Nights*150 + cards$Credit - abs(cards$FeeWaived1stYr-1)*cards$Fee
cards[is.na(cards)] <- 0
write.csv(cards, 'data/CurrentValues.csv', row.names = FALSE)