FROM node:7.8.0

WORKDIR /opt/app

COPY package.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
