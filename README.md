# ExGitHub2Jira

Simple service to create and close Github issues on Jira. Pet Elixir 
project to learn with and maybe a blog about it will come near future.

## System Environment Variables

- secret token added to the GitHub webhook
```
export SECRET_TOKEN=9fa72f26f151829a0599f3bfdc5294138a90c43c
```
- Jira URL
```
export JIRA_BASE_URL="https://jira.somwhere.com/rest/api/2"
```
- Jira authorization token
```
export JIRA_AUTH_TOKEN="Basic amFpbIUJ871lczpSOFBuR2tRcGYPOIUYIPw=="
```
- Server port
```
export PORT=80
```

## Test

```
MIX_ENV=test mix test
```

## run localy

```
MIX_ENV=prod mix run --no-halt
```