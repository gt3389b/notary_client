FROM golang:1.10.3

RUN apt-get update && apt-get install -y --quiet \
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
	jq \
	tree \
	vim \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "root:Docker!" | chpasswd

RUN useradd -ms /bin/bash notary \
	&& pip install codecov \
	&& pip install securesystemslib \
	&& pip install cfssl \
	&& pip install pyopenssl \
   && go get github.com/theupdateframework/notary \
   && go install -tags pkcs11 github.com/theupdateframework/notary/cmd/notary
#	&& go get github.com/golang/lint/golint github.com/fzipp/gocyclo github.com/client9/misspell/cmd/misspell github.com/gordonklaus/ineffassign github.com/securego/gosec/cmd/gosec/...

RUN chmod -R a+rw /go 

USER notary

WORKDIR /home/notary/

RUN export PATH=$PATH:/go/bin
RUN mkdir /home/notary/.notary
RUN mkdir /home/notary/.notary/trusted_certificates
RUN echo 'alias notary="notary -d ~/.notary"' >> ~/.bashrc

COPY ./root-ca.crt /home/notary/.notary/
COPY ./config.json /home/notary/.notary/
#COPY ./docker.com.crt /home/notary/.notary/trusted_certificates/
COPY ./data/*.crt /home/notary/.notary/trusted_certificates/
COPY --chown=notary:notary ./scripts/* ./

ENV NOTARY_ROOT_PASSPHRASE weakpass
ENV NOTARY_TARGETS_PASSPHRASE weakpass
ENV NOTARY_SNAPSHOT_PASSPHRASE weakpass
