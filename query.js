const mongoose = require("mongoose");
mongoose.connect("mongodb://127.0.0.1:27017/talkinall").then(async () => {
  // Find users where isListener=true
  const users = await mongoose.connection.db.collection('users').find({ isListener: true }).toArray();
  console.log("Total expert users:", users.length);
  if (users.length > 0) {
    users.slice(0,3).forEach(u => {
      console.log("User:", u._id, "| listenerId:", u.listenerId, "| email:", u.email);
    });
  }
  process.exit(0);
});
