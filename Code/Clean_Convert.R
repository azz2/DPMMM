clean_convert <- function(exper.name){
  image.dir <- paste0("Images/", exper.name)
  if (!file.exists(image.dir)){
    dir.create(image.dir)
  }
  relevant_trips <- Triplet_meta[triplets,]
  names_ext <- paste0(relevant_trips$Cell, "_Site", relevant_trips$Site,
                      "_Freq", relevant_trips$AltFreq,
                      "_Pos", relevant_trips$AltPos, ".png")
  curr_files <- paste0("Summary_Triplet", triplets, ".pdf-1.png")
  cbind(curr_files, names_ext)
  conv_csv <- paste0(image.dir, "/rename.csv")
  write.csv(cbind(curr_files, names_ext), file = conv_csv, row.names = F, col.names = NULL)
  clean_file <- paste0(image.dir, "/cleanup.sh")
  str1 = paste0("START=",min(triplets), "
                END=",max(triplets))
  str2 = paste0('EXT=".pdf"
              for ((i=START;i<=END;i++));
              do
              file="../../Figures/', exper.name,'/Triplet_$i/Summary_Triplet$i"')
  str3 = 'file+=".pdf"	
echo "Copying $file"
cp $file ./
echo "Converting Summary_Triplet$i$EXT "
file="Summary_Triplet$i$EXT"
pdftoppm -rx 300 -ry 300 -png "$file" "$file"
done'
  str4 = "awk -F, \'{print("
  str5 = '"mv \\"" $1 "\\" \\"" $2 "\\"")}'
  str6 = "' rename.csv | bash -"
  full_file = paste0(paste(str1, str2, str3, str4, sep = "\n"), str5, str6)
  cat(full_file, file = clean_file)
}