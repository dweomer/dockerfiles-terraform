FROM dweomer/hashibase as verify

WORKDIR /tmp

ARG TERRAFORM_VERSION=0.11.3

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS         /tmp/
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig     /tmp/
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip    /tmp/

RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN grep linux_amd64 terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -cs
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin
RUN terraform version

FROM alpine

ARG TERRAFORM_GID=1337
ARG TERRAFORM_UID=1337

RUN set -x \
 && apk add --no-cache \
    curl \
    git \
    openssh \
 && addgroup -g ${TERRAFORM_GID} terraform \
 && adduser -S -G terraform -u ${TERRAFORM_UID} terraform

COPY --from=verify /usr/local/bin/* /usr/local/bin/

USER terraform
ENTRYPOINT ["terraform"]
CMD ["help"]
