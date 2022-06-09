FROM node:16.14.2-alpine AS builder

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install \
  && apk del .gyp

COPY ./tsconfig.json ./
COPY ./src ./src/
RUN yarn build

FROM node:16.14.2-alpine

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./

RUN apk add --no-cache --virtual .gyp python3 make g++ \
  && yarn install --production \
  && apk del .gyp

COPY --from=builder /speedtest-prometheus-collector/build ./build/

EXPOSE 9030
CMD yarn start
