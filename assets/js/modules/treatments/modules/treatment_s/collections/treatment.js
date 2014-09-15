define([
	'backbone',
	 
],function(Backbone){
	var Collection = Backbone.Collection.extend({
		
		initialize: function() {
		    this.url =  '/api/treatments?condition=all&status=2lvl'
		  },
	   	
	});

	return Collection;
})

