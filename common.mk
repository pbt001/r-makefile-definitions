## File:    common.mk - to be included in Makefile(s)
## Purpose: Define gnu make rules for R, knitr, Rmarkdown and Sweave 
## Usage: Place file in a directory such as ~/lib and include with
##         include ~/lib/common.mk
##         at the bottom of Makefile
##         To override any definitions place them after the include statement
## NB: if using makepp then ~ is not recognized but the following is OK
##         include ${HOME}/lib/common.mk

## For help after including common.mk in Makefile: run
##         $  make help

## Changelog: None until Frid 2015-02-06 at 15:40:21
##            On Frid 2015-02-06
##            1) Added Rmarkdown rules
##               run $ make help-rmarkdown
##            2) Added stitch rules

## TODO: 1) proper documentation            2015-02-06 at 15:41:44
##       2) make knit more system independent
##	 3) should put up on github
##       4) sort out rough edges
## Question: Should I always run 'knit -n -o' to get .tex and run
##           through latexmk as that will really specify dependencies
##           properly

## For Sweave I've changed the default to knit as that's what I
## usually want but to use Sweave then use the following three lines
## at end of Makefile
## include ~/lib/common.mk
## KNIT    = $(R) CMD Sweave
## KNIT_FLAGS = 

## program defs:
##MAKE      = make

## general help -----------------------------------------------------

.PHONY: help
help:
	@echo ""
	@echo Some simple help can be obtained with
	@echo ""
	@echo make help-r
	@echo make help-rmarkdown
	@echo make help-stitch
	@echo make help-slides

# latex pattern rules  ---------------------------------------------------

## can be used to convert simple latex to .rtf file for MS word
LATEX2RTF     = latex2rtf

## cross platform way to run latex properly but best to run through R
LATEXMK       = $(R) CMD latexmk
LATEXMK_FLAGS = -pdf
## rubber - latexmk alternative on linux systems only
RUBBER    = $(R) CMD rubber
RUB_FLAGS = -d

## R pattern rules -------------------------------------------------
.PHONY: help-r
help-r:
	@echo ""
	@echo Just one major rule to produce .Rout but can stitch .R file too
	@echo ""
	@echo $$ make myFile.R
	@echo will produce 'myFile.Rout' using R CMD BATCH --vanilla myFile.R
	@echo but you can change options with something like
	@echo $$ R_OPTS=--no-restore-history make myFile.R
	@echo ""
	@echo To stitch file \(like RStudio\) just do one of the following:
	@echo make myFile.pdf
	@echo make myFile.docx
	@echo make myFile.html
	@echo NB: This assumes you don\'t have files like myFile.\{Rmd,Rnw,tex\} etc present,
	@echo ".   only 'myFile.R'"
	@echo "    So good practice is to use different names for reports and analysis"

R         = R
RSCRIPT   = Rscript
R_FLAGS   = CMD BATCH
##R_OPTS    = --no-save --no-restore --no-restore-history --no-readline
R_OPTS    = --vanilla
RWEAVE    = $(R) CMD Sweave
RWEAVE_FLAGS =

%.Rout: %.R
	@echo Job $<: started at `date`
	${R} ${R_FLAGS} ${R_OPTS} $< 
	@echo Job $<: finished at `date`

## knit (and Sweave) pattern rules --------------------------------------

## KNIT     = knit
KNIT     = /usr/lib64/R/library/knitr/bin/knit
KNIT_FLAGS = -n -o
## note - may need to use this (or similar) instead if knit is not in path
## KNIT = /usr/lib/R/library/knitr/bin/knit

%.R: %.Rnw
	${R} CMD Stangle $<
%.tex: %.Rnw
	${KNIT} $< -n -o $@
%.pdf: %.Rnw
	${KNIT} $<
%.pdf : %.tex
	${LATEXMK} ${LATEXMK_FLAGS} $<
##	${RUBBER} ${RUB_FLAGS} $<
## %.pdf: %.Rnw
## 	${RWEAVE} ${RW_FLAGS} $<
## 	${RUBBER} ${RUB_FLAGS} $<

