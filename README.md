# Waypoint K8s go GRPC

## Run

```
$ waypoint init
$ waypoint up
```
## Verify

```
grpcurl -d '{"name":"test"}' k8s-grpc.7ldev.com:443 helloworld.Greeter/SayHello
```

## Useful links
https://github.com/kubernetes
https://github.com/hashicorp
https://github.com/hashicorp/waypoint
https://devcenter.heroku.com/articles/buildpacks
https://paketo.io/
https://github.com/spinnaker
https://about.gitlab.com/solutions/kubernetes/
