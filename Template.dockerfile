###### BUILDER
FROM %%BASE_IMAGE%% as builder
WORKDIR /project

ARG COMMIT
ARG CACHEBUST

RUN apt-get install -y \
  git

RUN echo "$CACHEBUST"
RUN git clone https://github.com/Kaiede/BedrockifierCLI.git /project
RUN git checkout ${COMMIT}
RUN swift build -j 1 -c release

###### RUNTIME CONTAINER
FROM %%BASE_IMAGE%%-slim
WORKDIR /opt/bedrock

ARG ARCH

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker.io \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/entrypoint-demoter", "--match", "/backups", "--debug", "--stdin-on-term", "stop", "/opt/bedrock/bedrockifierd"]
HEALTHCHECK --start-period=1m CMD bash /opt/bedrock/healthcheck.sh

ARG EASY_ADD_VERSION=0.7.0
ADD https://github.com/itzg/easy-add/releases/download/${EASY_ADD_VERSION}/easy-add_linux_${ARCH} /usr/local/bin/easy-add
RUN chmod +x /usr/local/bin/easy-add

RUN easy-add --var version=0.2.1 --var app=entrypoint-demoter --file {{.app}} --from https://github.com/itzg/{{.app}}/releases/download/{{.version}}/{{.app}}_{{.version}}_linux_${ARCH}.tar.gz

COPY --from=builder /project/.build/release/bedrockifier-tool .
COPY --from=builder /project/.build/release/bedrockifierd .
COPY ./healthcheck.sh .

