const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.write('\nHello World!\n\n');
  res.write(`(from ${os.hostname()} ${os.platform()} ${os.arch()})\n\n`)
  res.end();
});

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
