FROM node:16.14.2

WORKDIR /speedtest-prometheus-collector

COPY ./package.json ./yarn.lock ./
RUN yarn install

COPY ./tsconfig.json ./
COPY ./src ./src/
RUN yarn build

EXPOSE 9030
CMD yarn start
