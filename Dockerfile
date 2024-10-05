FROM node:20.18.0-alpine@sha256:c13b26e7e602ef2f1074aef304ce6e9b7dd284c419b35d89fcf3cc8e44a8def9 AS builder

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install \
  && apk del .gyp

COPY ./tsconfig.json ./
COPY ./src ./src/
RUN yarn build

# ---

FROM node:20.18.0-alpine@sha256:c13b26e7e602ef2f1074aef304ce6e9b7dd284c419b35d89fcf3cc8e44a8def9

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install --production \
  && apk del .gyp

COPY --from=builder /speedtest-prometheus-collector/build ./build/

EXPOSE 9030
CMD yarn start
