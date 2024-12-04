# Sleep Apnea Visualizer

*Sleep Apnea Cost in Europe visualized in the map. For the method used in the visualizer, check project <https://github.com/janikmiet/sleep22calculator>*

- Working app available: <https://janimiettinen.shinyapps.io/sleepapneacost/>
 
- Dockerhub image: <https://hub.docker.com/repository/docker/janikmiet/sleeprevolution_visualization/general>


# Installation / App Launch

## Terminal App Run

```
R -e "shiny::runApp('app/')"
```


## Docker Image

Use docker to launch app

```
docker build  --no-cache -t sleep22visualizer . 
docker run --name shiny_sleep22visualizer --rm -d -p 3838:3838 sleep22visualizer
```

## ShinyServer / rsconnect

Modify and use script `deploy.R`



# Acknowledgement

![](app/img/alllogos.png) 
<br>
<img src="app/img/uef.png" style="width:4.0%" />