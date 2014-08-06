define([
	'backbone',
	 
],function(Backbone){
	
	
	var Collection = Backbone.Collection.extend({
		 
	   	url: '/api/test'
	});

	return Collection;
})

