Parse.Cloud.job("push64", function(request, status) {
	Parse.Cloud.httpRequest({
	  url: 'http://motosaratov.ru/rss/forums/2-1/',
	  success: function(httpResponse) {
	    var xmlreader = require('cloud/xmlreader.js');
	    xmlreader.read(httpResponse.text, function (err, res) {
	    	if(err) return console.error(err);
	    	console.log('Fetched items: ' + res.rss.channel.item.count());
	    	
    	    res.rss.channel.item.each(function (i, item){
    	    	var RssFeed = Parse.Object.extend("RssFeed");
				var query = new Parse.Query(RssFeed);
				query.equalTo("pubDate", item.pubDate.text());
				
				query.count({
				  success: function(count) {
				    if (count == 0) {
				    	addItem(item.title.text(), item.pubDate.text());
				    	push(item.title.text())
				    }
				  },
				  error: function(error) {
				  	console.error("Error: " + error.code + " " + error.message);
				  }
				});
		    });
		    //status.success("Done");
		});
	  },
	  error: function(httpResponse) {
	    console.error('Request failed with response code ' + httpResponse.status);
	    status.error('Request failed with response code ' + httpResponse.status);
	  }
	});

	function addItem(title, pubDate) {
		var RssFeed = Parse.Object.extend("RssFeed");
		var rssFeed = new RssFeed();
		rssFeed.set("title", title);
		rssFeed.set("pubDate", pubDate);
		 
		rssFeed.save(null, {
		  success: function(rssFeed) {
		    console.log('New item created: ' + title);
		  },
		  error: function(rssFeed, error) {
		    console.error('Failed to create new item, with error code: ' + error.message);
		  }
		});
	}
	
	function push(msg) {
		Parse.Push.send({
		  channels: [ "Moto64" ],
		  data: {
		    alert: msg,
		    badge: "Increment",
		    sound: "crash.aiff"
		  }
		}, {
		  success: function() {
		    console.log("Push sent: " + msg);
		  },
		  error: function(error) {
		    console.error('Push error: ' + error);
		  }
		});
	}
});