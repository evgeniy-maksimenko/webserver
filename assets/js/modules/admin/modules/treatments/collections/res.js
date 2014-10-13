define([
	'backbone',
	 
],function(Backbone){
	var Collection = Backbone.Collection.extend({
		
		initialize: function() {
		    this.url =  '/api/treatments?condition=rtg&rating=3'
		  },
	   	
	});

	return Collection;
})

