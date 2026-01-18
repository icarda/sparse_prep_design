df <- read.csv("FFMPYT-26 Entries.csv")
ped <- read.csv("FFMPYT-26 Pedigree Matrix.csv.gz", row.names = 1)

per.plot  <- 35 # Seed gr per plot
all.loc   <- 7  # Total number of locations
all.cross <- 51 # Test entries cross locations
prep.loc  <- 54 # P-Rep test entries per location
blocks    <- 2  # Augmented blocks per location

df$Family <- sub("^((?:[^-]*-){1}[^-]*).*", "\\1", df$SELHIS)

### allocate test entries for cross locations category #########################

packs <- all.loc
allocated <- 0

repeat {
  # filter test entries with enough seeds
  min.need <- per.plot * packs
  
  cross.df <- df[df$Available >= min.need,]
  
  # check condition at the end
  if (nrow(cross.df) >= all.cross) {
    if (packs != all.loc) {
      warning(paste((nrow(cross.df) - allocated), "entries are present in", packs, "locations."))
      warning("Seed shortages detected: entries with insufficient seed for all locations will be randomly replaced by commercial checks where needed to fill the gaps.")
    }
    break
  } else {
    warning(paste((nrow(cross.df) - allocated), "entries are present in", packs, "locations."))
    allocated <- nrow(cross.df)
    packs <- packs - 1
  }
}

# iteratively exclude entries with the highest pedigree similarity 
# to retain a core set maximizing genetic diversity.
cross.ped <- ped[rownames(ped) %in% cross.df$Code, colnames(ped) %in% cross.df$Code]

cross.rank <- sort(unique(unlist(cross.ped)), decreasing = TRUE)[-1]

for (i in nrow(cross.df):(all.cross+1)) {
  found <- 0
  j <- 1
  
  while (found == 0) {
    matches <- which(cross.ped == cross.rank[j], arr.ind = TRUE)
    found <- nrow(matches)
    j <- j + 1
  }
  
  del.entry <- rownames(matches)[sample(1:nrow(matches), 1)]
  
  cross.ped <- cross.ped[rownames(cross.ped) != del.entry, colnames(cross.ped) != del.entry]
}

cross.df <- cross.df[cross.df$Code %in% row.names(cross.ped), ]

cross.df$Location <- "All"

cross.df$Theme <- "Cross loc test entries"


### allocate test entries for the p-rep category ###############################

df <- df[!(df$Code %in% cross.df$Code), ]

# filter test entries with enough seeds
min.need <- per.plot * blocks

prep.df <- df[df$Available >= min.need,]

# iteratively exclude entries with the highest pedigree similarity 
# to retain a core set maximizing genetic diversity.
prep.ped <- ped[rownames(ped) %in% prep.df$Code, colnames(ped) %in% prep.df$Code]

prep.rank <- sort(unique(unlist(prep.ped)), decreasing = TRUE)[-1]

for (i in nrow(prep.df):(all.loc * prep.loc + 1)) {
  found <- 0
  j <- 1
  
  while (found == 0) {
    matches <- which(prep.ped == prep.rank[j], arr.ind = TRUE)
    found <- nrow(matches)
    j <- j + 1
  }
  
  del.entry <- rownames(matches)[sample(1:nrow(matches), 1)]
  
  prep.ped <- prep.ped[rownames(prep.ped) != del.entry, colnames(prep.ped) != del.entry]
}

prep.df <- prep.df[prep.df$Code %in% row.names(prep.ped), ]

prep.df <- prep.df[order(prep.df$Family), ]

prep.df$Location <- rep(1:all.loc, length.out = nrow(prep.df))

prep.df$Theme <- "P-Rep test entries"


### allocate un-replicated test entries to locations ###########################

test.df <- df[!(df$Code %in% c(cross.df$Code, prep.df$Code)), ]

test.df <- test.df[order(test.df$Family), ]

test.df$Location <- rep(1:all.loc, length.out = nrow(test.df))

test.df$Theme <- "Unreplicated test entries"


### add check entries ##########################################################

chk <- c("Rihane-03", "Khnata", "Chiffaa", "VMorales", "FFM2401147", "FFM220877", "Taffa", "Ksaiba")

check.df <- data.frame(Code = chk,
                       SELHIS = chk,
                       Available = 1000,
                       Family = chk,
                       Location = "All",
                       Theme = "Check entries")

### compile all groups together in the expected order for the lines code map ###

map <- rbind(prep.df, test.df)

map <- map[order(map$Location, map$Theme, map$Code), ]

map <- rbind(cross.df, map, check.df)

map$`Design ID` <- 1:nrow(map)

write.csv(map[,c("Location", "Theme", "Design ID", "Code", "SELHIS", "Available", "Family")], "entry_code_map.csv", row.names = FALSE)
