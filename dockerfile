#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:1.9.0 as build

#Copy the source folder into the Docker image
COPY . .

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="ExGitHub2Jira" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
EXPOSE ${PORT}
ENV REPLACE_OS_VARS=true \
    PORT=${PORT} \
    JIRA_AUTH_TOKEN=${JIRA_AUTH_TOKEN} \
    JIRA_BASE_URL==${JIRA_BASE_URL=} \
    SECRET_TOKEN=${SECRET_TOKEN}

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Change user
USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/ExGitHub2Jira"]
CMD ["foreground"]