%.rtf: %.tex
	${LATEX2RTF} ${L2R_FLAGS} ${@:.rtf=}

## wonder if this would cause a conflict with rmarkdown - shouldn't as
## long as R markdown rules come after this and possible override with
## explicit definitions?

%.md: %.Rmd
	${KNIT} $@ ${KNIT_OPTS} $<

## pandoc pattern rules  ----------------------------------------------

PANDOC = pandoc
PANDOC_OPTS = -s

%.pdf: %.md
	${PANDOC} ${PANDOC_OPTS} $< -o $@
%.docx: %.md
	${PANDOC} ${PANDOC_OPTS} $< -o $@

## stitch an R file using knitr --------------------------------------

## finding rmarkdown seems to be a better option than knitr  
## both on CRAN now so easier to install

.PHONY: help-stitch
help-stitch:
	@echo ""
	@echo To stitch file \(like RStudio\) just do one of the following:
	@echo make myFile.pdf
	@echo make myFile.docx
	@echo make myFile.html
	@echo NB: This assumes you don\'t have files like myFile.\{Rmd,Rnw,tex\} etc present,
	@echo ".   only 'myFile.R'"
	@echo "    So good practice is to use different names for reports and analysis"

%.pdf: %.R
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.pdf=.R}\", \"pdf_document\")"
%.html: %.R
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.html=.R}\", \"html_document\")"
## this borrows line from below
%.docx: %.R
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.docx=.R}\", \"word_document\")"

## Rmarkdown pattern rules  --------------------------------------------------

## generating pdf, docx, html other from Rmarkdown/sweave
## Note: $< does not appear to work whereas ${@:.pdf=.Rmd} does even
##       though I think they should be identical
.PHONY: help-rmarkdown
help-rmarkdown:
	@echo ""
	@echo You can easily set up a .PHONY target to produce all output
	@echo format files specified at the top of the .Rmd file
	@echo See the file ~/lib/common.mk file and simply
	@echo 1\) set up a phony target with something like
	@echo .PHONY: rmarkdown-all
	@echo rmarkdown-all: myfile.Rmd
	@echo 2\) insert an Rscript command eg.
	@echo '   a\) insert pdf command from ~/lib/common.mk'
	@echo '   b\) replace \"pdf_document\" with \"all\"'

%.pdf: %.Rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.pdf=.Rmd}\", \"pdf_document\")"
%.pdf: %.rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.pdf=.rmd}\", \"pdf_document\")"
%.html: %.Rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.html=.Rmd}\", \"html_document\")"
%.html: %.rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.html=.rmd}\", \"html_document\")"
%.docx: %.Rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.docx=.Rmd}\", \"word_document\")"
%.docx: %.rmd
	${RSCRIPT} ${R_OPTS} -e "library(rmarkdown);render(\"${@:.docx=.rmd}\", \"word_document\")"

## uncomment next line if required for debugging latex 
## .PRECIOUS: .tex 

## Course slides using knit/beamer ----------------------------------------

## Course slides, notes, etc etc using knitr
## Based on Douglas Bates lme course notes course code
## but added the slides/article styles as per happymutant website

.PHONY: help-slides
help-slides:
	@echo ""  
	@echo Slide file types used in Makefile with knitr
	@echo Note that base file is of form *-src.Rnw
	@echo ""  
	@echo "       %-Slides.\{tex,pdf\}: Slides for presentation"
	@echo "       %-2a4.\{tex,pdf\}: Handouts - 2 slides per A4 page"
	@echo "       %-4a4.\{tex,pdf\}: Handouts - 4 slides per A4 page"
	@echo "       %-Notes.\{tex,pdf\}: Notes in article style - not slides"
	@echo ""
	@echo "NB: %D.\{tex,pdf\}, %N.\{tex,pdf\} and  %H.\{tex,pdf\}"
	@echo "    produced as intermediate files PREVIOUSLY"
	@echo "NB2: Notes needs rewriting once courses over"
	@echo "     since knitr does not like old method"

