library(GEOquery)
library(SRAdb)
library(DBI)
library(httr)

sink("/mnt/rnaseq/data/raw/log.txt")

# do this only once - but keep updating once in a while
# srafile = getSRAdbFile()
srafile = '/mnt/rnaseq/data/tools/SRAmetadb.sqlite'
con = dbConnect(RSQLite::SQLite(), srafile)

# command line arguments
args = commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
  stop("GEO/SRA must be supplied ", call.=FALSE)
} else {
  id <- args[1]
  print(paste0("Supplied id: ",id))
  if(length(grep('GSE',id)) == 1) {
    type <- 'GEO'
  } else
    type <- 'SRA'
}
destdir <- paste0('/mnt/rnaseq/data/raw/', id)
sradir <- paste0(destdir,'/sra')
print(paste0("Destination folder: ", sradir))

if(type == "GEO"){
  print("GEO study supplied...")
  x <- getGEO(GEO = id, GSEMatrix = FALSE, getGPL = FALSE, AnnotGPL = FALSE)
  ftp.path <- x@header$supplementary_file[grep('SRP', x@header$supplementary_file)]
  if(!dir.exists(sradir)){
    print("Downloading data...")
    system(paste0('mkdir -p ', sradir))
    logfile <- paste0(sradir, '/wget_logs.txt')
    cmd1 <- paste0('wget -r ', ftp.path, ' --directory-prefix=', sradir, ' --append-output=', logfile)
    print(cmd1)
    system(cmd1)

    print("Getting all SRA files...")
    cmd2 <- paste0("find ", sradir, " -name '*.sra' -exec mv --target-directory=", sradir, " {} +")
    print(cmd2)
    system(cmd2)

    print("Removing residual files...")
    cmd3 <- paste0('rm -rf ', sradir, '/ftp-trace.ncbi.nlm.nih.gov/')
    print(cmd3)
    system(cmd3)
  }
} else {
  print("SRA study supplied...")
  print("Downloading data...")
  system(paste0('mkdir -p ', sradir))
  x <- getSRAfile(in_acc = id, sra_con = con, fileType = 'sra', 
                  destDir = sradir, makeDirectory = TRUE, srcType = "fasp")
  urls <- gsub('anon','',x$fasp)
  x <- x$run
  for(i in 1:length(x)){
    print(x[i])
    if(http_error(x = urls[i])){
      print("URL does not exists!")
      next
    } else {
      print("Proceed")
    }
    filedir = paste0(sradir,'/',x[i],'.sra')
    if(file.exists(filedir)){
      print("file exists!")
    } else {
      print("let's download...")
      getSRAfile(in_acc = x[i], sra_con = con, fileType = 'sra', 
                 destDir = sradir, makeDirectory = TRUE, 
                 ascpCMD = 'ascp -QT -l 300m -i /usr/local/aspera/connect/etc/asperaweb_id_dsa.putty')
    }
  }
}

print("Done!")
