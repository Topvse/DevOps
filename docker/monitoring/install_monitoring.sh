#!/bin/bash

mkdir -p ./monitoring/nginx
mkdir -p ./monitoring/grafana
mkdir -p ./monitoring/html

cat > ./monitoring/prometheus.yml <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']
EOL


cat > ./monitoring/nginx/nginx.conf <<EOL
events {}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    server {
        listen 80;

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }

        location /metrics {
            stub_status on;
            access_log off;
        }
    }
}
EOL

cat > ./docker-compose.yml <<EOL
version: '3'

services:

  prometheus:
    image: ubuntu/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    networks:
      - monitoring
    restart: always
    environment:
      - TZ=Europe/Moscow
    labels:
      - "com.example.description=Prometheus server"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    networks:
      - monitoring
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_SECURITY_ADMIN_USER=admin
    volumes:
      - grafana-storage:/var/lib/grafana
    restart: always
    labels:
      - "com.example.description=Grafana Dashboard"

  nginx:
    image: nginx:latest
    container_name: nginx
    volumes:
      - ./monitoring/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./monitoring/html:/usr/share/nginx/html
    ports:
      - "80:80"
    networks:
      - monitoring
    restart: always

networks:
  monitoring:
    driver: bridge

volumes:
  grafana-storage:
EOL

echo "Successfully"

docker compose up -d
