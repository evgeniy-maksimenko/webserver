define([
	'backbone',
	 
],function(Backbone){
	var Collection = Backbone.Collection.extend({
		
		initialize: function() {
		    this.url =  '/api_tm_view/treatments?condition=all&status=1lvl'
		  },
	   	
	});

	return Collection;
})

