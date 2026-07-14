require('dotenv').config();
const mongoose = require('mongoose');
mongoose.connect("mongodb://localhost:27017/notisboard", { useNewUrlParser: true, useUnifiedTopology: true })
  .then(async () => {
    const Setting = require('./sourcecode/admin/backend/models/setting.model.js');
    const settings = await Setting.findOne();
    if (settings && settings.privateKey) {
      console.log("Firebase Project ID in Settings:", settings.privateKey.project_id);
    } else {
      console.log("No privateKey found in Settings!");
    }
    process.exit(0);
  });
