var page = require('webpage').create();
var timeoutTime = 8000, url = "http://localhost:5000/#!/general";
page.viewportSize = { width: 1920, height: 2080 };

page.onCallback = function() {
  window.setTimeout(function () {
    page.render('screenshot.jpeg', {format: 'jpeg', quality: '100'});
    phantom.exit();
   }, timeoutTime);
};

page.open(url);