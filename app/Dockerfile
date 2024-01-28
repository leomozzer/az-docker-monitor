FROM node:18-alpine

WORKDIR /usr/app

COPY package.json ./

RUN npm install

EXPOSE 8080

COPY src ./src

CMD ["npm", "run", "start"]