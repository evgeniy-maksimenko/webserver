define([
	'backbone',
	 
],function(Backbone){
	var Model = Backbone.Collection.extend({
		
		initialize: function(args) {
		    this.url =  '/api/get_order_info?wo-oid=' + args.id
		  },
	   	
	});

	return Model;
})

