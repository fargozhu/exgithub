#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:1.9.0 as build

RUN mix local.hex --force
RUN mix local.rebar --force

#Copy the source folder into the Docker image
COPY . .

#Set environment variables and expose port
ARG JIRA_AUTH_TOKEN
ARG JIRA_BASE_URL
ARG SECRET_TOKEN

ENV REPLACE_OS_VARS=true \
    JIRA_AUTH_TOKEN=$JIRA_AUTH_TOKEN \
    JIRA_BASE_URL=$JIRA_BASE_URL \
    SECRET_TOKEN=$SECRET_TOKEN

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix distillery.release

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="exgithub" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

RUN apk --no-cache add bash curl

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Set environment variables and expose port
ARG JIRA_AUTH_TOKEN
ARG JIRA_BASE_URL
ARG SECRET_TOKEN

ENV REPLACE_OS_VARS=true \
    JIRA_AUTH_TOKEN=$JIRA_AUTH_TOKEN \
    JIRA_BASE_URL=$JIRA_BASE_URL \
    SECRET_TOKEN=$SECRET_TOKEN

EXPOSE 80

#Change user
USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/exgithub"]
CMD ["foreground"]