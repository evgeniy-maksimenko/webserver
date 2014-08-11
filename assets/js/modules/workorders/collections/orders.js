define([
	'backbone',
	 
],function(Backbone){
	
	
	var Collection = Backbone.Collection.extend({
		 
	   	//url: '/api/test'

		initialize: function(status, fromDate, toDate) {
			if(fromDate && toDate)
			{
				this.url =  '/api/get_all_orders?status='+ status +'&destinate=MY_GROUP&fromDate='+fromDate+'&toDate='+toDate
			} else {
		    	this.url =  '/api/get_all_orders?status='+ status +'&destinate=MY_GROUP'
		    }
		  },
	 
	});

	return Collection;
})

