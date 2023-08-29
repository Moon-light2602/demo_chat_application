# demo_chat_application

# app.js

const { log } = require('console');
const express = require('express');
const { createServer } = require("http");
const { Server } = require("socket.io");

// const cors = require('cors'); // Import the cors package
// const { Socket } = require('dgram');

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer);

// app.use(cors());

app.route("/").get((req, res) => {
  res.json("Hey there welcome again Flutter!!!")
})

io.on("connection", (socket) => {
  socket.join("chat_users");
  console.log("backend connected");
  socket.on("sendMsg", (msg)=>{
    console.log("msg", msg);
    // socket.emit("sendMsgServer",{...msg, type:"otherMsg"})
    io.to("chat_users").emit("sendMsgServer", {...msg, type:"otherMsg"});
  })
  //.......
});
