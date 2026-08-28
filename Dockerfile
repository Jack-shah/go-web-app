#Using the base image to build the project
FROM golang:1.22.5-alpine AS build   

# all the commands now run in  give directory in cotainer
WORKDIR /app

#this is like pom.xml ......dependencies manage
COPY  go.mod .  

# used to download the exact dependenciesdefined in go.od file
RUN go mod download         

# copy the all file from current folder on HOST( where DOckerfile is) to WORKDIR /app in container
COPY . .   
RUN go build -o main .

# above part  creates binary or artifact.......
# now we only need the final binary not the source code or other unnecessary file to run.........
# we only need the binary and it run time to run the app
# In below part we will  create a running image of this binary which will reduce the image size 

# To achive this we will use  dictroless image in RUN stage
FROM gcr.io/distroless/base

# Copy the artefact/binary from build stage
COPY --from=build /app/main  .

#Also copy the files which are needed and not part of the Binary
COPY --from=build /app/static  ./static  

#expose the port on conatainer 
EXPOSE 8080

#setting the default command  to run once this conatiner comes alive
CMD [ "./main" ]


