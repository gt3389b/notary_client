FROM golang:1.10.3

RUN apt-get update && apt-get install -y \
	curl \
	clang \
	libltdl-dev \
	libsqlite3-dev \
	patch \
	tar \
	xz-utils \
	python \
	python-pip \
	python-setuptools \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash notary \
	&& pip install codecov \
   && go get github.com/theupdateframework/notary \
   && go install -tags pkcs11 github.com/theupdateframework/notary/cmd/notary
#	&& go get github.com/golang/lint/golint github.com/fzipp/gocyclo github.com/client9/misspell/cmd/misspell github.com/gordonklaus/ineffassign github.com/securego/gosec/cmd/gosec/...

RUN chmod -R a+rw /go 

USER notary

WORKDIR /home/notary/

RUN export PATH=$PATH:/go/bin
RUN mkdir /home/notary/.notary
RUN echo 'alias notary="notary -d ~/.notary"' >> ~/.bashrc


COPY ./root-ca.crt /home/notary/.notary/
COPY ./config.json /home/notary/.notary/
