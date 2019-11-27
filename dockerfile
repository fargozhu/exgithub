#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:1.9.0 as builder

RUN mix local.hex --force
RUN mix local.rebar --force

#Copy the source folder into the Docker image
COPY . .

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix distillery.init && \
    mix distillery.release

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="exgithub" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM bitwalker/alpine-elixir:1.9.0 as deployer

RUN apk --no-cache add bash curl
RUN set -ex && apk --no-cache add sudo

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=builder /export/ .

#Set environment variables and expose port
ARG LABEL
ARG JIRA_AUTH_TOKEN
ARG JIRA_BASE_URL
ARG PORT
ARG SECRET_TOKEN
ARG LOG_LEVEL

ENV REPLACE_OS_VARS=true \
    LOG_LEVEL=$LOG_LEVEL \
    PORT=$PORT \
    LABEL=$LABEL \
    JIRA_AUTH_TOKEN=$JIRA_AUTH_TOKEN \
    JIRA_BASE_URL=$JIRA_BASE_URL \
    SECRET_TOKEN=$SECRET_TOKEN

EXPOSE $PORT

#Change user
USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/exgithub"]
CMD ["foreground"]