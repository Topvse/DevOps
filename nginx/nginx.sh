#!/bin/bash

echo "Установка nginx"

sudo apt update && sudo apt install -y nginx

echo "nginx установлен"

echo "Запуск сервера"
sudo systemctl enable nginx
sudo systemctl start nginx

echo "Проверь nginx на http://localhost"
