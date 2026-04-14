FROM node:16

WORKDIR /opt

COPY package.json ./

RUN npm install && npm install -g serve

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["serve", "-s", "build", "-l", "3000"]
