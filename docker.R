
system("docker build -t sleep22visualizer . ")
system("docker run --name shiny_sleep22visualizer --rm -d -p 3838:3838 sleep22visualizer") # run container
# system("docker stop shiny_container")
