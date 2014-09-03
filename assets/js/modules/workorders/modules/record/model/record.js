define([
	'backbone',
	 
],function(Backbone){
	
	var Collection = Backbone.Collection.extend({
		initialize: function(attrs) {
				this.url =  '/api/find_one_record?record_id=' + attrs.id
		  }, 
	});

	return Collection;
})

