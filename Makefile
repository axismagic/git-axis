NAME = Git Axis
VERSION := $(shell git describe --abbrev=0 2> /dev/null || (git branch | sed -e '/^[^*]/d' -e 's/^[*] //'))
RELEASE := Git Axis $(VERSION)

MAN = man/man1/git-axis.1
DOC = doc/git-axis.html

all: man

man: $(MAN)

doc: $(DOC)

doc/git-axis.html: git-axis.pod
	mkdir -p doc
	pod2html --css man.css --title "$(NAME) Manual" $^ > $@

man/man1/git-axis.1: git-axis.pod
	mkdir -p man/man1
	pod2man --center "$(NAME) Manual" --release "$(RELEASE)" $^ > $@

clean:
	rm -f $(MAN) $(DOC)

.PHONY: man clean
