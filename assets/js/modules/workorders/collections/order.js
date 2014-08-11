define([
	'backbone',
	 
],function(Backbone){
	var Collection = Backbone.Collection.extend({
		
		initialize: function(args) {
		    this.url =  '/api/get_order_info?wo-oid=' + args.id
		  },
	   	
	});

	return Collection;
})

