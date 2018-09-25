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
RUN mkdir /home/notary/bin
ENV PATH="/home/notary/bin:${PATH}"

RUN mkdir /home/notary/.notary
RUN mkdir /home/notary/.notary/trusted_certificates
RUN echo 'alias notary="notary -d ~/.notary"' >> ~/.bashrc
RUN echo 'set -o vi' >> ~/.bashrc

COPY --chown=notary:notary ./root-ca.crt /home/notary/.notary/
COPY --chown=notary:notary ./config.json /home/notary/.notary/
#COPY ./docker.com.crt /home/notary/.notary/trusted_certificates/
#COPY --chown=notary:notary ./data/*.crt /home/notary/.notary/trusted_certificates/
COPY --chown=notary:notary ./certificates_ca/cacerts.crt /home/notary/.notary/trusted_certificates/
COPY --chown=notary:notary ./certificates_ca ./certificates_ca
COPY --chown=notary:notary ./certificates_repo ./certificates_repo
COPY --chown=notary:notary ./scripts/* ./bin/

ENV NOTARY_ROOT_PASSPHRASE weakpass
ENV NOTARY_TARGETS_PASSPHRASE weakpass
ENV NOTARY_SNAPSHOT_PASSPHRASE weakpass
ENV NOTARY_DELEGATION_PASSPHRASE weakpass