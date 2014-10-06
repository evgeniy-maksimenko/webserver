define([
	'backbone',
	 
],function(Backbone){
	var Collection = Backbone.Collection.extend({
		
		url :  '/api/treatments?condition=all&status=1lvl'
		
	   	
	});

	return Collection;
})

