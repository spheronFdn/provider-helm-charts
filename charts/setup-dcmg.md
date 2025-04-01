## Install Docker with Nvidia Container Toolkit

```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

## Install Nvidia Container Toolkit

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
wget -qO - https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - && \
wget -qO - https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

```bash
sudo nvidia-ctk runtime configure --runtime=docker
```

```bash
sudo systemctl restart docker
```

#### Test Nvidia Container Toolkit

```bash
docker run --runtime=nvidia --rm nvidia/cuda:12.3.0-base-ubuntu22.04 nvidia-smi
```

#### Run DCGM-exporter

```bash
docker run -d --runtime=nvidia --hostname <node-name> --restart=on-failure -p 9400:9400 nvidia/dcgm-exporter:latest
```


### Prometheus stack values.yaml 

```yaml
prometheus:
  prometheusSpec:
    remoteWrite:
      - url: http://vector.default.svc.cluster.local:9090
    additionalScrapeConfigs:
      - job_name: 'dcgm-exporter'
        static_configs:
          - targets:
              - '192.168.169.31:9400'
              - '192.168.169.8:9400'
              - '192.168.169.96:9400'
              - '192.168.169.199:9400'
              - '192.168.10.239:9400'
        metrics_path: '/metrics'
        scrape_interval: 15s  
```