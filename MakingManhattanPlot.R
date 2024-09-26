install.packages("qqman")

library("qqman")
library(dplyr)
library(tidyr)

#Set working directory

gwasResults <- read.table("ExampleSizeAnalysis.assoc.linear.adjusted",header=TRUE,fill=TRUE,sep="",check.names=FALSE)

gwasResults2 <- gwasResults %>% separate_wider_delim(SNP, ":", names = c("A", "SNP"))

gwasResults3 <- transform(gwasResults2,id=as.numeric(factor(CHR)))

gwasResults3$SNP <- as.numeric(gwasResults3$SNP)

rm(gwasResults)

rm(gwasResults2)

pdf(file = "MyPlot.pdf",   # The directory you want to save the file in
    width = 6, # The width of the plot in inches
    height = 4) # The height of the plot in inches

gwasResults4 <- gwasResults3[which(gwasResults3$UNADJ<0.01),]

manhattan(gwasResults4, chr="id", bp="SNP", p="UNADJ",suggestiveline = F, genomewideline = F, ylim = c(2, 7))

dev.off()

######
