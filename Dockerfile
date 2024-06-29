FROM node:20.15.0-alpine@sha256:df01469346db2bf1cfc1f7261aeab86b2960efa840fe2bd46d83ff339f463665 AS builder

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install \
  && apk del .gyp

COPY ./tsconfig.json ./
COPY ./src ./src/
RUN yarn build

# ---

FROM node:20.15.0-alpine@sha256:df01469346db2bf1cfc1f7261aeab86b2960efa840fe2bd46d83ff339f463665

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install --production \
  && apk del .gyp

COPY --from=builder /speedtest-prometheus-collector/build ./build/

EXPOSE 9030
CMD yarn start
