# Build Vue
FROM node:14.5.0-alpine as build-stage

ARG VUE_APP_VERSION
ENV VUE_APP_VERSION=${VUE_APP_VERSION}

WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend/ .
RUN npm run build

# Deploy Stage
FROM python:3.8-alpine as deploy-stage

# Set Variables
ENV PYTHONIOENCODING=UTF-8
ENV THEME=Default

WORKDIR /api
COPY ./backend/requirements.txt .

# Install Dependancies
RUN apk add --no-cache --virtual=build-dependencies \
    g++ \
    make \
    postgresql-dev \
    python3-dev \
    libffi-dev \
    ruby-dev && \
    apk add --no-cache \
    python3 \
    py3-pip \
    mysql-dev \
    postgresql-dev \
    mysql-dev \
    nginx && \
    gem install sass && \
    pip3 install wheel && \
    pip3 install -r requirements.txt && \
    apk del --purge build-dependencies && \
    rm -rf /root/.cache /tmp/*

COPY ./backend/api ./
COPY ./backend/alembic /alembic
COPY root ./backend/alembic.ini /

# Vue
COPY --from=build-stage /app/dist /app
COPY nginx.conf /etc/nginx/

# Expose
VOLUME /config
EXPOSE 8000