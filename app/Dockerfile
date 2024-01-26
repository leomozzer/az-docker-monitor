FROM node:18-alpine

WORKDIR /usr/app

COPY package.json ./

RUN npm install

COPY src ./src

CMD ["npm", "run", "start"]