# Tests for 'tablesgg' package# 21 Nov 2020 / Richard Raubertas# 27 Nov 2020 : Change list 'tablesggOpt' to function 'tablesggOpt()'.  (Now #               diverging from 'tests_1.r'.)# 02 Feb 2021 : Replace 'grProps' with 'grSpecs'.# 22 Feb 2021 : Run tests with 'allowMarkdown=FALSE'.  More 'tablesggOpt' tests.# 04 Mar 2021 : Orthogonality of styles and scale.# 25 Apr 2021 : More thorough test of 'scale'.if (!get0("IS_PKG", ifnotfound=TRUE)) {  pdf(paste0("tests_1n2.", Sys.Date(), ".pdf"))}HEADLESS <- (!interactive())#=====# 'as.dfObj(NULL, <class>)' creates empty objects of the specified class.stopifnot(is.data.frame(as.tblEntries(NULL)))stopifnot(is.data.frame(as.tblBlocks(NULL)))stopifnot(is.data.frame(as.prEntries(NULL)))stopifnot(is.data.frame(prEntries(as.tblEntries(NULL))))stopifnot(is.data.frame(as.prBlocks(NULL)))stopifnot(is.data.frame(prBlocks(as.tblBlocks(NULL))))stopifnot(is.data.frame(as.prHvrules(NULL)))stopifnot(is.data.frame(prHvrules(as.tblBlocks(NULL))))#=====# Check consistency of 'element_*' functions and 'grSpecs'.stopifnot(all(row.names(grSpecs("entry")) %in%               setdiff(names(element_entry()), "inherit.blank")))stopifnot(all(row.names(grSpecs("block")) %in%               setdiff(names(element_block()), "inherit.blank")))stopifnot(all(row.names(grSpecs("hvrule")) %in%               setdiff(names(element_hvrule()), "inherit.blank")))             #=====# Setting/restoring package options.oldopt <- tablesggOpt()oldopt1 <- tablesggSetOpt(entryStyle=styles_pkg$entryStyle_pkg_2)plt <- plot(iris2_tab, title="Changed default entry style")stopifnot(identical(attr(entries(plt), "style"), styles_pkg$entryStyle_pkg_2))# Change the values of multiple options.oldopt2 <- tablesggSetOpt(list(hvruleStyle=styles_pkg$hvruleStyle_pkg_base,                                plot.margin=c(5, 5, 5, 5)))stopifnot(identical(tablesggOpt("plot.margin"), c(5, 5, 5, 5)))# Restore previous options, two ways.tablesggSetOpt(oldopt)stopifnot(identical(oldopt, tablesggOpt()))tablesggSetOpt(c(oldopt2, oldopt1))stopifnot(identical(oldopt, tablesggOpt()))# Restore factory-fresh options.tablesggOpt(reset=TRUE)tablesggSetOpt(allowMarkdown=FALSE)  # markdown tested in a different scriptrm(oldopt, oldopt1, oldopt2, plt)#=====# Examples/tests based on iris data.#-----stopifnot(require(tables, quietly=TRUE))tbl <- tabular(Species*Heading()*value*Format(digits=2)*(mean + sd) ~                Heading("Flower part")*flower_part*Heading()*direction,                data=iris2)ttbl <- textTable(tbl, title="The iris data")stopifnot(identical(ttbl, textTable(ttbl)))# Test 'tblEntries', 'rowheadInside', 'mergeRuns'.etbl <- tblEntries(ttbl)stopifnot(identical(etbl, as.tblEntries(etbl)))etbl2 <- tblEntries(ttbl, rowheadInside=TRUE)etbl3 <- tblEntries(ttbl, mergeRuns=FALSE)etbl4 <- tblEntries(ttbl, mergeRuns=FALSE, rowheadInside=TRUE)# Converting tblEntries back to textTable:stopifnot(identical(etbl, tblEntries(textTable(etbl))))stopifnot(identical(textTable(etbl), textTable(etbl3)))#stopifnot(identical(textTable(etbl), textTable(etbl2)))   # FALSE#  ('rowheadInside' changes rowhead entry text)stopifnot(identical(textTable(etbl2), textTable(etbl4)))# Test 'adim'.stopifnot(identical(adim(ttbl), c(10, 6)))stopifnot(identical(adim(ttbl), adim(etbl)),           identical(adim(ttbl), adim(etbl3)),          # rowheadInside changes augmented row-col grid:          identical(adim(ttbl) + c(3, -1), adim(etbl2)),           identical(adim(etbl) + c(3, -1), adim(etbl4)))# Test 'arow', 'acol'.plt <- plot(ttbl)stopifnot(identical(arow(ttbl, "foot"), numeric(0)),           identical(arow(ttbl, "foot"), arow(plt, "foot")),           identical(acol(ttbl, "foot"), seq(1, 6, by=1)),           identical(acol(ttbl, "foot"), acol(plt, "foot")),          identical(arow(ttbl, "rowhead")[3], 7),          identical(acol(plt, "rowhead_right"), 2.5))# Test subscripting a 'textTable'.stopifnot(identical(ttbl, ttbl[, ]),           identical(ttbl, ttbl[TRUE, TRUE]),           adim(ttbl[FALSE, FALSE]) == c(0, 0),           adim(ttbl[0, 0]) == c(0, 0))plt1 <- plot(ttbl)plt2 <- plot(ttbl[-arow(ttbl, "colhead")[1], ])  # Remove 'Flower part' col layerplt3 <- plot(ttbl[-arow(ttbl, "colhead")[1],                   c(1, 2, 5, 6, 3, 4)])  # Also switch order of sepal/petal colsstopifnot(identical(adim(plt1), adim(ttbl)),           identical(adim(plt2), adim(plt1)-c(1,0)),           identical(adim(plt2), adim(plt3)))if (!HEADLESS) {print(plt1, position=c(0.5, 1))print(plt2, position=c(0.5, 0.5), newpage=FALSE)print(plt3, position=c(0.5, 0), newpage=FALSE)}# Check 'rowhead_inside', 'undo_rowhead_inside'.chk <- c("id", "part", "headlayer", "level_in_layer", "type", "arow1", "arow2",          "acol1", "acol2", "enabled", "multirow", "multicolumn", "hjust")# (Don't expect text to match, b/c group labels were modified.  Also row order # may change.)etbl1b <- undo_rowhead_inside(etbl2)stopifnot(sort(row.names(etbl)) == sort(row.names(etbl1b)),           isTRUE(all.equal(etbl[, chk], etbl1b[row.names(etbl), chk])))etbl3b <- undo_rowhead_inside(etbl4)stopifnot(sort(row.names(etbl3)) == sort(row.names(etbl3b)),           isTRUE(all.equal(etbl3[, chk], etbl3b[row.names(etbl3), chk])))# Test 'tblParts'.  Result shouldn't depend on 'mergeRuns' or 'rowheadInside'.parts <- tblParts(ttbl)plt1 <- plot(ttbl)plt2 <- plot(ttbl, rowheadInside=TRUE)plt3 <- plot(ttbl, mergeRuns=FALSE)plt4 <- plot(ttbl, rowheadInside=TRUE, mergeRuns=FALSE)stopifnot(identical(parts, tblParts(plt1)),           identical(parts, tblParts(plt2)),          identical(parts, tblParts(plt3)),          identical(parts, tblParts(plt4)))stopifnot(identical(parts, tblParts(etbl)))# Test 'ids'.stopifnot(identical(ids(ttbl), rownames(tblParts(ttbl))),           identical(ids(plt, type="block"), row.names(blocks(plt))),           identical(ids(plt, type="block", enabledOnly=FALSE),                     row.names(blocks(plt, enabledOnly=FALSE))),           identical(ids(plt, type="entry"),                     elements(plt, type="entry")[, "id"]))# Test 'tblBlocks' (but not 'rowgroupSize' here).blks <- tblBlocks(ttbl)blks1 <- tblBlocks(etbl)stopifnot(identical(blks, blks1))stopifnot(identical(blks, as.tblBlocks(blks)))blks2 <- tblBlocks(etbl2)blks3 <- tblBlocks(etbl3)blks4 <- tblBlocks(etbl4)# 'tblBlocks' shouldn't depend on 'mergeRuns'.stopifnot(identical(blks1, blks3), identical(blks2, blks4))# 'rowheadInside' eliminates 3 standard blocks ('rowhead', 'body', # and 'rowhead_and_stub').stopifnot((dim(blks1) - c(3, 0)) == dim(blks2))# Test 'prHvrules'.  Result shouldn't depend on 'mergeRuns', since blocks don't.hvr <- prHvrules(blks)hvr2 <- prHvrules(blks2)hvr3 <- prHvrules(blks3)hvr4 <- prHvrules(blks4)stopifnot(identical(hvr, hvr3), identical(hvr2, hvr4))hvr <- prHvrules(blks, style=styles_pkg$hvruleStyle_pkg_null)  # all hvrules disabledstopifnot(sum(hvr$enabled) == 0, identical(hvr, as.prHvrules(hvr)))# Test plot creation.pr <- prEntries(etbl)prtbl <- prTable(pr)plt <- plot(prtbl)stopifnot(identical(prtbl, prTable(plt),           identical(prtbl, prTable(plot(ttbl)))))#.....# Manually adding hvrules.plt <- plot(ttbl)#-- Explicitly specify row and column numbers:plt2 <- addHvrule(plt, id="test", direction="hrule",                   arows=1.5, acols=c(2, 5))props(plt2, id="test") <- element_hvrule(color="blue", size=1)#-- Or specify them relative to table parts, using helper functions:plt2 <- addHvrule(plt2, id="test2", dir="vrule",                   acols=max(acol(plt, "body"))-0.5,  # btwn last two columns ...                  arows=arow(plt, "body"),  # ... and spanning the table body                  props=element_hvrule(color="red", linetype=1))# Updating style should not change manually added hvrules:plt3 <- update(plt2, hvruleStyle=styles_pkg$hvruleStyle_pkg_base)stopifnot(identical(elements(plt2, type="hvrule")[c("test", "test2"), ],                     elements(plt3, type="hvrule")[c("test", "test2"), ]))if (!HEADLESS) {print(plt, vpx=0.25, vpy=0.75)print(plt2, vpx=0.75, vpy=0.75, newpage=FALSE)print(plt3, vpx=0.25, vpy=0.25, newpage=FALSE)}# Manually adding blocks.plt4 <- addBlock(plt3, id="blktest", arows=arow(plt3, "rowblock/A/2/2"),                  acols=acol(plt3, "body"), props=element_block(fill="green1",                  border_color="orange", border_size=1, enabled=TRUE))if (!HEADLESS) {print(plt4, vpx=0.75, vpy=0.25, newpage=FALSE)}#.....# Make sure 'pr*' functions can handle 0-row inputs.temp1 <- as.prEntries(prEntries(etbl[0, , drop=FALSE]))temp2 <- as.prEntries(prEntries(etbl[0, , drop=FALSE],                                 style=styles_pkg$entryStyle_pkg_1))temp3 <- as.prEntries(prEntries(etbl[0, , drop=FALSE], scale=0.8))stopifnot(nrow(temp1) == 0, nrow(temp2) == 0, nrow(temp3) == 0)temp1 <- as.prBlocks(prBlocks(blks[0, , drop=FALSE]))temp2 <- as.prBlocks(prBlocks(blks[0, , drop=FALSE],                               style=styles_pkg$blockStyle_pkg_1))temp3 <- as.prBlocks(prBlocks(blks[0, , drop=FALSE], scale=0.8))stopifnot(nrow(temp1) == 0, nrow(temp2) == 0, nrow(temp3) == 0)temp1 <- as.prHvrules(hvr[0, , drop=FALSE])# To change hvrule style, need to provide blocks, not prHvrules:tools::assertError(update.prObj(hvr[0, , drop=FALSE],                                 style=styles_pkg$hvruleStyle_pkg_1))temp2 <- as.prHvrules(prHvrules(blks[0, , drop=FALSE],                                 style=styles_pkg$hvruleStyle_pkg_1))temp3 <- update.prObj(hvr[0, , drop=FALSE], scale=0.8)stopifnot(nrow(temp1) == 0, nrow(temp2) == 0, nrow(temp3) == 0)#.....if (!HEADLESS) {plt1 <- plot(ttbl, subtitle="Default display")plt2 <- plot(ttbl, rowheadInside=TRUE, subtitle="rowheadInside = TRUE")plt3 <- plot(ttbl, mergeRuns=FALSE, subtitle="mergeRuns = FALSE")plt4 <- plot(ttbl, mergeRuns=FALSE, rowheadInside=TRUE,              subtitle="mergeRuns = FALSE, rowheadInside = TRUE")print(plt1, position=c("left", "top"))print(plt2, position=c("right", "bottom"), newpage=FALSE)print(plt3, position=c("left", "bottom"), newpage=FALSE)print(plt4, position=c("right", "top"), newpage=FALSE)}#.....# Changing styles.# Start with session default from 'tablesggOpt':stopifnot(identical(attr(entries(plt2), "style"), tablesggOpt("entryStyle")))plt2b <- update(plt2, entryStyle=styles_pkg$entryStyle_pkg_base)stopifnot(identical(attr(entries(plt2b), "style"),                     styles_pkg$entryStyle_pkg_base))if (!HEADLESS) {print(plt2, position=c("left", "top"))print(plt2b, position=c("right", "top"), newpage=FALSE)}plt2b2 <- update(plt2b, entryStyle=tablesggOpt("entryStyle")) # reverse style changestopifnot(identical(prTable(plt2b2), prTable(plt2)))plt2d <- update(plt2, entryStyle=styles_pkg$entryStyle_pkg_null)# 'entryStyle_pkg_null' matches nothing, so plot should have the base style ...if (!HEADLESS) {print(plt2d, position=c("left", "bottom"), newpage=FALSE)}# ... but 'style_row' is all NA.# Default style should match some (but not necessarily all) elements.  Base # style should match all elements.  Null style should match no elements.stopifnot(!all(is.na(entries(plt2, enabledOnly=FALSE)$style_row)))stopifnot(!any(is.na(entries(plt2b, enabledOnly=FALSE)$style_row)))stopifnot(all(is.na(entries(plt2d, enabledOnly=FALSE)$style_row)))plt2c <- update(plt2, hvruleStyle=styles_pkg$hvruleStyle_pkg_base)if (!HEADLESS) {print(plt2c, position=c("right", "bottom"), newpage=FALSE)}plt2c2 <- update(plt2c, hvruleStyle=tablesggOpt("hvruleStyle")) # reverse style changestopifnot(identical(prTable(plt2c2), prTable(plt2)))plt2d <- update(plt2, hvruleStyle=styles_pkg$hvruleStyle_pkg_null)# Default style should match some (but not necessarily all) elements.  Base # style should match all elements.  Null style should match no elements.stopifnot(!all(is.na(hvrules(plt2, enabledOnly=FALSE)$style_row)))stopifnot(!any(is.na(hvrules(plt2c, enabledOnly=FALSE)$style_row)))stopifnot(all(is.na(hvrules(plt2d, enabledOnly=FALSE)$style_row)))plt2c <- update(plt2, blockStyle=styles_pkg$blockStyle_pkg_base)# blockStyle_pkg_base and default (blockStyle_pkg_1) are currently the same.plt2d <- update(plt2, blockStyle=styles_pkg$blockStyle_pkg_null)# Base style should match all blocks.  Null style should match no blocks.stopifnot(!all(is.na(blocks(plt2, enabledOnly=FALSE)$style_row)))stopifnot(!any(is.na(blocks(plt2c, enabledOnly=FALSE)$style_row)))stopifnot(all(is.na(blocks(plt2d, enabledOnly=FALSE)$style_row)))#.....# Styles and scale should be orthogonal:  result shouldn't depend on # order of updating.# Default 'update' args change nothing:stopifnot(identical(prTable(plt2), prTable(update(plt2))))# Different update paths should lead to the same result:plt2b <- update(plt2, entryStyle=styles_pkg$entryStyle_pkg_base)plt2c <- update(plt2, scale=0.7)plt2bc <- update(plt2, entryStyle=styles_pkg$entryStyle_pkg_base, scale=0.7)stopifnot(identical(prTable(plt2bc), prTable(update(plt2b, scale=0.7))))stopifnot(identical(prTable(plt2bc), prTable(update(plt2c,                                    entryStyle=styles_pkg$entryStyle_pkg_base))))#.....# Test use of 'scale'.plt <- plot(tbl, scale=1.0, title="Table at natural size (scale=1.0)")plt2 <- plot(tbl, scale=0.8, title="Small version (scale=0.8)")plt3 <- plot(tbl, scale=1.2, title="Large version (scale=1.2)")# Make sure sizes reflect scaling.pltmgn <- attr(plt, "plot.margin")adj <- c(sum(pltmgn[c(2,4)]), sum(pltmgn[c(1,3)]))sz <- pltdSize(plt) - adjsz2 <- pltdSize(plt2) - adjsz3 <- pltdSize(plt3) - adjstopifnot(all(abs(sz2/sz - 0.8) < 0.02), all(abs(sz3/sz - 1.2) < 0.03))# Multiple tables on a page, adjusting position.  Modify table display with # ggplot options.if (!HEADLESS) {print(plt, position=c("center", "top"))plt2 <- plot(tbl, scale=0.8,              title=c("Small version (scale=0.8), with borders:",                      "panel (blue), plot (red)")) +         theme(panel.background=element_rect(color="blue", size=1),               plot.background=element_rect(color="red"))  # add bordersprint(plt2, position=c(0.03, 0.45), newpage=FALSE)print(plt3, position=c(0.97, 0.0), newpage=FALSE)}rm(pltmgn, adj, sz, sz2, sz3)#.....# Add reference marks, using either 'addRefmark' or 'props<-'.# Using text-based 'addRefmark' adds marks to all instances of "sd". ttbl2 <- textTable(tbl, title="The iris data", foot="sd = standard deviation")plt2 <- plot(ttbl2)ttbl2a <- addRefmark(ttbl2, mark="a", before="^sd =", after="^sd$")ttbl2a <- update(ttbl2a, subtitle="'addRefmark' applied to textTable")plt2a <- plot(ttbl2a)# Unicode refmarks generate lots of grid warnings ("font metrics unknown for # Unicode character"), but seem to display properly#plt2b <- plot(ttbl2, subtitle="'addRefmark' applied to pltdTable")#plt2b <- addRefmark(plt2b, mark="\u2020", before="^sd =", after="^sd$")# Using 'propsd<-' can be more selective:  only the first instance of "sd" in # the row header.plt2c <- plot(ttbl2,               subtitle="Reference marks via 'propsd<-'")propsd(plt2c, subset=(part == "rowhead" & partcol == 2 & partrow == 2)) <-   element_refmark(mark="*", side="after")propsd(plt2c, subset=(part == "foot")) <-   element_refmark(mark="*", side="before")# Or use 'propsa<-' with 'hpath' to specify the instance of "sd":plt2d <- plot(ttbl2,               subtitle="Reference marks via 'propsa<-'")propsa(plt2d, arows=arow(plt2d, hpath=c("setosa", "sd")), acols=2) <-   element_refmark(mark="**", side="after")propsa(plt2d, arows=arow(plt2d, "foot")[1]) <-   element_refmark(mark="**", side="before")if (!HEADLESS) {print(plt2, position=c("left", "top"))print(plt2a, position=c("right", "top"), newpage=FALSE)#print(plt2b, position=c("left", "bottom"), newpage=FALSE)print(plt2c, position=c("left", "bottom"), newpage=FALSE)print(plt2d, position=c("right", "bottom"), newpage=FALSE)}#.....rm(tbl, ttbl, etbl, etbl2, etbl3, etbl4, chk, etbl1b, etbl3b,    blks, blks1, blks2, blks3, blks4, temp1, temp2, temp3, parts,    hvr, hvr2, hvr3, hvr4, pr, prtbl, plt, plt1, plt2, plt3, plt4,    plt2b, plt2b2, plt2c, plt2d, plt2c2,    ttbl2, ttbl2a, plt2a)   #===== Taken from 'tests_2.r':#=====# Plot a listing of the iris data.ttbl <- textTable(head(iris, 11), row.names="", title="Part of the iris data")plt <- plot(ttbl)stopifnot(identical(adim(ttbl), adim(plt)))#-----# Updating 'prTable' object (scale or styles only).plt2 <- update(plt, scale=0.8)temp <- update(plt2, scale=1.0)  # reverse previous stepstopifnot(isTRUE(all.equal(prTable(plt), prTable(temp))))stopifnot(isTRUE(all.equal(pltdSize(plt), pltdSize(temp))))# Test row groups, and display of blocks.pltdtbl2 <- plot(ttbl, rowgroupSize=4, subtitle=c("Rows grouped by fours",                 "Highlight the block containing the 2nd group"))propsd(pltdtbl2, subset=(subtype == "G" & group_in_level == 2)) <-        element_block(enabled=TRUE)if (!HEADLESS) {print(plt, position=c("center", "top"))print(pltdtbl2, position=c("center", "bottom"), newpage=FALSE)}#-----# Subscripting 'textTable's, edge cases (no body rows and/or no body columns):arbody <- arow(ttbl, "body")acbody <- acol(ttbl, "body")# Make sure 'tblParts' can reconstruct part dimensions from just the # entries.stopifnot(identical(tblParts(ttbl[-arbody,]), tblParts(tblEntries(ttbl[-arbody,]))))stopifnot(identical(adim(ttbl[-arbody,]), adim(tblEntries(ttbl[-arbody,]))))stopifnot(identical(tblParts(ttbl[,-acbody]), tblParts(tblEntries(ttbl[,-acbody]))))stopifnot(identical(adim(ttbl[,-acbody]), adim(tblEntries(ttbl[,-acbody]))))stopifnot(adim(ttbl[-arbody,-acbody]) == c(0, 0))stopifnot(identical(tblParts(ttbl[-arbody,-acbody]), tblParts(tblEntries(ttbl[-arbody,-acbody]))))stopifnot(identical(adim(ttbl[-arbody,-acbody]), adim(tblEntries(ttbl[-arbody,-acbody]))))tools::assertWarning(plt0 <- plot(ttbl[-arbody,-acbody]))  # NULL, with warningstopifnot(is.null(plt0))if (!HEADLESS) {print(plot(ttbl[-arbody,], foot="(plotting ttbl[-arbody, ])"),       position=c("right", "top"))  # annotation, colhead onlyprint(plot(ttbl[,-acbody], foot="(plotting ttbl[, -acbody])"),      position=c("left", "center"), newpage=FALSE)  # annotation, rowhead only}blks <- tblBlocks(ttbl[-arbody, -acbody])  # Full set of blocks, all emptystopifnot(all(blks$nr == 0), all(blks$nc == 0),           all(is.na(blks$arow1)), all(is.na(blks$arow2)),           all(is.na(blks$acol1)), all(is.na(blks$acol2)))hvr <- prHvrules(blks)  # 0-row prHvrules objectstopifnot(nrow(hvr) == 0, identical(hvr, as.prHvrules(hvr)))hvr2 <- prHvrules(blks[-arbody, ])  # 0-row prHvrules objectstopifnot(nrow(hvr2) == 0, identical(hvr2, as.prHvrules(hvr2)))#.....# Now with row header labels.  (Now the table has a stub, so table without a # body is plot-able.)ttbl <- textTable(head(iris, 11), row.names="Obs. #",                   title="Part of the iris data")pltdtbl <- plot(ttbl)# Test row groups.pltdtbl2 <- plot(ttbl, rowgroupSize=4, subtitle="Rows grouped by fours")if (!HEADLESS) {print(pltdtbl, position=c("center", "top"))print(pltdtbl2, position=c("center", "bottom"), newpage=FALSE)}# Edge case:arbody <- arow(ttbl, "body")acbody <- acol(ttbl, "body")plt0 <- plot(ttbl[-arbody, -acbody], foot="(plotting ttbl[-arbody, -acbody])")if (!HEADLESS) {print(plot(ttbl[-arbody,], foot="(plotting ttbl[-arbody, ])"),       position=c("right", "top"))  # annotation, rowheadLabels, colhead onlyprint(plot(ttbl[, -acbody], foot="(plotting ttbl[, -acbody])"),      position=c("left", "bottom"), newpage=FALSE) # annotation, rowheadLabels, rowhead onlyprint(plt0, position=c("left", "top"), newpage=FALSE)  # annotation, rowheadLabels}#-----if (!get0("IS_PKG", ifnotfound=TRUE)) {  dev.off()}rm(ttbl, blks, hvr, hvr2, plt, plt0, plt2, temp, pltdtbl2, pltdtbl,    arbody, acbody)rm(HEADLESS)