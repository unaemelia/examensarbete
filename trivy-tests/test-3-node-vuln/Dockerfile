# Testfall: Sårbar Bibliotek
FROM node:14

WORKDIR /app

COPY package.json .
COPY index.js .

RUN npm install

EXPOSE 3000

CMD ["node", "index.js"]
