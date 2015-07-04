LHSFiles = \
    Choice.lhs

all: lib book

lib: .cabal-sandbox dist
	cabal build -j

.PHONY: cabal-init
cabal-init: .cabal-sandbox dist .cabal-sandbox/bin/hlint .cabal-sandbox/bin/hoogle

dist:
	cabal configure

.cabal-sandbox: bam.cabal
	cabal sandbox init
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle --only-dependencies

book: tex book.tex $(LHSFiles:%.lhs=tex/%.tex)
	latex book.tex
	latex book.tex

QUOTE = dist/build/Quote/Quote

tex/%.tex: src/%.lhs $(QUOTE)
	$(QUOTE) < $< > $@

$(QUOTE): utils/Quote.s
	cabal build Quote

tex:
	mkdir -p tex

.PHONY: cabal-clean
cabal-clean: real-clean
	rm -rf .cabal-sandbox cabal.sandbox.config Setup.hs

.PHONY: real-clean
real-clean: clean
	rm -rf tex

.PHONY: clean
clean:
	cabal clean
	rm -f *.dvi
	rm -f *.log
	rm -f *.aux
	rm -f tex/*.aux
	rm -f *.lof
	rm -f *.lot
	rm -f *.toc

.cabal-sandbox/bin/hlint:
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle hlint

.PHONY: hlint
hlint: .cabal-sandbox/bin/hlint
	.cabal-sandbox/bin/hlint .

.cabal-sandbox/bin/hoogle:
	cabal install -j --enable-documentation --haddock-html --haddock-hoogle hoogle
	.cabal-sandbox/bin/hoogle data

.PHONY: hoogle
hoogle: .cabal-sandbox/bin/hoogle