## produce latex file with knitr but note that it does not have
## document class - perhaps it should and use perl etc to modify it
%-src.tex: %-src.Rnw

## Presentation pdf - produced via R CMD latexmk ...
## %-Slides.pdf requires %-src.Rnw WITHOUT  \documentclass top line
# %-Present.tex: %-src.tex
# 	@echo "\\documentclass[dvipsnames,pdflatex,ignorenonframetext]{beamer}" > $@
# 	@echo "\\input{"$*-src"}" >> $@
# 	@echo "\\end{document}" >> $@

## Presentation pdf - produced via R CMD latexmk ...
## %-Slides.pdf requires %-src.Rnw WITHOUT  \documentclass top line
%-Present.Rnw: %-src.Rnw
	sed -e s/~~MY~BEAMER~~OPTIONS~~/dvipsnames,pdflatex,ignorenonframetext/g $< > $@

## Presentation syntax
%-syntax.R: %-src.Rnw
	R -e 'library(knitr);knit("$<", tangle=TRUE)'
	mv ${<:.Rnw=.R} $@

## Slides - one per page - produced via R CMD latexmk ...
## dropped handout option!
%-Slides.tex: %-Present.tex
	sed -e s/dvipsnames,pdflatex,ignorenonframetext/ignorenonframetext,dvipsnames,pdflatex,handout/g $< > $@

##%-Slides.tex: %-src.tex
##	@echo "\\documentclass[ignorenonframetext,dvipsnames,pdflatex,handout]{beamer}" > $@
##	@echo "\\input{"$*-src"}" >> $@
##	@echo "\\end{document}" >> $@

# A4 paper - 2 per slides page
%-2a4.tex: %-Slides.pdf
	@echo "\\documentclass[a4paper]{article}" > $@
	@echo "\\usepackage{pdfpages}" >> $@
#	@echo "\\usepackage{pgfpages}" >> $@
#	@echo "\\pgfpagesuselayout{2 on 1}[a4paper,border shrink=5mm]" >> $@
	@echo "\\begin{document}" >> $@
	@echo "\\includepdf[nup=1x2,pages=-]{"$*"-Slides.pdf}" >> $@
#	@echo "\\includepdf{"$*"H.pdf}" >> $@
	@echo "\\end{document}" >> $@

# A4 paper - 4 slides per page
%-4a4.tex: %-Slides.pdf
	@echo "\\documentclass[a4paper,landscape]{article}" > $@
	@echo "\\usepackage{pdfpages}" >> $@
	@echo "\\begin{document}" >> $@
	@echo "\\includepdf[nup=2x2,pages=-]{"$*"-Slides.pdf}" >> $@
	@echo "\\end{document}" >> $@

## Beamer style article - slight clash with todonotes
%-Notes.tex: %-src.tex
	@echo "%\\PassOptionsToPackage{override,tikz}{xcolor}" > $@
	@echo "%\\PassOptionsToPackage{override,xcolor}{tikz}" > $@
	@echo "%\\PassOptionsToPackage{override,xcolor}{todonotes}" > $@
	@echo "%\\PassOptionsToPackage{override,xcolor}{beamer}" > $@
	@echo "% best to comment todonotes as it just messes up" > $@
	@echo "\\documentclass[a4paper]{article}" > $@
	@echo "\\usepackage{beamerarticle}" >> $@
	@echo "\\input{"$*-src"}" >> $@
	@echo "\\end{document}" >> $@

## Housekeeping rules ---------------------------------------------------


## housekeeping which needs improving - especially backup (.tgz or
## .zip file?)  but this won't work without extra directories etc
## etc needs some checking and thought

.PHONY: clean
clean: 
	-rm -f *.pdf *.Rout *.log *.aux *.bbl *~

.PHONY: backup
backup:
	-zip -9 backup/backup-`date +%F`.zip *.R Makefile */*/*.csv *.pdf *.Rnw *.Rout
