define([
	'backbone',
	 
],function(Backbone){
	
	
	var Collection = Backbone.Model.extend({
		 
	   	//url: '/api/test'
	   	url: '/api/get_all_orders?status=WORK&destinate=MY_GROUP'
	});

	return Collection;
})

